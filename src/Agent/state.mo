import { Fees; Nonce } "../../../utilities/src";

module {

  public type State = {
    var agent_read_attempts: Nat;
    var agent_ingress_expiry : Nat;
    var agent_nonce : Nonce.State;
  };

  public type InitParams = { ingress_expiry : Nat };

  public func init(params: InitParams) : State = {
    var agent_read_attempts = 1;
    var agent_ingress_expiry = params.ingress_expiry;
    var agent_nonce = Nonce.State.init()
  }

}