import { Fees; Nonce } "mo:utilities";
import { Client; Agent } "../../src";
import ECDSA "mo:tecdsa";

module {

  public let { SECP256K1 } = ECDSA;

  public let { FEES = { ID = FEE_ID; APP = FEE_AMT } } = Client;

  public type State = {
    manager_state : ECDSA.Manager.State;
    client_state : Client.State;
    agent_state : Agent.State; 
  };

  public func init(): State {
    let fees = Fees.State.init([
      (SECP256K1.ID.TEST_KEY_1, SECP256K1.FEE.TEST_KEY_1),
      (FEE_ID.PER_RESPONSE_BYTE, FEE_AMT.PER_RESPONSE_BYTE),
      (FEE_ID.PER_REQUEST_BYTE, FEE_AMT.PER_REQUEST_BYTE),
      (FEE_ID.PER_CALL, FEE_AMT.PER_CALL),
    ]);
    return {
      manager_state = ECDSA.Manager.State.init({canister_id = "aaaaa-aa"; fees = fees});
      agent_state = Agent.State.init({ingress_expiry = 120_000_000_000});
      client_state = Client.State.init({
        domain = "https://icp-api.io";
        path = "/api/v2/canister/";
        nonce = Nonce.State.init();
        fees = fees;
      });
    };
  };

}
