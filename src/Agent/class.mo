import { fromArray = blobFromArray } "mo:base/Blob";
import { encodeUtf8; decodeUtf8 } "mo:base/Text";
import Principal "mo:base/Principal";
import { sign_request } "utils";
import { Nonce } "mo:utilities";
import Time "mo:base/Time";
import { abs } "mo:base/Int";
import Cbor "../Cbor";
import T "types";

module {

  type Attempts = { var count : Nat };

  public class Agent(state: T.State, client : T.Client, identity: T.Identity) = {

    let nonce_factory = Nonce.Nonce( state.agent_nonce );

    public func query_method(req: T.CallRequest) : async* T.Response {
      switch( await* sign_and_send(#query_method(req)) ){
        case( #err msg ) #err(msg);
        case( #ok(_, cbor) ){
          let response = Cbor.load( cbor );
          switch( response.get<[Nat8]>("reply", Cbor.getBytearray) ){
            case( ?candid ) #ok( blobFromArray( candid ) );
            case _ #err(#missing("response field: 'reply'"))
          }
        }
      }
    };

    public func update_method(req: T.CallRequest) : async* T.Response {
      let attempts : Attempts = { var count = 0 };
      let expiration : Int = Time.now() + state.agent_ingress_expiry;
      switch( await* sign_and_send(#update_method(req)) ){
        case( #err msg ) return #err(msg);
        case( #ok(req_id, _) ){
          while true {
            switch( await* request_status(attempts, expiration, req_id, req.canister_id, req.max_response_bytes) ){
              case( #err msg ) switch( msg ){ case(#expired) return #err(#expired); case _ () };
              case( #ok (status, cbor) ){
                let hashtree = Cbor.HashTree( cbor );
                if ( status == "replied" ){
                  state.agent_read_attempts := attempts.count;
                  let path = [encodeUtf8("request_status"), req_id, encodeUtf8("reply")];
                  switch( hashtree.lookup( path ) ){
                    case null return #err(#fatal("Agent.update_method(): response lookup failed"));
                    case( ?candid ) return #ok( candid )
                  }
                }
                else if ( status == "rejected" ){
                  state.agent_read_attempts := attempts.count;
                  let path = [encodeUtf8("request_status"), req_id, encodeUtf8("reject_message")];
                  switch( hashtree.lookup( path ) ){
                    case null return #err(#fatal("Agent.update_method(): response lookup failed"));
                    case( ?rejection ){
                      let ?reject_message = decodeUtf8(rejection) else { return #err(#fatal("Failed to decode response")) };
                      return #err(#rejected(reject_message))
                    }
                  }
                }
              }
            }
          }; #err(#fatal("mo:http-loopback/Agent/class: line 60"))
        }
      }
    };

    func request_status(attempts: Attempts, exp: Int, req_id: T.RequestId, cid: Text, mrb: ?Nat64): async* T.Status {

      if ( Time.now() >= exp ) return #err( #expired );

      switch(
        await* read_state(
          {
            canister_id = cid;
            max_response_bytes = mrb;
            paths = [[ encodeUtf8("request_status"), req_id ]]
          }
        )
      ){
        case( #err msg ) { attempts.count += 1; #err(msg) };
        case( #ok cbor ) {

          attempts.count += 1;
          let certificate = Cbor.load( cbor );
          let path = [encodeUtf8("request_status"), req_id, encodeUtf8("status")];
          let ?tree = certificate.get<Cbor.CborArray>("tree", Cbor.getArray) else { return #err(#missing("hashtree")) };
          let hashtree = Cbor.HashTree( tree );
          let ?encoded_status = hashtree.lookup( path ) else { return #err(#missing("request status")) };
          let ?status = decodeUtf8(encoded_status) else { return #err(#fatal("Agent.request_status(): Failed to decode request status")) };

          #ok((status, tree))

        }
      }
    };

    func read_state(read_req: T.ReadRequest): async* T.ReadResponse {
      switch( await* sign_and_send( #read_state( read_req ) ) ){
        case( #err msg ) #err(msg);
        case( #ok (_, cbor) ) {
          let content = Cbor.load( cbor );
          switch( content.get<T.Bytearray>("certificate", Cbor.getBytearray) ){
            case( ?certificate ) #ok( certificate );
            case null #err(#missing("certificate"));
          }
        }
      }
    };

    func sign_and_send(rtype: T.RequestType): async* T.SignResponse {

      let (cid, mrb, client_endpoint) = switch( rtype ){
        case( #read_state req ) (req.canister_id, req.max_response_bytes, client.read_state_endpoint);
        case( #query_method req ) (req.canister_id, req.max_response_bytes, client.query_endpoint);
        case( #update_method req ) (req.canister_id, req.max_response_bytes, client.call_endpoint);
      };

      switch(
        await* sign_request(
          identity, 
          {
            sender = Principal.toBlob( identity.get_principal() );
            ingress_expiry = abs(Time.now()) + state.agent_ingress_expiry;
            nonce = ?nonce_factory.next_blob();
            request = rtype;
          }
        )
      ){
        case( #err msg ) #err(msg);
        case( #ok (reqid, env) ){

          switch( 
            await* client_endpoint(
              {
                max_response_bytes = mrb;
                canister_id = cid;
                envelope = env;
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