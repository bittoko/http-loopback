import Buffer "mo:base/Buffer";
import Ecdsa "../../../ECDSA/src";
import { Content } "../Content";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Cbor "mo:cbor/Encoder";
import { init; mapEntries; tabulate } "mo:base/Array";
import { toBlob = principalToBlob } "mo:base/Principal";
import Hash "mo:rep-indy-hash";
import T "types";

module {

  type Identity = Ecdsa.Identity;

  type AsyncReturn<T> = Ecdsa.AsyncReturn<T>;

  public let IC_REQUEST_DOMAIN_SEPERATOR : [Nat8] = [10, 105, 99, 45, 114, 101, 113, 117, 101, 115, 116]; // "\0Aic-request";

  public func sign_request(identity: Identity, request: T.Request): async* AsyncReturn<(T.RequestId, T.Cbor)> {
    let hash : [Nat8] = hash_content( request );
    let request_id : T.RequestId = to_request_id( hash );
    let message_id : Blob = to_message_id( hash );
    switch( await* identity.sign(message_id) ){
      case( #err msg ) #err(msg);
      case( #ok sig ){
        let envelope = Content();
        envelope.set( "content", #majorType5(map_content( request )) );
        envelope.set( "sender_pubkey", #majorType2(Blob.toArray(identity.public_key)) );
        envelope.set( "sender_sig", #majorType2(Blob.toArray(sig)) );
        (request_id, envelope.dump());
      }
    }
  };

  func to_request_id(hash: [Nat8]): Blob = Blob.fromArray(hash);

  func to_message_id(hash: [Nat8]): Blob {
    Blob.toArray(
      tabulate<Nat8>(43, func(i) = 
        if ( i < 11 ) IC_REQUEST_DOMAIN_SEPERATOR[i]
        else hash[i - 11]
      )
    )
  };

  func map_content(req: T.Request): T.Map {
    let content = Content();
    content.set( "sender", #majorType2(Blob.toArray(req.sender)) );
    content.set( "ingress_expiry", #majorTyp0(req.ingress_expiry) );
    switch( req.nonce ){
      case( ?nonce ) content.set( "nonce", #majorType2(Blob.toArray(nonce)) );
      case null ();
    };
    switch( req.request ){
      case( #update_method params ){
        content.set( "request_type", #majorType3("call") );
        content.set( "canister_id", #majorType3(Blob.toArray(params.canister_id)) );
        content.set( "method_name", #majorType3(params.method_name) );
        content.set( "arg", #majorType2(Blob.toArray(params.arg)) );
      };
      case( #query_method params ){
        content.set( "request_type", #majorType3("query") );
        content.set( "canister_id", #majorType3(Blob.toArray(params.canister_id)) );
        content.set( "method_name", #majorType3(params.method_name) );
        content.set( "arg", #majorType2(Blob.toArray(params.arg)) );
      };
      case( #read_state params ){
        content.set( "paths",
          #majorType4( mapEntries<[Blob], T.CborArray>(params.path, func(state_path, _): T.CborArray {
            #majorType4( mapEntries<Blob, T.CborBytes>(state_path, func(path_label, _): T.CborBytes {
              #majorType2( Blob.toArray(path_label) )
            }))
          }))
        )
      }};
    content.dump()
  };

  func hash_content(req: T.Request): T.Hash {
    let buffer = Buffer.Buffer<(Text, T.Value)>(4);
    buffer.add( ("sender", #Blob(req.sender)) );
    buffer.add( ("ingress_expiry", #Nat(Nat64.toNat(req.ingress_expiry))) );
    switch( req.nonce ){
      case( ?nonce ) buffer.add(("nonce", #Blob(nonce)));
      case null ();
    };
    switch( req.request ){
      case( #update_method params ){
        buffer.add(("request_type", #Text("call")));
        buffer.add(("canister_id", #Blob(params.canister_id)));
        buffer.add(("method_name", #Text(params.method_name)));
        buffer.add(("arg", #Blob(params.arg)));
      };
      case( #query_method params ){
        buffer.add(("request_type", #Text("query")));
        buffer.add(("canister_id", #Blob(params.canister_id)));
        buffer.add(("method_name", #Text(params.method_name)));
        buffer.add(("arg", #Blob(params.arg)));
      };
      case( #read_state params ){
        buffer.add(("paths",
          mapEntries<[Blob], T.Value>(params.paths, func(state_path, _): T.Value {
            mapEntries<Blob, T.Value>(state_path, func(path_label, _): T.Value {
              #Blob(path_label)
            })
          })
        ))
      }};
    Hash.hash_val( #Map( Buffer.toArray<(Text, T.Value)>( buffer ) ) )
  };

};