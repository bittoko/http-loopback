export const idlFactory = ({ IDL }) => {
  const Value = IDL.Rec();
  const FloatPrecision = IDL.Variant({
    'f16' : IDL.Null,
    'f32' : IDL.Null,
    'f64' : IDL.Null,
  });
  const FloatX = IDL.Record({
    'exponent' : IDL.Opt(IDL.Int),
    'mantissa' : IDL.Nat,
    'precision' : FloatPrecision,
    'isNegative' : IDL.Bool,
  });
  Value.fill(
    IDL.Variant({
      'majorType0' : IDL.Nat64,
      'majorType1' : IDL.Int,
      'majorType2' : IDL.Vec(IDL.Nat8),
      'majorType3' : IDL.Text,
      'majorType4' : IDL.Vec(Value),
      'majorType5' : IDL.Vec(IDL.Tuple(Value, Value)),
      'majorType6' : IDL.Record({ 'tag' : IDL.Nat64, 'value' : Value }),
      'majorType7' : IDL.Variant({
        'float' : FloatX,
        'integer' : IDL.Nat8,
        'bool' : IDL.Bool,
        '_break' : IDL.Null,
        '_undefined' : IDL.Null,
        '_null' : IDL.Null,
      }),
    })
  );
  const CborValue = IDL.Variant({
    'majorType0' : IDL.Nat64,
    'majorType1' : IDL.Int,
    'majorType2' : IDL.Vec(IDL.Nat8),
    'majorType3' : IDL.Text,
    'majorType4' : IDL.Vec(Value),
    'majorType5' : IDL.Vec(IDL.Tuple(Value, Value)),
    'majorType6' : IDL.Record({ 'tag' : IDL.Nat64, 'value' : Value }),
    'majorType7' : IDL.Variant({
      'float' : FloatX,
      'integer' : IDL.Nat8,
      'bool' : IDL.Bool,
      '_break' : IDL.Null,
      '_undefined' : IDL.Null,
      '_null' : IDL.Null,
    }),
  });
  const CborEntry = IDL.Tuple(CborValue, CborValue);
  const CborMap = IDL.Vec(CborEntry);
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
    'debug_bad' : IDL.Func([], [CborMap], ['query']),
    'debug_good' : IDL.Func([], [IDL.Opt(Value)], ['query']),
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
