import {test; suite} "mo:test";
import { Nonce } "mo:utilities";
import { range } "mo:base/Iter";
import { trap; print } "mo:base/Debug";

suite("Nonce Class Methods", func(){

  let state = Nonce.State.init();
  let nonce_factory = Nonce.Nonce(state);

  test("next()", func() {
    let nat : Nat = nonce_factory.next();
  	assert nat == 0;
  });

  test("next_blob()", func(){
	let blob : Blob = nonce_factory.next_blob();
	assert blob == "\01"
  });

  test("next_string()", func(){
	let text : Text = nonce_factory.next_string();
    assert text == "02";
  });

  test("next_array()", func(){
	let arr : [Nat8] = nonce_factory.next_array();
	assert arr[0] == 0x03;
  });

  test("BigInt", func(){
    for( i in range(0, 18446744073709551620)){
	  ignore nonce_factory.next();
	};
	print(debug_show(nonce_factory.next()))
  });

})