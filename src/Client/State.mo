import { Fees; Nonce } "../../../utilities/src";
import { Identity } "../../../ECDSA/src";


module {

  public type State = {
    var client_path: Text;
    var client_domain: Text;
    var client_nonce: Nonce.State;
    var client_fees: Fees.State;
  };

  public type InitParams = {fees: [(Text, Fees.Fee)]; domain: Text; path: Text};

  public func init(params: InitParams): State = {
    var client_path = params.path;
    var client_domain = params.domain;
    var client_nonce = Nonce.State.init();
    var client_fees = Fees.State.init(params.fees);
  };

};