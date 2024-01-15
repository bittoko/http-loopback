import Buffer "mo:base/Buffer";
import Ecdsa "../../../ECDSA/src";
import Content "../Content";
import { init } "mo:base/Array";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import { toBlob = principalToBlob } "mo:base/Principal";
import T "types";

module {

  type Identity = Ecdsa.Identity;

  public let IC_REQUEST_DOMAIN_SEPERATOR : Blob = "\0A\69\63\2D\72\65\71\75\65\73\74"; // "\0Aic-request";

  public func sign_request(request: T.Request, identity: Identity): async* (T.RequestId, T.Cbor) {
    let content = Content.Content( map_request( request ) );
    let content_hash : T.Hash = content.hash();
    let request_id : T.RequestId = to_request_id( content_hash );
    let message_id : Blob = to_message_id( content_hash );
    switch( await* identity.sign(message_id) ){
      
    }
  };

  public func to_request_id(hash: T.Hash): T.RequestId {

  };

  public func to_message_id(hash: T.Hash): Blob {
    var index : Nat = 0;
    let message = msg.vals();
    let domain = IC_REQUEST_DOMAIN_SEPERATOR.vals();
    let bytearray : [var Nat8] = init<Nat8>(43, 0x00);
    for ( byte in domain ){ bytearray[index] := byte; index += 1 };
    for ( byte in message ){ bytearray[index] := byte; index += 1 };
    Blob.fromArrayMut( bytearray );
  };

  public func map_call_request(type_: {#call; #query_}, req : T.CallRequest, attr: Attributes): T.Map {
    map_request({
      sender = principalToBlob( attr.principal );
      ingress_expiry = Time.now() + attr.ingress_expiry;
      nonce = ?attr.nonce;
      request = #call_method({
        request_type = type_;
        method_name = req.method_name;
        canister_id = req.canister_id;
        arg = req.arg;
      })
    })
  };

  public func map_read_request(req: T.ReadRequest, attr: Attributes): T.Map {
    map_request({
      sender = principalToBlob( attr.principal );
      ingress_expiry = Time.now() + attr.ingress_expiry;
      nonce = ?attr.nonce;
      request = req;
    })
  };

  func map_request(req: T.Request): T.Map {
    let map_buffer = Buffer.Buffer<T.MapEntry>(4);
    map_buffer.add(("sender", Content.wrapBlob(req.sender)));
    map_buffer.add(("ingress_expiry", Content.wrapNat(req.ingress_expiry)));
    switch( req.request ){
      case( #call_method params ){
        let request_type = switch( params.request_type ){case(#call)"call";case(#query_)"query"};
        map_buffer.add(("request_type", Content.wrapText(request_type)));
        map_buffer.add(("canister_id", Content.wrapBlob(params.canister_id)));
        map_buffer.add(("method_name", Content.wrapText(params.method_name)));
        map_buffer.add(("arg", Content.wrapBlob(params.arg)));
      };
      case( #read_state params ){
        map_buffer.add(("paths",
          Content.wrapArray<[Blob]>(params.paths, func(state_path) =
            Content.wrapArray<Blob>(state_path, Content.wrapBlob)
        )));
      };
    };
    switch( req.nonce ){
      case( ?nonce ) map_buffer.add(("nonce", Content.wrapBlob(nonce)));
      case null ();
    };
    Buffer.toArray<T.MapEntry>( map_buffer )
  };


};