import { Fees } "mo:utilities";
import Cbor "../Cbor";

module {

  public type URL = Text;

  public type ContentMap = Cbor.ContentMap; 

  public type Response = { #ok: ContentMap; #err: Error };

  public type ReturnFee = Fees.Return;

  public type Error = {
    #fee_not_defined: Text;
    #rejected: Text;
    #missing: Text;
    #invalid: Text;
    #trapped: Text;
    #expired;
    #fatal: Text;
  };

  public type Request = {
    envelope: ContentMap;
    canister_id: Text;
    max_response_bytes: ?Nat64;
  };
  
};