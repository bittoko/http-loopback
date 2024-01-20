import Errors "mo:cbor/Errors";
import Cbor "mo:cbor/Value";

module {

  public type Key = Text;

  public type Entry = (Key, CborValue);

  public type CborValue = Cbor.Value;

  public type CborMap = [CborEntry];
  
  public type CborArray = [CborValue];
  
  public type CborEntry = (CborValue, CborValue);

};