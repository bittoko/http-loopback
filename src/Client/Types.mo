import { Fees } "../../../utilities/src";
import Content "../Content";
import Cbor "mo:cbor/Value";

module {

  public type URL = Text;

  public type ContentMap = Content.Map; 

  public type Response = { #ok: ContentMap; #err: Error };

  public type ReturnFee = Fees.Return;

  public type Error = {
    #fee_not_defined: Text;
    #rejected: Text;
    #missing: Text;
    #invalid: Text;
    #trapped: Text;
    #expired: Text;
    #fatal: Text;
  };

  public type Request = {
    envelope: ContentMap;
    canister_id: Text;
    max_response_bytes: ?Nat64;
  };
  
};