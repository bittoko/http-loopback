import Client "../Client";
import Content "../Content";
import State "state";
import Text "mo:base/Text";

module {

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

  public type CallRequest = { canister_id: Text; method_name: Text; arg: Blob };

  public type ReadRequest = { paths : Paths };

  public type Request = {
    sender: Blob;
    ingress_expiry: Nat;
    nonce: ?Blob;
    request: {
      #read_state: ReadRequest;
      #call_method: {
        request_type: { #call; #query_ };
        canister_id: Blob;
        method_name: Text;
        arg: Blob;
      }
    }
  };

};