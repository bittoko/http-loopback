import T "types";
import C "content";
import { HashTree } "tree";

module {

  public type Key = T.Key;

  public type Tree = T.HashTree;

  public type ContentMap = T.ContentMap;

  public type CborMap = T.CborMap;

  public type Value = T.CborValue;

  public type Array = T.CborArray;

  public type Record = T.CborRecord;

  public let { load; dump } = C;

  public func getNat64(v: Value): ?Nat64 {
    let #majorType0(value) = v else { return null };
    ?value
  };

  public func getByteArray(v: Value): ?[Nat8] {
    let #majorType2(value) = v else { return null };
    ?value
  };

  public func getText(v: Value): ?Text {
    let #majorType3(value) = v else { return null };
    ?value
  };

  public func getContentMap(v: Value): ?ContentMap {
    let #majorType2( bytes ) = v else { return null };
    ?load( bytes )
  };

  public func getHashTree(v: Value): ?Tree{
    let #majorType4( arr ) = v else { return null };
    ?HashTree( arr )
  };
};