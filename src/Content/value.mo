import T "types";

module {

//  public func wrapNat(v: Nat): T.CborValue = #nat(v);

  public func unwrapNat64(v: T.CborValue): ?Nat64 {
    let #majorType0(value) = v else { return null };
    ?value
  };

//  public func wrapBlob(v: Blob): T.CborValue = #blob(v);

  public func unwrapBytes(v: T.CborValue): ?[Nat8] {
    let #majorType2(value) = v else { return null };
    ?value
  };

//  public func wrapText(v: Text): T.CborValue = #text(v);

  public func unwrapText(v: T.CborValue): ?Text {
    let #majorType3(value) = v else { return null };
    ?value
  };

 // public func wrapMap<V>(v: V, mapFn: (V) -> T.Map): T.CborValue = #map(mapFn(v));
  
  public func unwrapMap(v: T.CborValue): ?T.CborMap {
    let #majorType5(value) = v else { return null };
    ?value
  };

//  public func wrapArray<V>(v: [V], wrapFn: (V) -> T.CborValue): T.CborValue {
//    #array(mapEntries<V, T.CborValue>(v, func(x, _) = wrapFn(x)))
//  };

  public func unwrapArray(v: T.CborValue): ?T.CborArray {
    let #majorType4(value) = v else { return null };
    ?value
  };

  public func unwrapRecord(v: T.CborValue): ?(Nat64, T.CborValue) {
    let #majorType6(rec) = v else { return null };
    ?(rec.tag, rec.value)
  };

};