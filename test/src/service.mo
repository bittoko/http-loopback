import { Agent; Client } "../../src";

module {

  type Agent = Agent.Agent;

  public class Service(agent: Agent, canister_id: Text) = {

    public func hello(t: Text): async* {#ok: ?Text; #err: Client.Error} {
      switch(
        await* agent.update_method(
          {
            max_response_bytes = ?1_000_000;
            canister_id = canister_id;
            method_name = "hello";
            arg = to_candid( t );
          }
        )
      ){
        case( #ok candid ) #ok( from_candid( candid ) );
        case( #err msg ) #err(msg)
      }
    };

  };

}