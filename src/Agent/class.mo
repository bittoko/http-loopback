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
      let (_, res) = await* sign_and_send(#query_method(req));
      res
    };

    public func update_method(req: T.CallRequest) : async* T.Response {
      var attempts : Nat = 0;
      let expiration : Int = Time.now() + state.agent_ingress_expiry;

      // PICKUP HERE - NEED TO COME UP WITH A POLLING FUNCTION
      let (reqid, res) = await* sign_and_send(#call_method(req));
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

    func sign_and_send(rtype: T.RequestType): async* (T.RequestId, T.ClientResponse) {

     let content = Content();

      let client_endpoint = switch( request_type ){
        case( #read_state _ ) client.read_state_endpoint;
        case( #query_method _ ) client.query_endpoint;
        case( #update_method _ ) client.call_endpoint;
      };

      switch(
        await* sign_request(
          identity, 
          {
            sender = Principal.toBlob( identity.principal );
            ingress_expiry = state.agent_ingress_expiry;
            nonce = ?nonce_factory.next_blob();
            request = rtype;
          }
        )
      ){
        case( #err msg ) #err(msg);
        case( #ok (reqid, envelope) ){

          switch( 
            await* client_endpoint(
              {
                max_response_bytes = req.max_response_bytes;
                canister_id = req.canister_id;
                envelope;
              }
            )
          ){
            case( #err msg ) #err(msg);
            case( #ok map ){
              content.load( map );
              (reqid, #ok(content))
            }
          }

        }
      } 
    };

  };



};