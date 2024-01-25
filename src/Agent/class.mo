import { Nonce = { Nonce }; Fees = { Fees } } "mo:utilities";
import { encodeUtf8; decodeUtf8 } "mo:base/Text";
import { Identity } "mo:ECDSA";
import Principal "mo:base/Principal";
import { sign_request } "utils";
import { lookup } "../Content";
import Time "mo:base/Time";
import Client "../Client";

import T "types";

module {

  type Attempts = { var count : Nat };

  public class Agent(state: T.State, client : T.Client, identity: T.Identity) = {

    let nonce_factory = Nonce.Nonce( state.agent_nonce );

    public func query_method(req: T.CallRequest) : async* T.Response {
      let (_, res) = await* sign_and_send(#query_method(req));
      res
    };

    public func update_method(req: T.CallRequest) : async* T.Response {
      var polling : Bool = true;
      var response : Candid = "";
      let attempts : Attmepts = { count = 0 };
      let expiration : Int = Time.now() + state.agent_ingress_expiry;
      let (req_id, res) = await* sign_and_send(#call_method(req));
      switch( res ){
        case( #err msg ) return #err(msg);
        case( #ok _ ) while polling {
          switch( await* request_status(attempts, expiration, req_id) ){
            case( #ok (status, cert) ){
              if ( status == "replied" ){
                polling := false;
                state.agent_read_attempts := attempts.count;
                switch( lookup([encodeUtf8("request_status"), req_id, encodeUtf8("reply")], cert) ){
                  case null #err(#fatal("Agent.update_method(): response lookup failed"));
                  case( ?candid ) response := candid;
                }
              }
              else if ( status == "rejected "){
                polling := false;
                state.agent_read_attempts := attempts.count;
                switch( lookup([encodeUtf8("request_status"), req_id, encodeUtf8("reject_message")], cert) ){
                  case null return #err(#fatal("Agent.update_method(): response lookup failed"));
                  case( ?rejection ){
                    let ?reject_message = decodeUtf8(rejection) else { return #err(#fatal("Failed to decode response")) };
                    return #err(#rejected(reject_message))
                  }
              }}};
            case( #err msg ) switch( msg ){
              case(#expired) return #err(#expired);
              case _ ()
            };
          }
        }
      };
      #ok( response )
    };

    func request_status(attempts: Attempts, exp: Int, req_id: T.RequestId): async* T.Status {
      if ( Time.now() >= exp ) return #err( #expired );
      switch( await* read_state( req_id ) ){
        case( #err msg ) { attempts.count += 1; #err(msg) };
        case( #ok certificate ) {
          attempts.count += 1;
          let ?encoded_status = lookup([ encodeUtf8("request_status"), req_id, encodeUtf8("status")], cert);
          let ?status = decodeUtf8(encoded_status) else { return #err(#fatal("Agent.request_status(): Failed to decode request status")) };
          #ok((status, certificate))
        }
      }
    };

    func read_state(req_id: T.RequestId): async* T.Response {
      let read_req : T.ReadRequest = {paths = [[ encodeUtf8("request_status"), req_id ]]};
      switch( await* sign_and_send( #read_state( read_req ) ) ){
        case( #err msg ) { attempts.count += 1; #err(msg) };
        case( #ok content ) {
          attempts.count += 1;
          switch( content.get<T.Map>("certificate", unwrapMap) ){
            case null #err(#missing("certificate"));
            case( ?map ){
              let certificate = Content();
              certificate.load( map );
              #ok( certificate )
            }
          }
        }
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