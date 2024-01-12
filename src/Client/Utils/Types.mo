import Value "mo:cbor/Value";

module {

  public type Hash = Blob;

  public type CBOR = {
    #majorType0: Nat64; // 0 -> 2^64 - 1
    #majorType2 : [Nat8];
    #majorType3: Text;
    #majorType4: [CBOR];
    #majorType5: [(CBOR, CBOR)];
  };

  public type ContentMap = [Field];

  public type Paths = [[Blob]];
  
  public type Field = (Text, {#map: ContentMap; #nat: Nat; #blob: Blob; #text: Text; #paths: Paths});

  public type ContentForm = {
    sender: Blob;
    ingress_expiry: Nat;
    nonce: Blob;
    request: {
      #read_state: {paths: Paths};
      #call_method: {
        request_type: Text;
        canister_id: Blob;
        method_name: Text;
        arg: Blob;
      }
    }
  };

};