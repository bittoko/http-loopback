import { Nonce = { Nonce }; Fees } "mo:utilities";
import { add = addCycles } "mo:base/ExperimentalCycles";
import Cbor "../Cbor";
import S "state";
import T "types";
import C "const";
import H "http";

module {

  public class Client(state: S.State) = {

    let ic : H.IC = actor("aaaaa-aa");

    let fees = Fees.Fees( state.client_fees );

    let nonce_factory = Nonce.Nonce( state.client_nonce );

    public func set_path(t: Text): () { state.client_path := t };

    public func set_domain(t: Text): () { state.client_domain := t };

    public func set_fee(k: Text, v: Nat64): () = fees.set(k, v);
    
    public func get_path(): Text = state.client_path;

    public func get_domain(): Text = state.client_domain;

    public func get_fee(k: Text): T.ReturnFee = fees.get(k);

    public func query_endpoint(request: T.Request): async* T.Response {
      await* canister_endpoint(request, "/query")
    };

    public func call_endpoint(request: T.Request): async* T.Response {
      await* canister_endpoint(request, "/call")
    };

    public func read_state_endpoint(request: T.Request): async* T.Response {
      await* canister_endpoint(request, "/read_state")
    };

    public func calculate_fee(request_bytes: Nat64, response_bytes: ?Nat64): T.ReturnFee {
      let max_response = getOpt<Nat64>(response_bytes, C.DEFAULT_MAX_RESPONSE_BYTES);
      let #ok(base_fee) = fees.get(C.FEE_KEY_PER_CALL) else { return #err(#fee_not_defined(C.FEE_KEY_PER_CALL)) };
      let #ok(request_fee) = fees.multiply(C.FEE_KEY_PER_REQUEST_BYTE, request_bytes) else { return #err(#fee_not_defined(C.FEE_KEY_PER_REQUEST_BYTE)) };
      let #ok(response_fee) = fees.multiply(C.FEE_KEY_PER_RESPONSE_BYTE, max_response) else { return #err(#fee_not_defined(C.FEE_KEY_PER_RESPONSE_BYTE)) };
      #ok(base_fee + request_fee + response_fee)
    };
  
    func canister_endpoint(request: T.Request, endpoint: Text): async* T.Response {
      switch( calculate_fee(natToNat64(request.data.size()), request.max_response_bytes) ) {
        case( #err msg ) #err(msg);
        case( #ok fee ){
          addCycles( nat64ToNat(fee) );
          process_http_response(
            await ic.http_request({
              method = #post;
              transform = null;
              body = ?Cbor.dump( request.envelope );
              max_response_bytes = request.max_response_bytes;
              url = state.client_domain # state.client_path # request.canister_id # endpoint;
              headers = [
                { name = "Content-Type"; value = "application/cbor" },
                { name = "Idempotency-Key"; value = nonce_factory.next_string() }
              ]
            })
          )
        }
      }
    };

    func process_http_response(res: H.HttpResponsePayload) : T.Response {
      if ( res.status >= 500 ) return #err(#rejected("server error"));
      if ( res.status >= 400 ) return #err(#rejected("malformed request"));
      switch( res.status ){
        case( 202 ) #ok( Cbor.load( res.body ) );
        case( 200 ){
          let content = Cbor.load( res.body );
          let ?reject_code = content.get<Nat64>("reject_code", Cbor.getNat64) else { return #err(#missing("reject_code")) };
          let ?reject_msg = content.get<Text>("reject_message", Cbor.getText) else { return #err(#missing("reject_message")) };
          switch( reject_code ){
            case( 1 ) #err( #rejected("sys_fatal: " # reject_msg) );
            case( 2 ) #err( #rejected("sys_transient: " #reject_msg) );
            case( 3 ) #err( #rejected("destination_invalid: " # reject_msg) );
            case( 4 ) #err( #rejected("canister_reject: " #reject_msg) );
            case( 5 ) #err( #rejected("canister_error: " # reject_msg) );
            case( v ) #err( #rejected("invalid_reject_code: "  # debug_show(v)) );
          }
        };
        case( v ) #err(#rejected("unknown response status: " # debug_show(v)) )
      }
    };
  
  };

};