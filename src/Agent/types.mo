import Client "../Client";
import ECDSA "../../../ECDSA/src";
import Content "../Content";
import State "state";
import Text "mo:base/Text";
import Cbor "mo:cbor/Value";
import Hash "mo:rep-indy-hash";

module {

  public type Identity = ECDSA.Identity;
  
  public type Value = Hash.Value;
  
  public type RequestId = Text;

  public type State = State.State;

  public type Map = Content.Map;

  public type Content = Content.Content;

  public type MapEntry = Content.Entry;

  public type Signature = Blob;

  public type Hash = Content.Hash;

  public type Cbor = Content.Cbor;

  public type Paths = [[Blob]];

  public type Response = { #ok: Content; #err: Client.Error };

  public type ReadRequest = { paths : Paths };

  public type CborValue = Cbor.Value;

  public type CborMap = { #majorType5 : [CborEntry]};

  public type CborArray = { #majorType4 : [CborValue] };

  public type CborBytes = { #majorType2 : [Nat8] };
  
  public type CborEntry = (CborText, CborValue);

  public type CborText = { #majorType3 : Text };

  public type CallRequest = {
    max_response_bytes: ?Nat64;
    canister_id: Text;
    method_name: Text;
    arg: Blob
  };

  public type RequestType = {
    #read_state: ReadRequest;
    #query_method: CallRequest;
    #update_method: CallRequest;
  };

  public type Request = {
    request: RequestType;
    ingress_expiry: Nat;
    sender: Blob;
    nonce: ?Blob;
  };

};