import ECDSA "mo:tecdsa";
import Loopback "../../src";
import { toBlob; fromActor; toText } "mo:base/Principal";
import { encodeUtf8 } "mo:base/Text";
import { print } "mo:base/Debug";
import { Service } "service";
import State "state";

shared actor class Test() = self {

  stable let state = State.init();

  let { Client; Agent; Http } = Loopback;

  let { Manager; SECP256K1 = { CURVE; ID = { TEST_KEY_1 } } } = ECDSA;

  let identity_manager = Manager.Manager( state.manager_state );

  state.agent_state.agent_ingress_expiry := 60_000_000_000;

  public shared query func hello(t: Text): async Text { "hello " # t # "!" };
  
  public shared func generate_new_identity(): async ?(Nat, [Text]) {
    switch( await* identity_manager.fill_next_slot({curve=CURVE; name=TEST_KEY_1}) ){
      case( #err _ ) null;
      case( #ok ret ) ?ret
    }
  };

  public shared func get_principal(id: Nat): async Principal {
    let identity = identity_manager.get_slot( id );
    identity.get_principal()
  };

  public shared query func get_public_key(id: Nat): async [Nat8] {
    let identity = identity_manager.get_slot( id );
    identity.public_key
  };

  public shared func sign_message(id: Nat): async ?Blob {
    let identity = identity_manager.get_slot( id );
    let data = encodeUtf8("Hello world");
    switch( await* identity.sign( data ) ){
      case( #ok signature ) ?signature;
      case( #err msg ){
        print(debug_show(#err(msg)));
        null
      }
    }
  };

  public query func transform(args: Http.TransformArgs): async Http.HttpResponsePayload { Loopback.transform(args) };

  public func loopback(id: Nat, t: Text): async {#ok: ?Text; #err: Client.Error} {
    let identity = identity_manager.get_slot( id );
    let loopback_client = Client.Client(state.client_state, transform);
    let agent = Agent.Agent(state.agent_state, loopback_client, identity);
    let service = Service(agent, toText(fromActor(self)));
    await* service.hello( t )
  };

};
