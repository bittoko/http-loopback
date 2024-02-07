export const idlFactory = ({ IDL }) => {
  const Test = IDL.Service({
    'generate_new_identity' : IDL.Func(
        [],
        [IDL.Opt(IDL.Tuple(IDL.Nat, IDL.Vec(IDL.Text)))],
        [],
      ),
    'get_principal' : IDL.Func([IDL.Nat], [IDL.Principal], ['query']),
    'get_public_key' : IDL.Func([IDL.Nat], [IDL.Vec(IDL.Nat8)], ['query']),
    'hello' : IDL.Func([IDL.Text], [IDL.Text], ['query']),
    'loopback' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Opt(IDL.Text)], []),
    'sign_message' : IDL.Func([IDL.Nat], [IDL.Opt(IDL.Vec(IDL.Nat8))], []),
  });
  return Test;
};
export const init = ({ IDL }) => { return []; };
