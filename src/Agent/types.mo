import Client "../Client";
import Content "Content";
import State "state";

module {

  public type ReqId = Text;

  public type State = State.State;

  public type Map = Content.Map;

  public type Content = Content.Content;

  public type MapEntry = Content.Entry;

  public type Hash = Content.Hash;

  public type Cbor = Content.Cbor;

  public type Paths = [[Blob]];

  public type Response = { #ok: Content; #err: Client.Error };

  public type Request = {
    sender: Blob;
    ingress_expiry: Nat;
    nonce: ?Blob;
    request: {
      #read_state: {paths: Paths};
      #call_method: {
        request_type: { #call; #query_ };
        canister_id: Blob;
        method_name: Text;
        arg: Blob;
      }
    }
  };

};