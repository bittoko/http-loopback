import { Nonce = { Nonce }; Fees = { Fees } } "../../../utilities/src";
import { encodeUtf8; decodeUtf8 } "mo:base/Text";
import { Identity } "../../../ECDSA/src";
import Principal "mo:base/Principal";
import { sign_request } "utils";
import Time "mo:base/Time";
import Client "../Client";

import T "types";

module {

  public class Agent(state: T.State, client : T.Client, identity: T.Identity) = {

    let nonce_factory = Nonce.Nonce( state.agent_nonce );

    public func query_method(req: T.CallRequest) : async* T.Response {
      let request : T.Request = {
        sender = Principal.toBlob( identity.principal );
        ingress_expiry = state.agent_ingress_expiry;
        nonce = ?nonce_factory.next_blob();
        request = #query_method( req );
      };
      switch( await* sign_request(identity, request) ){
        case( #err msg ) #err(msg);
        case( #ok (_, payload) ){
          let c_request : Client.Request = {
            max_response_bytes = req.max_response_bytes;
            canister_id = req.canister_id;
            data = payload;
          };
          switch( await* client.query_endpoint( req ) ){
            case( #err msg ) #err(msg);
            case( #ok cbor ){
              let content = Content([]);
              switch( content.import_cbor( cbor ) ){
                case( #err msg ) #err(msg);
                case( #ok ) #ok( content );
              }
            }
          }
        }
      } 
    };

    public func update_method(req: T.CallRequest) : async* T.Response {
      var attempts : Nat = 0;
      let expiration : Int = Time.now() + state.agent_ingress_expiry;
      func read_state(reqid: T.RequestId): async* Client.Response {
        if ( Time.now() >= expiration ) return #err( #expired( reqid ) );
        attemps += 1;
        switch( await* sign_and_send( #read_state( read_req ) ) ){
          case( #err msg ) #err(msg);
          case( #ok cbor ){
            let content = Content([]);
            content.import_cbor( cbor );
            #ok( content )
          };
        }
      };
      switch( await* sign_and_send(#update_method( req ) ) ){
        case( #err msg ) #err(msg);
        case( #ok request_id ){
          let read_req : T.ReadRequest = {
            paths = [[ encodeUtf8("request_status"), Blob.fromArray(request_id) ]]
          };
          
          switch( await* sign_and_send( #read_state( read_req ) ) ){
            case( #err msg ) #err(msg);
            case( #ok cbor ){
              let content = Content([]);
              content.import_cbor( cbor );
              #ok( content )
            }
          };
        }
      };
    };

    func read_state(attempts: Nat, exp: Int, req_id: T.RequestId): async* (Nat, Client.Response) {
      if ( Time.now() >= exp ) return #err( #expired( req_id ) );
      switch( await* sign_and_send( #read_state( read_req ) ) ){
        case( #err msg ) #err(msg);
        case( #ok cbor ){
          let content = Content([]);
          content.import_cbor( cbor );
          
        };
      }
    };

    func sign_and_send(request_type: T.RequestType): async* T.Client.Response {
      var is_update : Bool = false;
      let request : T.Request = {
        sender = Principal.toBlob( identity.principal );
        ingress_expiry = state.agent_ingress_expiry;
        nonce = ?nonce_factory.next_blob();
        request = request_type;
      };
      switch( await* sign_request(identity, request) ){
        case( #err msg ) #err(msg);
        case( #ok (req_id, payload) ){
          let client_request : Client.Request = {
            max_response_bytes = req.max_response_bytes;
            canister_id = req.canister_id;
            data = payload;
          };
          let client_endpoint = switch( request_type ){
            case( #read_state _ ) client.read_state_endpoint;
            case( #query_method _ ) client.query_endpoint;
            case( #update_method _ ) {
              client.call_endpoint;
              is_update := true
            };
          };
          switch( await* client_endpoint( client_request ) ){
            case( #err msg ) #err(msg);
            case( #ok bytearray ){
              if is_update #ok( Blob.toArray( encodeUtf8( req_id ) ) )
              else #ok( bytearray )
            }
          }
        }
      }
    };

  };



};