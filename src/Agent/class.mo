import { Nonce = { Nonce }; Fees = { Fees } } "../../../utilities/src";
import Identity "../../../ECDSA/src/Identity";
import { map_call_request; map_read_request } "utils";
import { Content } "../Content";
import Time "mo:base/Time";
import Client "../Client";

import T "types";

module {

  type Client = Client.Client;
  type Identity = Identity.Identity;

  public class Agent(state: T.State, client : Client, identity: Identity) = {

    let nonce_factory = Nonce.Nonce( state.agent_nonce );

    public func query_method(req: T.CallRequest) : async* T.Response {
      

      let content = Content(
        map_call_request(#query_, req, {
          principal = identity.principal;
          nonce = nonce_factory.next_blob();
          ingress_expiry = state.agent_ingress_expiry;
        })
      );

      let hash : T.Hash = content.hash();
      let cbor : T.Cbor = content.export_cbor();
      let message_id : Blob = to_message_id( content_hash );

      switch( await* identity.sign( message_id ) ){
        
      };

    };

    public func update_method(req: T.CallRequest) : T.Response {};

    public func read_state(req: T.ReadRequest) : T.Response {};

  };

};