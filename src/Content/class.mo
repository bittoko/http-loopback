import { set = mapSet; get = mapGet; thash } "mo:map/Map";
import { toArray = blobToArray; fromArray = blobFromArray } "mo:base/Blob";
import { fromIter; toArray } "mo:map/Map";
import Hash "hash";
import Cbor "cbor";
import T "types";

module {

  public class Content(map_: T.Map) = {

    var hashmap = fromIter<T.Key, T.Value>(map_.vals(), thash);

    public func export_map(): T.Map {
      toArray<T.Key, T.Value>(hashmap)
    };

    public func import_map(map: T.Map): () {
      hashmap := fromIter<T.Key, T.Value>(map.vals(), thash)
    };

    public func export_cbor() : T.Return<[Nat8], T.EncodingError> {
      Cbor.encode(Cbor.fromMap(export_map()));
    };

    public func import_cbor(data: T.Cbor): T.Return<(), T.DecodingError> {
      switch( Cbor.decode( blobFromArray(data) ) ){
        case( #err msg ) #err(msg);
        case( #ok cbor ){
          let ?map = Cbor.toMap( cbor ) else {
            return #err(#invalid("Unsupported CBOR Type"))
          };
          #ok( import_map( map ) )
        }
      }
    };

    public func set(k: T.Key, v: T.Value): () = mapSet(hashmap, thash, k, v);

    public func get<V>(k: T.Key, fn: (T.Value) -> ?V): ?V {
      let ?value = mapGet(hashmap, thash, k) else { return null };
      fn( value )
    };

    public func hash(): T.Hash = Hash.fromMap( export_map() );
    
  };

};