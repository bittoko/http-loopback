export const idlFactory = ({ IDL }) => {
  const Error = IDL.Variant({
    'expired' : IDL.Null,
    'missing' : IDL.Text,
    'other' : IDL.Text,
    'invalid' : IDL.Text,
    'fee_not_defined' : IDL.Text,
    'trapped' : IDL.Text,
    'rejected' : IDL.Text,
    'fatal' : IDL.Text,
  });
  const HttpHeader = IDL.Record({ 'value' : IDL.Text, 'name' : IDL.Text });
  const HttpResponsePayload = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  const TransformArgs = IDL.Record({
    'context' : IDL.Vec(IDL.Nat8),
    'response' : HttpResponsePayload,
  });
  const Test = IDL.Service({
    'generate_new_identity' : IDL.Func(
        [],
        [IDL.Opt(IDL.Tuple(IDL.Nat, IDL.Vec(IDL.Text)))],
        [],
      ),
    'get_principal' : IDL.Func([IDL.Nat], [IDL.Principal], []),
    'get_public_key' : IDL.Func([IDL.Nat], [IDL.Vec(IDL.Nat8)], ['query']),
    'hello' : IDL.Func([IDL.Text], [IDL.Text], []),
    'loopback' : IDL.Func(
        [IDL.Nat, IDL.Text],
        [IDL.Variant({ 'ok' : IDL.Opt(IDL.Text), 'err' : Error })],
        [],
      ),
    'sign_message' : IDL.Func([IDL.Nat], [IDL.Opt(IDL.Vec(IDL.Nat8))], []),
    'transform' : IDL.Func([TransformArgs], [HttpResponsePayload], ['query']),
  });
  return Test;
};
export const init = ({ IDL }) => { return []; };
