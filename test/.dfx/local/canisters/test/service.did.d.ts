import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type CborEntry = [CborValue, CborValue];
export type CborMap = Array<CborEntry>;
export type CborValue = { 'majorType0' : bigint } |
  { 'majorType1' : bigint } |
  { 'majorType2' : Uint8Array | number[] } |
  { 'majorType3' : string } |
  { 'majorType4' : Array<Value> } |
  { 'majorType5' : Array<[Value, Value]> } |
  { 'majorType6' : { 'tag' : bigint, 'value' : Value } } |
  {
    'majorType7' : { 'float' : FloatX } |
      { 'integer' : number } |
      { 'bool' : boolean } |
      { '_break' : null } |
      { '_undefined' : null } |
      { '_null' : null }
  };
export type Error = { 'expired' : null } |
  { 'missing' : string } |
  { 'other' : string } |
  { 'invalid' : string } |
  { 'fee_not_defined' : string } |
  { 'trapped' : string } |
  { 'rejected' : string } |
  { 'fatal' : string };
export type FloatPrecision = { 'f16' : null } |
  { 'f32' : null } |
  { 'f64' : null };
export interface FloatX {
  'exponent' : [] | [bigint],
  'mantissa' : bigint,
  'precision' : FloatPrecision,
  'isNegative' : boolean,
}
export interface HttpHeader { 'value' : string, 'name' : string }
export interface HttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface Test {
  'debug_bad' : ActorMethod<[], CborMap>,
  'debug_good' : ActorMethod<[], [] | [Value]>,
  'generate_new_identity' : ActorMethod<[], [] | [[bigint, Array<string>]]>,
  'get_principal' : ActorMethod<[bigint], Principal>,
  'get_public_key' : ActorMethod<[bigint], Uint8Array | number[]>,
  'hello' : ActorMethod<[string], string>,
  'loopback' : ActorMethod<
    [bigint, string],
    { 'ok' : [] | [string] } |
      { 'err' : Error }
  >,
  'sign_message' : ActorMethod<[bigint], [] | [Uint8Array | number[]]>,
  'transform' : ActorMethod<[TransformArgs], HttpResponsePayload>,
}
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export type Value = { 'majorType0' : bigint } |
  { 'majorType1' : bigint } |
  { 'majorType2' : Uint8Array | number[] } |
  { 'majorType3' : string } |
  { 'majorType4' : Array<Value> } |
  { 'majorType5' : Array<[Value, Value]> } |
  { 'majorType6' : { 'tag' : bigint, 'value' : Value } } |
  {
    'majorType7' : { 'float' : FloatX } |
      { 'integer' : number } |
      { 'bool' : boolean } |
      { '_break' : null } |
      { '_undefined' : null } |
      { '_null' : null }
  };
export interface _SERVICE extends Test {}
