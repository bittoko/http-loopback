import T "types";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Sha256 "mo:sha2/Sha256";
import NatX "mo:xtended-numbers/NatX";
import Array "mo:base/Array";
import { tabulate; init; mapEntries; foldLeft } "mo:base/Array";

module {

  type Bytes = { next : () -> ?Nat8 };

  func hashBlob(b: Blob): Blob { Sha256.fromBlob(#sha256, b) };

  func hashIter(i: Bytes): Blob { Sha256.fromIter(#sha256, i) };

  public func fromMap(map: T.Map): T.Hash {

    let field_buffer = Buffer.Buffer<Blob>(map.size());

    for ( (k, v) in map.vals() ){
      var index : Nat = 0;
      let entry : [var Nat8] = init<Nat8>(64, 0x00);
      let key : Bytes = hashBlob(Text.encodeUtf8(k)).vals();
      let value : Bytes = switch( v ){
        case( #map m ) fromMap(m).vals();
        case( #blob b ) hashBlob(b).vals();
        case( #text t ) hashBlob(Text.encodeUtf8(t)).vals();
        case( #array a ) fromArray(a).vals();
        case( #nat n ) {
          let buffer = Buffer.Buffer<Nat8>(0);
          NatX.encodeNat(buffer, n, #unsignedLEB128);
          buffer.vals()
        };
      };

      for ( byte in key ) { entry[index] := byte; index += 1 };

      for ( byte in value ) { entry[index] := byte; index += 1 };

      field_buffer.add(Blob.fromArrayMut( entry ));

    };

    field_buffer.sort(Blob.compare);

    var index : Nat = 0;
    let size : Nat = field_buffer.size() * 32;
    let bytearray : [var Nat8] = init<Nat8>(size, 0x00);
    for ( field in field_buffer.vals() ){
      for ( byte in field.vals() ) { bytearray[index] := byte; index += 1 }
    };

    hashIter( bytearray.vals() )

  };


  func fromArray(array: T.Array): T.Hash {
    Sha256.fromBlob(#sha256, Blob.fromArray(
      Buffer.toArray<Nat8>(
        Array.foldLeft<T.Value, Buffer.Buffer<Nat8>>(
          array, Buffer.Buffer<Nat8>(array.size()), func(buffer, value): Buffer.Buffer<Nat8> {
            buffer.append(Buffer.fromIter<Nat8>(
              switch( value ){
                case( #map m ) fromMap(m).vals();
                case( #blob b ) Sha256.fromBlob(#sha256, b).vals();
                case( #text t ) Sha256.fromBlob(#sha256, Text.encodeUtf8(t)).vals();
                case( #array a ) fromArray(a).vals();
                case( #nat n ) {
                  let buffer = Buffer.Buffer<Nat8>(0);
                  NatX.encodeNat(buffer, n, #unsignedLEB128);
                  Sha256.fromBlob(#sha256, Blob.fromArray(Buffer.toArray(buffer))).vals()
                };
              }
            ));
            buffer
          }
        ))
      )
    )
  };

};