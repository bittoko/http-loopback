import { fromArray = blobFromArray } "mo:base/Blob";
import { decode } "mo:cbor/Decoder";
import { toArray = bufferToArray; fromArray = bufferFromArray } "mo:base/Buffer";
import { unwrapArray } "value";
import { trap; print } "mo:base/Debug";
import Content "class";
import T "types";

module {

  let EMPTY   : Nat64 = 0;
  let FORK    : Nat64 = 1; 
  let LABELED : Nat64 = 2;
  let LEAF    : Nat64 = 3;
  let PRUNED  : Nat64 = 4;

  public type Path = [Blob];

  public type Tree = T.CborArray;

  public class Certificate(tree: Tree) = {

    public func lookup(path: Path) : ?Blob = lookup_path(path, tree, 0, path.size());

    func lookup_path(path: Path, tree: Tree, offset: Nat, size: Nat): ?Blob {
      let #majorType0( tag ) = tree[0] else { trap("0") };
      if ( size == 0 ){
        if ( tag == LEAF ){
          let #majorType2( bytes ) = tree[1] else { trap("1") };
          return ?blobFromArray( bytes )
        } 
        else trap("2");
      };
      switch( find_label(path[offset], flatten_forks(tree)) ){
        case( ?t ) lookup_path(path, t, offset+1, size-1);
        case null trap("3")
      }
    };

    func flatten_forks(t: Tree): [Tree] {
      let #majorType0( tag ) = t[0] else { return [] };
      if( tag == EMPTY ) []
      else if ( tag == FORK ){
        let #majorType4( l_val ) = t[1] else { return [] };
        let #majorType4( r_val ) = t[2] else { return [] };
        let buffer = bufferFromArray<Tree>( flatten_forks( l_val ) );
        buffer.append( bufferFromArray<Tree>( flatten_forks( r_val ) ) );
        bufferToArray<Tree>( buffer )
      }
      else [t]
    };

    func find_label(key: Blob, trees: [Tree]): ?Tree {
      if ( trees.size() == 0 ) return null;
      for ( tree in trees.vals() ){
        let #majorType0( tag ) = tree[0] else { return null };
        if ( tag == LABELED ){
          let #majorType2( bytes ) = tree[1] else { return null };
          let label_ : Blob = blobFromArray( bytes );
          if ( label_ == key ){
            let #majorType4( labeled_tree ) = tree[2] else { return null };
            return ?labeled_tree
          }
        }
      };
      null
    };
  
  };

    public func from_response_blob(response: Blob): ?Certificate {
      let ?content_map = get_content_map( response ) else { return null };
      for ( field in content_map.vals() ){
        switch( field.0 ){
          case( #majorType3 name ) if ( name == "certificate" ){
            let #majorType2( arr ) = field.1 else { return null };
            let ?cert_map = get_content_map( blobFromArray( arr ) ) else { return null };
            for ( entry in cert_map.vals() ) {
              switch( entry.0 ){
                case( #majorType3 e_name ) if ( e_name == "tree" ){
                  let #majorType4( elems ) = entry.1 else { return null };
                  return ?Certificate( elems );
                };
                case _ ();
              };
            }
          };
          case _ ();
        }
      };
      null
    };

    func get_content_map(blob: Blob): ?T.CborMap {
      let #ok( cbor ) = decode( blob ) else { return null };
      let #majorType6( rec ) = cbor else { return null };
      if ( rec.tag != 55_799 ) return null;
      let #majorType5( map ) = rec.value else { return null };
      ?map
    };

};