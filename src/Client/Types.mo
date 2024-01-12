

module {

  public type URL = Text;

  public type Candid = Blob;

  public type Request = {
    payload: Blob;
    canister_id: Text;
    addCycles: (Nat64) -> Bool;
  };

  public type Response<T> = { #ok: T; #err: Error };

  public type Error = {
    #malformed;
    #rejected: Text;
  };
  
};