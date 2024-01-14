import { trap } "mo:base/Debug";
import { Buffer; toArray = bufferToArray } "mo:base/Buffer";
import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Encoder "mo:cbor/Encoder";
import Decoder "mo:cbor/Decoder";
import Cbor "mo:cbor/Value";
import { mapEntries } "mo:base/Array";
import T "types";

module {

  type FullCbor = Cbor.Value;

  public let { encode } = Encoder;

  public let { decode } = Decoder;
  
  public func fromMap(map: T.Map): T.CborMap {
    #majorType5(mapEntries<T.Entry, T.CborEntry>(
      map, func(entry, _) = (
        #majorType3(entry.0),
        switch( entry.1 ){
          case( #map m ) fromMap(m);
          case( #nat n ) #majorType0(Nat64.fromNat(n));
          case( #blob b ) #majorType2(Blob.toArray(b));
          case( #text t ) #majorType3(t);
          case( #array a ) fromArray(a);
        }
      )
    ))
  };

  public func toMap(cbor: FullCbor): ?T.Map {
    let #majorType5( cbor_entries ): FullCbor = cbor else { return null };
    let buffer = Buffer<T.Entry>( cbor_entries.size() );
    for ( cbor_entry in cbor_entries.vals() ){
      let #majorType3( key ) = cbor_entry.0 else { return null };
      switch( cbor_entry.1 ){
        case ( #majorType0 n ) buffer.add((key, #nat(Nat64.toNat(n))));
        case ( #majorType2 b ) buffer.add((key, #blob(Blob.fromArray(b))));
        case ( #majorType3 t ) buffer.add((key, #text(t)));
        case ( #majorType4 a ) {
          let ?array_ = toArray(cbor_entry.1) else { return null };
          buffer.add((key, #array(array_)))
        };
        case ( #majorType5 m ) {
          let ?map_ = toMap(cbor_entry.1) else { return null };
          buffer.add((key, #map(map_)))
        };
        case ( #majorType1 _ ) return null;
        case ( #majorType6 _ ) return null;
        case ( #majorType7 _ ) return null;
      }
    };
    ?bufferToArray<T.Entry>( buffer )
  };

  func fromArray(array: T.Array): T.CborArray {
    #majorType4(mapEntries<T.Value, T.CborValue>(
      array, func (value, _): T.CborValue {
        switch( value ){
          case( #map m ) fromMap(m);
          case( #nat n ) #majorType0(Nat64.fromNat(n));
          case( #blob b ) #majorType2(Blob.toArray(b));
          case( #text t ) #majorType3(t);
          case( #array a ) fromArray(a);
        };
      }
    ))
  };

  func toArray(cbor: FullCbor): ?T.Array {
    let #majorType4( cbor_array ) = cbor else { return null };
    let buffer = Buffer<T.Value>( cbor_array.size() );
    for ( cbor_value in cbor_array.vals() ){
      switch( cbor_value ){
        case ( #majorType0 n ) buffer.add(#nat(Nat64.toNat(n)));
        case ( #majorType2 b ) buffer.add(#blob(Blob.fromArray(b)));
        case ( #majorType3 t ) buffer.add(#text(t));
        case ( #majorType4 a ) {
          let ?array_ = toArray(cbor_value) else { return null };
          buffer.add(#array(array_))
        };
        case ( #majorType5 m ) {
          let ?map_ = toMap(cbor_value) else { return null };
          buffer.add(#map(map_))
        };
        case ( #majorType1 _ ) return null;
        case ( #majorType6 _ ) return null;
        case ( #majorType7 _ ) return null;
      }
    };
    ?bufferToArray<T.Value>( buffer )
  };

};