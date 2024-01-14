import Buffer "mo:base/Buffer";
import Content "Content";
import T "types";

module {

  public func map_request(req: T.Request): T.Map {
    let map_buffer = Buffer.Buffer<T.MapEntry>(4);
    map_buffer.add(("sender", Content.wrapBlob(req.sender)));
    map_buffer.add(("ingress_expiry", Content.wrapNat(req.ingress_expiry)));
    switch( req.request ){
      case( #call_method params ){
        let request_type = switch( params.request_type ){case(#call)"call";case(#query_)"query"};
        map_buffer.add(("request_type", Content.wrapText(request_type)));
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


};