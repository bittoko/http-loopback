import Client "../Client";
import ECDSA "mo:ECDSA";
import Cbor "../Cbor";
import State "state";
import Text "mo:base/Text";
import Hash "mo:rep-indy-hash";

module {

  public type Client = Client.Client;

  public type Identity = ECDSA.Identity;
  
  public type RequestId = Blob;

  public type State = State.State;

  public type Candid = Blob;

  public type HashTree = Cbor.HashTree;

  public type ContentMap = Cbor.ContentMap;

  public type Certificate = ContentMap;

  public type Signature = Blob;

  public type Paths = [[Blob]];

  public type Response = { #ok: Candid; #err: Client.Error };

  public type ClientResponse = { #ok: (RequstId, ContentMap); #err: Client.Error };

  public type Status = { #ok : (Text, HashTree); #err : Client.Error };

  public type ReadResponse = { #ok : Certificate; #err : Client.Error };

  public type ReadRequest = { paths : Paths };

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