import { set = mapSet; get = mapGet; thash; new } "mo:map/Map";
import { fromIter; toArray } "mo:map/Map";
import { mapEntries } "mo:base/Array";
import { trap } "mo:base/Debug";
import T "types";

module {

  public class Content() = {

    var hashmap = new<T.Key, T.CborValue>();

    public func set(k: T.Key, v: T.CborValue): () = mapSet(hashmap, thash, k, v);

    public func get<V>(k: T.Key, fn: (T.CborValue) -> ?V): ?V {
      let ?value = mapGet<T.Key, T.CborValue>(hashmap, thash, k) else { return null };
      fn( value )
    };
    
    public func dump() : [T.CborEntry] {
      mapEntries<T.Entry, T.CborEntry>(toArray(hashmap), func((key, val), _) = (#majorType3(key), val));
    };

    public func load(data: T.CborMap): () {
      hashmap := fromIter<T.Key, T.CborValue>(
        mapEntries<T.CborEntry, T.Entry>(data, func((key, value), cnt): T.Entry {
          switch( key ){
            case( #majorType3 name ) (name, value);
            case _ ("bad_field_" # debug_show(cnt), value);
        }}).vals(),
        thash
      )
    };
    
  };

};