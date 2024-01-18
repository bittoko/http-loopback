import Content "../Content";
import T "types";

module {

  let EMPTY   : Nat = 0;
  let FORK    : Nat = 1;
  let LABELED : Nat = 2;
  let LEAF    : Nat = 3;
  let PRUNED  : Nat = 4;

  public func lookup(path: [Blob], cert: T.Map) : ?Blob {
    let certificate = Content(cert);
    let ?tree = certificate.get("tree", unwrapRec) else { return null };
  };

};