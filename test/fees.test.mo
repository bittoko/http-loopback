import {test; suite} "mo:test";
import { Fees } "mo:utilities";
import { trap; print } "mo:base/Debug";

suite("Fee Class Methods", func(){

  let state = Fees.State.init([("dfx_test_key", 10_000_000)]);
  let fees = Fees.Fees(state);

  test("get() - existing", func() {
    switch( fees.get("dfx_test_key") ){
      case( #ok fee ) assert fee == 10_000_000;
      case( #err msg ) assert false;
    }
  });

  test("get() - missing", func() {
    switch( fees.get("bad_key") ){
      case( #ok fee ) assert false;
      case( #err msg ) switch( msg ){
        case( #fee_not_defined txt){
          assert txt == "bad_key"
        }
      }
    }
  });

})