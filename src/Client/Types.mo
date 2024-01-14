import { Fees } "../../../utilities/src";

module {

  public type URL = Text;

  public type Candid = Blob;

  public type Response = { #ok: Blob; #err: Error };

  public type Error = {
    #sys_fatal: Text;
    #malformed_request: Text;
    #destination_invalid: Text;
    #sys_transient: Text;
    #canister_reject: Text;
    #canister_error: Text;
    #fee_not_defined: Text;
    #invalidValue: Text;
    #missing: Text;
    #invalid: Text;
    #invalid_status: Nat;
    #invalid_reject_code: Nat;
    #unexpectedEndOfBytes;
    #unexpectedBreak;
    #server_error;
  };

  public type Request = {
    data: [Nat8];
    canister_id: Text;
    max_response_bytes: ?Nat64;
  };
  
};