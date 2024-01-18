import C "class";
import V "value";
import T "types";
import Cb "cbor";

module {

  public type Cbor = T.Cbor;

  public type Hash = T.Hash;

  public type Content = C.Content;
  
  public type DecodingError = T.DecodingError;
  
  public type EncodingError = T.EncodingError;

  public type Return<X,Y> = T.Return<X, Y>;

  public type Map = T.Map;

  public type Entry = T.Entry;

  public type Array = T.Array;

  public type Key = T.Key;

  public type Value = T.Value;

  public let Cbor = Cb;

  public let { Content } = C;

  public let { unwrapNat; unwrapBlob; unwrapText } = V;

  public let { wrapNat; wrapBlob; wrapText } = V;

  public let { unwrapMap; unwrapArray } = V;

  public let { wrapMap; wrapArray } = V;

};