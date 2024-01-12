import T ".";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Sha256 "mo:sha2/SHA256";
import NatX "mo:xtended-numbers/NatX";
import Array "mo:base/Array";

module {

  public func fromBlob(x: Blob): T.Hash = Sha256.fromBlob(x);

  public func fromText(x: Text): T.Hash = Sha256.fromBlob(Text.encodeUtf8(x));

  public func fromNat(x: Nat): T.Hash {
    let buffer = Buffer<Nat8>(0);
    NatX.encodeNat(buffer, x, #unsignedLEB128);
    Sha256.fromBlob(Blob.fromArray(Buffer.toArray(buffer)))
  };

  public func fromPaths(paths: T.Paths): Hash {
    Sha256.fromBlob(Blob.fromArray(

        // Concatenate hashes of StatePath elements
        Buffer.toArray<Nat8>(
          Array.foldLeft<[Blob], Buffer<Nat8>>(paths, Buffer<Nat8>(table.size()), func(b0, path_elements) = {
            b0.append(Buffer.fromIter<Nat8>(

                // Hash each StatePath element
                Sha256.fromBlob(Blob.fromArray(

                    // Concatenate hashes of PathLabel elements
                    Buffer.toArray<Nat8>(
                      Array.foldLeft<Blob, Buffer<Nat8>>(
                        path_elements, Buffer<Nat8>(path_elements.size()),

                        // Hash each PathLabel element
                        func(b1, element): Buffer<Nat8> = {
                          b1.append(Buffer.fromIter<Nat8>(
                            Sha256.fromBlob(element).vals()
                          ));
                          b1
                        }
                      )
                    )
                  )
                ).vals()
              )
            );
            b0
          })
        )
      )
    )
  }; 

  public func fromMap(map: T.Map): T.Hash {
    let map_buffer = Array.foldLeft<T.Field, Buffer<Blob>>(
      map, Buffer<Blob>(map.size()),
      func(b0, field): Buffer<Blob> {
        let field_buffer = Buffer.fromArray<Nat8>(Blob.toArray(fromString(field.0)));
        field_buffer.append(
          Buffer.fromArray<Nat8>(
            Blob.toArray(
              switch( field.1 ){
                case( #map m ) fromMap(m);
                case( #nat n ) fromNat(n);
                case( #blob b ) fromBlob(b);
                case( #text t ) fromText(t);
                case( #paths p) fromPaths(p);
      })))});
    map_buffer.sort(Blob.compare)
    var idx: Nat = 0;
    let size = Buffer.foldLeft<Nat, Blob>(map_buffer, 0, func(a, x) = { a + x.size() });
    let bytearray = Array.init<Nat8>(size, 0x00);
    for ( blob in map_buffer.vals() ){
      for ( byte in blob.vals() ){ bytearray[idx] := byte; idx += 1 };
    };
    Sha256.fromBlob(Blob.fromArray(bytearray))
  };

};