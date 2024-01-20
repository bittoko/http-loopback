import { Fees } "../../../utilities/src";
import Cbor "mo:cbor/Value";

module {

  public type URL = Text;

  public type Response = { #ok: Cbor.Value; #err: Error };

  public type ReturnFee = Fees.Return;

  public type Error = {
    #fee_not_defined: Text;
    #rejected: Text;
    #missing: Text;
    #invalid: Text;
    #trapped: Text;
    #expired: Text;
  };

  public type Request = {
    data: Cbor.Value;
    canister_id: Text;
    max_response_bytes: ?Nat64;
  };
  
};