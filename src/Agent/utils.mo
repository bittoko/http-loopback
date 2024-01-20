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
    let request_id : T.RequestId = toHex( hash );
    let message_id : Blob = to_message_id( hash );
    switch( await* identity.sign(message_id) ){
      case( #err msg ) #err(msg);
      case( #ok sig ){
        let envelope = #majorType6{
          tag = 55799;
          value = #majorType5([
            (#majorType3("content"), wrap_content(request)),
            (#majorType3("sender_pubkey"), #majorType2(Blob.toArray(identity.public_key))),
            (#majorType3("sender_sig", #majorType2(Blob.toArray(sig)))),
          ])
        };
        switch( Cbor.encode( envelope ) ){
          case( #ok cbor ) (request_id, cbor);
          case( #err msg ) #err(msg);
        }
      }
    }
  };

  func to_message_id(hash: [Nat8]): Blob {
    Blob.toArray(
      tabulate<Nat8>(43, func(i) = 
        if ( i < 11 ) IC_REQUEST_DOMAIN_SEPERATOR[i]
        else hash[i - 11]
      )
    )
  };

  func wrap_content(req: T.Request): T.CborMap {
    let buffer = Buffer.Buffer<T.CborEntry>(4);
    buffer.add(( #majorType3("sender"), #majorType2(Blob.toArray(req.sender)) ));
    buffer.add(( #majorType3("ingress_expiry"), #majorTyp0(req.ingress_expiry) ));
    switch( req.nonce ){
      case( ?nonce ) buffer.add(( #majorType3("nonce"), #majorType2(Blob.toArray(nonce)) ));
      case null ();
    };
    switch( req.request ){
      case( #update_method params ){
        buffer.add(( #majorType3("request_type"), #majorType3("call") ));
        buffer.add(( #majorType3("canister_id"), #majorType3(Blob.toArray(params.canister_id)) ));
        buffer.add(( #majorType3("method_name"), #majorType3(params.method_name) ));
        buffer.add(( #majorType3("arg"), #majorType2(Blob.toArray(params.arg)) ));
      };
      case( #query_method params ){
        buffer.add(( #majorType3("request_type"), #majorType3("query") ));
        buffer.add(( #majorType3("canister_id"), #majorType3(Blob.toArray(params.canister_id)) ));
        buffer.add(( #majorType3("method_name"), #majorType3(params.method_name) ));
        buffer.add(( #majorType3("arg"), #majorType2(Blob.toArray(params.arg)) ));
      };
      case( #read_state params ){
        buffer.add(( #majorType3("paths"),
          #majorType4( mapEntries<[Blob], T.CborArray>(params.path, func(state_path, _): T.CborArray {
            #majorType4( mapEntries<Blob, T.CborBytes>(state_path, func(path_label, _): T.CborBytes {
              #majorType2( Blob.toArray(path_label) )
            }))
          }))
        ))
      }};
    #majorType5( Buffer.toArray<T.CborEntry>( buffer ) );
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