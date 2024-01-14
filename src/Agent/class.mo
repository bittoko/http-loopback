import { Nonce = { Nonce }; Fees = { Fees } } "../../../utilities/src";
import Identity "../../../ECDSA/src/Identity";
import Client "../Client";
import T "types";

module {

  type Client = Client.Client;

  type Identity = Identity.Identity;

  public class Agent(state: T.State, client : Client, identity: Identity) = {

    let fees = Fees( state.client_fees );

    let nonce_factory = Nonce( state.nonce );
    
    public let principal = identity.principal;

    public func query_method(req: T.CallRequest) : T.Response {};

    public func update_method(req: T.CallRequest) : T.Response {};

    public func read_state(req: T.ReadRequest) : T.Response {};

  };

};