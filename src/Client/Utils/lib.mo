import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import { tabulate } "mo:base/Array";
import { hash_from_map = fromMap } "Hash";
import { cbor_from_map = fromMap } "CBOR";
import T "Types";

module {

  public type Hash = T.Hash;

  public type CBOR = T.CBOR;

  public type Paths = T.Paths;

  public type ContentMap = T.ContentMap;

  public type ContentForm = T.ContentForm;

  public func hash_content = hash_from_map;

  public let wrap_content = cbor_from_map;

  public func map_content_form(content: ContentForm): ContentMap {
    let content_buffer = Buffer.Buffer<T.Field>(8);
    content_buffer.add( ("nonce", #blob(content.nonce)) );
    content_buffer.add( ("sender", #blob(content.sender)) );
    content_buffer.add( ("ingress_expiry", #nat(content.ingress_expiry)) );
    switch( content.request ){
      case( #read_state request ){
        content_buffer.add( ("request_type", #text("read_state")) );
        content_buffer.add( ("paths", #paths(request.paths)) );
      };
      case( #call_method request ){
        content_buffer.add( ("request_type", #text(request.request_type)) );
        content_buffer.add( ("canister_id", #blob(request.canister_id)) );
        content_buffer.add( ("method_name", #text(request.method_name)) );
        content_buffer.add( ("arg", #blob(request.arg)) );
      }
    };
    Buffer.toArray<T.AccountIdentifierField>( content_buffer );
  };

  public func concatenate(b0: Blob, b1: Blob): Blob {
    let prefix_size: Nat = b0.size();
    let combined_size: Nat = prefix_size + b1.size();
    let a0: [Nat8] = Blob.toArray(b0);
    let a1: [Nat8] = Blob.toArray(b1);
    Blob.fromArray(tabulate<Nat8>(
      combined_size, func(x: Nat): Nat8 {
        if (x < prefix_size ) a0[x] else a1[x - prefix_size]; 
      }
    ))
  };

};