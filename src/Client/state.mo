import { get = getOpt } "mo:base/Option";
import { Fees; Nonce } "mo:utilities";
import { Identity } "mo:tecdsa";

module {

  public type State = {
    var path: Text;
    var domain: Text;
    var nonce: Nonce.State;
    var fees: Fees.State;
  };

  public type InitParams = {
    nonce: Nonce.State;
    fees: Fees.State;
    domain: Text;
    path: Text;
  };

  public func init(params: InitParams): State = {
    var path = params.path;
    var domain = params.domain;
    var nonce = params.nonce;
    var fees = params.fees;
  };

};