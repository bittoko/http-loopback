import { Fees; Nonce } "../../../utilities/src";
import { Identity } "../../../ECDSA/src";
import { get = getOpt } "mo:base/Option";


module {

  public type State = {
    var client_path: Text;
    var client_domain: Text;
    var client_nonce: Nonce.State;
    var client_fees: Fees.State;
  };

  public type InitParams = {
    nonce: Nonce.State;
    fees: Fees.State;
    domain: Text;
    path: Text;
  };

  public func init(params: InitParams): State = {
    var client_path = params.path;
    var client_domain = params.domain;
    var client_nonce = params.nonce;
    var client_fees = params.fees;
  };

};