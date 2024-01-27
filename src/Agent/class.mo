import { Nonce = { Nonce }; Fees = { Fees } } "mo:utilities";
import { getContentMap; getHashTree; getBytes } "../Cbor";
import { fromArray = blobFromArray } "mo:base/Blob";
import { encodeUtf8; decodeUtf8 } "mo:base/Text";
import { Identity } "mo:ECDSA";
import Principal "mo:base/Principal";
import { sign_request } "utils";
import Time "mo:base/Time";
import Client "../Client";
import T "types";

module {

  type Attempts = { var count : Nat };

  public class Agent(state: T.State, client : T.Client, identity: T.Identity) = {

    let nonce_factory = Nonce.Nonce( state.agent_nonce );

    public func query_method(req: T.CallRequest) : async* T.Response {
      switch( await* sign_and_send(#query_method(req)) ){
        case( #err msg ) #err(msg);
        case( #ok(_, response) ){
          switch( response.get<[Nat8]>("reply", getBytes) ){
            case( ?candid ) #ok( blobFromArray( candid ) );
            case _ #err(#missing("response field: 'reply'"))
          }
        }
      }
    };

    public func update_method(req: T.CallRequest) : async* T.Response {
      let attempts : Attempts = { count = 0 };
      let expiration : Int = Time.now() + state.agent_ingress_expiry;
      switch( await* sign_and_send(#call_method(req)) ){
        case( #err msg ) return #err(msg);
        case( #ok(req_id, _) ){
          while true {
            switch( await* request_status(attempts, expiration, req_id) ){
              case( #err msg ) switch( msg ){ case(#expired) return #err(#expired); case _ () };
              case( #ok (status, hashtree) ){
                if ( status == "replied" ){
                  state.agent_read_attempts := attempts.count;
                  let path = [encodeUtf8("request_status"), req_id, encodeUtf8("reply")];
                  switch( hashtree.lookup( path ) ){
                    case null return #err(#fatal("Agent.update_method(): response lookup failed"));
                    case( ?candid ) return #ok( blobFromArray( candid ) )
                  }
                }
                else if ( status == "rejected "){
                  state.agent_read_attempts := attempts.count;
                  switch( lookup([encodeUtf8("request_status"), req_id, encodeUtf8("reject_message")], cert) ){
                    case null return #err(#fatal("Agent.update_method(): response lookup failed"));
                    case( ?rejection ){
                      let ?reject_message = decodeUtf8(rejection) else { return #err(#fatal("Failed to decode response")) };
                      return #err(#rejected(reject_message))
                    }
                  }
                }
              }
            }
          }
        }
      }
    };

    func request_status(attempts: Attempts, exp: Int, req_id: T.RequestId): async* T.Status {
      if ( Time.now() >= exp ) return #err( #expired );
      switch( await* read_state( req_id ) ){
        case( #err msg ) { attempts.count += 1; #err(msg) };
        case( #ok certificate ) {
          attempts.count += 1;
          let path = [encodeUtf8("request_status"), req_id, encodeUtf8("status")];
          let ?hashtree = certificate.get<T.HashTree>("tree", getHashTree) else { return #err(#missing("hashtree")) };
          let ?encoded_status = hashtree.lookup( path ) else { return #err(#missing("request status")) };
          let ?status = decodeUtf8(encoded_status) else { return #err(#fatal("Agent.request_status(): Failed to decode request status")) };
          #ok((status, hashtree))
        }
      }
    };

    func read_state(req_id: T.RequestId): async* T.ReadResponse {
      let read_req : T.ReadRequest = {paths = [[ encodeUtf8("request_status"), req_id ]]};
      switch( await* sign_and_send( #read_state( read_req ) ) ){
        case( #err msg ) { attempts.count += 1; #err(msg) };
        case( #ok (_, content) ) {
          attempts.count += 1;
          switch( content.get<T.Content>("certificate", getContentMap) ){
            case( ?certificate ) #ok( certificate );
            case null #err(#missing("certificate"));
          }
        }
      }
    };

    func sign_and_send(rtype: T.RequestType): async* T.ClientResponse {

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
            case( #ok content ) #ok(reqid, content)
          }

        }
      } 
    };

  };



};