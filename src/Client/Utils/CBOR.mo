import Encoder "mo:cbor/Encoder";
import Decoder "mo:cbor/Decoder";
import { trap } "mo:base/Debug";
import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Errors "mo:cbor/Errors";
import Result "mo:base/Result";
import { mapEntries } "mo:base/Array";
import T "Types";

module {

  public type EncodingError = Errors.EncodingError;

  public type DecodingError = Errors.DecodingError;

  public let encode = Encoder.encode;

  public let decode = Decoder.decode;

  public func fromNat(x: Nat): T.CBOR = #majorType0(Nat64.fromNat(x));

  public func toNat(cbor: T.CBOR): Nat {
    let #majorType0( nat64 ) = cbor else { trap("Unexpected CBOR value") }; 
    return Nat64.toNat( nat64 );
  };

  public func fromBlob(x: Blob): T.CBOR = #majorType2(Blob.toArray(x));

  public func toBlob(cbor: T.CBOR): Blob {
    let #majorType2( bytes ) = cbor else {trap("Unexpected CBOR value") };
    return Blob.fromArray( bytes );
  };

  public func fromText(x: Text): T.CBOR = #majorType3(x);

  public func toText(cbor: T.CBOR): Text {
    let #majorType3( txt ) = cbor else { trap("Unexpected CBOR value") };
    return txt
  };

  public func fromMap(content: T.ContentMap): T.CBOR {
    #majorType5(mapEntries<T.Field, (T.CBOR, T.CBOR)>(
      content, func(field, _) = (
        #majorType3(field.0),
        switch( field.1 ){
          case( #map m ) fromMap(m);
          case( #nat n ) fromNat(n);
          case( #blob b ) fromBlob(b);
          case( #text t ) fromText(t);
          case( #paths p ) fromPaths(p);
        }
      )
    ))
  };

  public func toMap(fields: [(T.CBOR, T.CBOR)]): T.ContentMap {
    let map = mapEntries<(T.CBOR, T.CBOR), T.Field>(
      fields, func(cbor, _): T.Field {
        let #majorType3( name ) = cbor.0 else { trap("Malformed content") };
        switch( cbor.1 ){
          case ( #majorType5 m ) (name, #map(toMap(m)));
          case ( #majorType0 n ) (name, #nat(Nat64.toNat(n)));
          case ( #majorType2 b ) (name, #blob(Blob.fromArray(b)));
          case ( #majorType3 t ) (name #text(t));
          case ( #majorType4 p ) (name #paths(toPaths(p)));
        }
      }
    );
    ?map
  };

  public func fromPaths(paths: T.Paths): T.CBOR {
    #majorType4(mapEntries<[Blob], T.CBOR>(
      paths, func (path_elements, _): T.CBOR {
        #majorType4(mapEntries<Blob, T.CBOR>(
          path_elements, func(element, _): T.CBOR {
            #majorType2(element)
          }
        ))
      }
    ))
  };

};