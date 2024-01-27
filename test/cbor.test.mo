import {test; suite} "mo:test";
import { decode } "mo:cbor/Decoder";
import { encodeUtf8; decodeUtf8 } "mo:base/Text";
import Cbor "../src/Cbor";
import { trap; print } "mo:base/Debug";
import Blob "mo:base/Blob";
import T "../src/Cbor/types";

suite("Response Certificate", func(){

  var content : T.ContentMap = Cbor.load([]);
  var hashtree : T.HashTree = object {public func lookup(p: [Blob]): ?Blob = null};
  let response : Blob = "\d9\d9\f7\a1\6b\63\65\72\74\69\66\69\63\61\74\65\59\05\2e\d9\d9\f7\a3\64\74\72\65\65\83\01\83\01\82\04\58\20\3b\53\c2\2e\b0\60\a3\01\f8\fa\96\db\84\d6\33\2c\62\b6\6c\08\a4\18\d0\4f\ce\ae\a0\85\90\47\5b\08\83\01\83\02\4e\72\65\71\75\65\73\74\5f\73\74\61\74\75\73\83\01\82\04\58\20\6f\99\84\b2\d3\41\ba\89\cf\23\7b\32\58\6b\4f\09\d1\5f\4d\44\0c\07\20\ae\6c\fb\fc\a9\7c\66\1e\b8\83\01\83\01\83\01\82\04\58\20\ec\3b\6e\2c\e9\e3\4d\1a\b6\11\1a\43\08\6f\42\17\66\f6\d4\76\12\e2\a3\01\c7\ab\e1\d8\bb\fa\35\91\83\01\83\01\82\04\58\20\d3\c0\0f\e9\0d\eb\9f\8d\ce\3e\67\b4\c5\b7\4e\65\17\40\32\ea\2a\7e\1e\f7\e0\dc\e8\2e\5e\9f\1a\34\83\01\83\01\83\01\82\04\58\20\60\a3\ff\43\2a\f6\ae\1b\45\d4\66\e8\cc\46\50\69\ef\32\e6\ea\ff\3e\bb\94\37\94\de\e2\00\3b\f7\ff\83\02\58\20\95\fb\07\e2\ef\83\0d\e3\53\e6\70\0e\05\f7\81\d2\79\6b\fd\bb\2e\77\b3\e6\02\f9\81\bb\9d\71\23\1b\83\01\83\02\45\72\65\70\6c\79\82\03\58\1b\44\49\44\4c\00\01\71\13\32\30\32\33\2d\31\32\2d\33\31\2c\20\32\33\3a\35\39\3a\39\83\02\46\73\74\61\74\75\73\82\03\47\72\65\70\6c\69\65\64\82\04\58\20\67\f3\24\bc\1a\d9\c3\01\be\3c\7c\4f\c1\8c\2e\29\d5\af\35\a5\07\c1\7e\1e\1b\0a\af\a8\cb\c1\96\9e\82\04\58\20\a4\48\06\d4\fa\42\a2\0d\8c\6e\26\e2\d6\f4\93\f7\ab\7c\05\b8\0e\7f\0b\2f\f3\1d\f9\f7\d9\b3\ae\d3\82\04\58\20\45\bd\f9\19\b2\42\54\f1\eb\ee\18\21\d5\26\05\3a\0b\81\f0\8b\3a\3b\41\71\62\b2\98\26\c8\a0\7b\9d\82\04\58\20\ac\d8\bc\b5\24\ce\0b\a6\dd\2e\4f\ff\c8\7e\b9\a0\ff\0a\a1\83\3d\42\a1\af\ec\58\2f\ab\56\40\42\f5\82\04\58\20\15\97\19\69\81\e2\b5\88\e6\9e\cf\12\93\62\5c\9c\ba\c2\03\69\b8\ed\3b\da\e4\e1\4a\4c\88\82\cb\9d\82\04\58\20\ac\5d\69\1d\e6\f2\a3\72\c1\14\5d\96\8f\c5\f3\d9\b7\da\6f\7a\88\c6\a6\86\67\c5\a8\f8\1f\13\ec\60\83\01\82\04\58\20\29\0a\60\2b\09\ee\3f\e7\3e\0b\61\e3\12\41\55\9b\c3\07\06\e0\d0\22\7c\01\69\cd\41\27\5c\e2\a7\91\83\02\44\74\69\6d\65\82\03\49\ef\ed\8f\90\b8\bc\dc\d6\17\69\73\69\67\6e\61\74\75\72\65\58\30\b3\6b\cf\f5\06\11\71\59\45\12\eb\1b\f8\6a\4c\19\93\5b\60\da\54\bc\c4\c2\b2\3b\c3\07\08\d3\e9\ff\3b\b1\88\98\3d\08\08\93\31\af\56\57\81\72\86\96\6a\64\65\6c\65\67\61\74\69\6f\6e\a2\69\73\75\62\6e\65\74\5f\69\64\58\1d\2f\1a\95\48\06\2f\52\ca\0e\90\e7\2a\4a\97\cb\32\4f\a1\df\b6\2b\56\4e\f1\b2\9f\38\aa\02\6b\63\65\72\74\69\66\69\63\61\74\65\59\02\57\d9\d9\f7\a2\64\74\72\65\65\83\01\82\04\58\20\5a\7f\70\ab\df\36\79\d5\b5\fa\50\08\f3\81\22\12\3b\1a\12\7b\18\ff\c7\3b\e6\80\59\77\7f\dd\ef\4d\83\01\83\02\46\73\75\62\6e\65\74\83\01\83\01\83\01\82\04\58\20\26\7f\e5\51\11\b5\6e\3c\39\75\53\2e\a3\37\3f\7b\72\e9\f8\20\72\fe\8e\60\7e\d3\44\86\47\8a\5b\39\83\01\83\01\83\01\82\04\58\20\1e\ab\30\21\2d\99\95\b8\cf\17\0c\82\de\d4\4d\6e\f0\5c\78\8f\fc\6c\80\e0\1e\e5\89\87\92\6e\3d\36\83\02\58\1d\2f\1a\95\48\06\2f\52\ca\0e\90\e7\2a\4a\97\cb\32\4f\a1\df\b6\2b\56\4e\f1\b2\9f\38\aa\02\83\01\83\02\4f\63\61\6e\69\73\74\65\72\5f\72\61\6e\67\65\73\82\03\58\1b\d9\d9\f7\81\82\4a\00\00\00\00\01\60\00\00\01\01\4a\00\00\00\00\01\6f\ff\ff\01\01\83\02\4a\70\75\62\6c\69\63\5f\6b\65\79\82\03\58\85\30\81\82\30\1d\06\0d\2b\06\01\04\01\82\dc\7c\05\03\01\02\01\06\0c\2b\06\01\04\01\82\dc\7c\05\03\02\01\03\61\00\84\69\8b\a1\8e\a4\6f\20\41\35\3c\98\fd\f6\98\02\35\fa\b9\9a\6f\5b\83\c5\de\3b\b3\2a\7a\d1\90\ef\26\fd\2a\fa\d2\dd\2e\4f\b5\ea\eb\c4\fd\17\7e\3c\11\ed\29\fb\7d\ab\26\a6\90\9d\36\6c\18\5c\b9\d9\64\d3\ff\3a\8e\71\c0\c2\8a\df\ca\71\56\98\f6\79\ce\f6\b6\34\61\06\a7\8c\9f\8d\3f\8e\9a\66\e8\80\82\04\58\20\70\ff\c8\b0\74\ec\3f\16\c6\3c\4e\f6\7b\ff\fa\08\6f\81\ab\d7\1c\92\ca\2b\fb\58\a0\fb\5f\6f\9a\18\82\04\58\20\2b\ea\e7\05\be\11\39\5c\a7\a1\05\36\93\4b\80\0d\4a\8f\11\e0\bf\36\6d\6e\1d\d8\6e\f0\df\d6\4a\4d\82\04\58\20\ef\89\95\c4\10\ed\40\57\31\c9\b9\13\f6\78\79\e3\b6\a6\b4\d6\59\d2\74\6d\b9\a6\b4\7d\7e\70\d3\d5\82\04\58\20\98\cf\91\90\6d\48\08\8a\29\02\80\c6\bf\5e\50\54\c9\07\a3\c6\63\1a\95\0a\52\d7\5c\f5\04\49\9f\f2\83\02\44\74\69\6d\65\82\03\49\ee\e4\f9\f7\aa\de\da\d5\17\69\73\69\67\6e\61\74\75\72\65\58\30\b9\0c\ea\46\16\d1\1c\a5\e5\91\3f\51\8f\af\eb\ff\87\8f\1f\88\b6\d6\9a\3b\90\7d\4e\e3\d0\68\07\1f\0b\de\6c\50\40\a9\d9\36\72\21\4d\c8\73\8e\d6\ac";
  let request_id = Blob.fromArray([149, 251, 7, 226, 239, 131, 13, 227, 83, 230, 112, 14, 5, 247, 129, 210, 121, 107, 253, 187, 46, 119, 179, 230, 2, 249, 129, 187, 157, 113, 35, 27]);
  
  test("load cbor response", func(){
    content := Cbor.load( Blob.toArray(response) );
  });

  test("load cbor certificate", func(){
    let ?certificate = content.get<T.ContentMap>("certificate", Cbor.getContentMap) else { trap("") };
    content := certificate
  });

  test("load hashtree from cert", func(){
    let ?tree = content.get<T.HashTree>("tree", Cbor.getHashTree) else { trap("") };
    hashtree := tree
  });

  test("lookup_request_status", func() {
    let path : [Blob] = [encodeUtf8("request_status"), request_id, encodeUtf8("status")];
    let ?ret = hashtree.lookup( path ) else { trap("failed to locate path" ) };
    let ?txt = decodeUtf8( ret ) else { trap("failed to decode status blob" ) };
    assert txt == "replied"
  });

  test("lookup_reply_blob", func() {
    let path : [Blob] = [encodeUtf8("request_status"), request_id, encodeUtf8("reply")];
    let ?ret = hashtree.lookup( path ) else { trap("failed to locate reply" ) };
  })

})