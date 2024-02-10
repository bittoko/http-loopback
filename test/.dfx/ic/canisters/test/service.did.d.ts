import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type Error = { 'expired' : null } |
  { 'missing' : string } |
  { 'other' : string } |
  { 'invalid' : string } |
  { 'fee_not_defined' : string } |
  { 'trapped' : string } |
  { 'rejected' : string } |
  { 'fatal' : string };
export interface HttpHeader { 'value' : string, 'name' : string }
export interface HttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface Test {
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
export interface _SERVICE extends Test {}
