import { toArray = blobToArray } "mo:base/Blob";
import S "State";
import T "Types";
import H "HTTP";

module {

  public class Client(state: S.State) = {

    let gateway : H.Gateway = actor("aaaaa-aa");

    public func query_endpoint(req: T.Request): async* T.Response<T.Candid> { 
      req.addCycles( C.FEE_QUERY_METHOD );
      let response : H.HttpResponsePayload = 
        await gateway.http_request({
          method = #put;
          max_response_bytes = null;
          url = state.http_gateway_url # GATEWAY_CANISTER_API # req.canister_id # "/query";
          headers = [{name = "Content-Type"; value = "application/cbor"}];
          body = ?blobToArray( req.data );
      });
      let cbor = CBOR.decode( res.body );


    };

  };

};