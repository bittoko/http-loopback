import Buffer "mo:base/Buffer";
import Ecdsa "../../../ECDSA/src";
import { Content } "../Content";
import { init } "mo:base/Array";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import { toBlob = principalToBlob } "mo:base/Principal";
import T "types";

module {

  type Identity = Ecdsa.Identity;

  type AsyncReturn<T> = Ecdsa.AsyncReturn<T>;

  public let IC_REQUEST_DOMAIN_SEPERATOR : Blob = "\0A\69\63\2D\72\65\71\75\65\73\74"; // "\0Aic-request";

  func to_request_id(hash: T.Hash): T.RequestId { toHex( Blob.toArray( hash ) ) };

  public func sign_request(identity: Identity, request: T.Request): async* AsyncReturn<(T.RequestId, T.Cbor)> {
    let content = Content( map_request( request ) );
    let content_hash : T.Hash = content.hash();
    let request_id : T.RequestId = to_request_id( content_hash );
    let message_id : Blob = to_message_id( content_hash );
    switch( await* identity.sign(message_id) ){
      case( #err msg ) #err(msg);
      case( #ok sig ){
        let envelope : T.Map = [
          ("content", #map( content.export_map()) ),
          ("sender_pubkey", #blob( identity.public_key ) ),
          ("sender_sig", #blob( sig ) ),
        ];
        let cbor : T.Cbor = Content(envelope).export_cbor();
        (request_id, cbor)
      }
    }
  };

  func to_message_id(hash: T.Hash): Blob {
    var index : Nat = 0;
    let message = msg.vals();
    let domain = IC_REQUEST_DOMAIN_SEPERATOR.vals();
    let bytearray : [var Nat8] = init<Nat8>(43, 0x00);
    for ( byte in domain ){ bytearray[index] := byte; index += 1 };
    for ( byte in message ){ bytearray[index] := byte; index += 1 };
    Blob.fromArrayMut( bytearray );
  };

  func map_request(req: T.Request): T.Map {
    let map_buffer = Buffer.Buffer<T.MapEntry>(4);
    map_buffer.add(("sender", Content.wrapBlob(req.sender)));
    map_buffer.add(("ingress_expiry", Content.wrapNat(req.ingress_expiry)));
    switch( req.request ){
      case( #update_method params ){
        map_buffer.add(("request_type", Content.wrapText("call")));
        map_buffer.add(("canister_id", Content.wrapBlob(params.canister_id)));
        map_buffer.add(("method_name", Content.wrapText(params.method_name)));
        map_buffer.add(("arg", Content.wrapBlob(params.arg)));
      };
      case( #query_method params ){
        map_buffer.add(("request_type", Content.wrapText("query")));
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

  /// The following code was sourced from gekctek's xtended-numbers library
  ///
  /// https://github.com/edjCase/motoko_numbers/blob/main/src/Util.mo
  ///
  /// The code has been modified to fit this use case
  ///
  func toHex(array : [Nat8]) : Text {
    Array.foldLeft<Nat8, Text>(array, "", func (accum, w8) {
      if (accum == "") "0x" # accum # encodeW8(w8)
      else accum # encodeW8(w8)
    });
  };

  let base : Nat8 = 0x10; 

  let symbols = [
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
  ];
  /**
  * Encode an unsigned 8-bit integer in hexadecimal format.
  */
  func encodeW8(w8 : Nat8) : Text {
    let c1 = symbols[Nat8.toNat(w8 / base)];
    let c2 = symbols[Nat8.toNat(w8 % base)];
    Char.toText(c1) # Char.toText(c2);
  };

};