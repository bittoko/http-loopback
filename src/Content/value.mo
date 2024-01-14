import { mapEntries } "mo:base/Array";
import T "types";

module {

  public func wrapNat(v: Nat): T.Value = #nat(v);

  public func unwrapNat(v: T.Value): ?Nat {
    let #nat(value) = v else { return null };
    ?value
  };

  public func wrapBlob(v: Blob): T.Value = #blob(v);

  public func unwrapBlob(v: T.Value): ?Blob {
    let #blob(value) = v else { return null };
    ?value
  };

  public func wrapText(v: Text): T.Value = #text(v);

  public func unwrapText(v: T.Value): ?Text {
    let #text(value) = v else { return null };
    ?value
  };

  public func wrapMap<V>(v: V, mapFn: (V) -> T.Map): T.Value = #map(mapFn(v));
  
  public func unwrapMap(v: T.Value): ?T.Map {
    let #map(value) = v else { return null };
    ?value
  };

  public func wrapArray<V>(v: [V], wrapFn: (V) -> T.Value): T.Value {
    #array(mapEntries<V, T.Value>(v, func(x, _) = wrapFn(x)))
  };

  public func unwrapArray(v: T.Value): ?T.Array {
    let #array(value) = v else { return null };
    ?value
  };

};