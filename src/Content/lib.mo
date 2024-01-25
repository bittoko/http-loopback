import C "class";
import V "value";
import T "types";
import Cert "cert";

module {

  public type Content = C.Content;

  public type Certificate = Cert.Certificate;

  public type Key = T.Key;

  public type Value = T.CborValue;

  public type Map = T.CborMap;

  public type Record = T.CborRecord;

  public let { Content } = C;

  public let Certificate = Cert;

  public let { unwrapNat64; unwrapBytes; unwrapText } = V;

  public let { unwrapRecord; unwrapMap; unwrapArray } = V;

};