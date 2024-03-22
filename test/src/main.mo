import { fromActor = principalFromActor } "mo:base/Principal";
import { encodeUtf8 } "mo:base/Text";
import { print } "mo:base/Debug";
import { Service } "service";
import Loopback "../../src";
import ECDSA "mo:tecdsa";
import RT "runtime";

shared actor class Test() = self {

  let { Http } = Loopback;

  let { Runtime; State; Types = T } = RT;

  stable let state = State.empty();

  let runtime = Runtime( state );

  public func init() : async T.AsyncReturn<()> { await* runtime.init( principalFromActor( self ) ) };

  public shared func hello(t: Text): async Text { "hello " # t # "!" };

  public query func transform(args: Http.TransformArgs): async Http.HttpResponsePayload { Loopback.transform(args) };

  public shared func get_principal(id: Nat): async Principal {
    runtime
      .identity()
      .get_principal()
  };

  public shared query func get_public_key(id: Nat): async [Nat8] {
    runtime
      .identity()
      .public_key
  };

  public func loopback(text: Text): async {#ok: ?Text; #err: Loopback.Client.Error} {
    await* runtime
      .service( transform )
      .hello( text )
  };

  public shared func sign_message(msg: Text): async ?Blob {
    switch(
      await* runtime
        .identity()
        .sign( encodeUtf8( msg ) )
    ){
      case( #ok signature ) ?signature;
      case( #err emsg ){
        print(debug_show(#err(emsg)));
        null
      }
    }
  };

};
