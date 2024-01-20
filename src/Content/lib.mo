import C "class";
import V "value";
import T "types";

module {

  public type Content = C.Content;

  public type Key = T.Key;

  public type Value = T.CborValue;

  public type Map = T.CborMap;

  public let { Content } = C;

  public let { unwrapNat64; unwrapBytes; unwrapText } = V;

  public let { unwrapRecord; unwrapMap; unwrapArray } = V;

};