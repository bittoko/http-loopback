import Errors "mo:cbor/Errors";

module {

  public type Cbor = [Nat8];

  public type Hash = Blob;

  public type DecodingError = Errors.DecodingError;
  
  public type EncodingError = Errors.EncodingError;

  public type Return<X,Y> = { #ok: X; #err: Y };

  public type Map = [Entry];

  public type Entry = (Key, Value);

  public type Array = [Value];

  public type Key = Text;

  public type Value = {
    #map: Map;
    #nat: Nat;
    #blob: Blob;
    #text: Text;
    #array: [Value];
  };

  public type CborMap = { #majorType5 : [CborEntry]};

  public type CborArray = { #majorType4 : [CborValue] };

  public type CborEntry = (CborText, CborValue);

  public type CborText = { #majorType3 : Text };

  public type CborValue = {
    #majorType0 : Nat64;
    #majorType2 : [Nat8];
    #majorType3 : Text;
    #majorType5 : [CborEntry];
    #majorType4 : [CborValue];
  };

};