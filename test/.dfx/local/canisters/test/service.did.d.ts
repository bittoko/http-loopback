import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AsyncError = { 'other' : string } |
  { 'fee_not_defined' : string } |
  { 'trapped' : string };
export type AsyncReturn = { 'ok' : null } |
  { 'err' : AsyncError };
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
  'get_principal' : ActorMethod<[bigint], Principal>,
  'get_public_key' : ActorMethod<[bigint], Uint8Array | number[]>,
  'hello' : ActorMethod<[string], string>,
  'init' : ActorMethod<[], AsyncReturn>,
  'loopback' : ActorMethod<
    [string],
    { 'ok' : [] | [string] } |
      { 'err' : Error }
  >,
  'sign_message' : ActorMethod<[string], [] | [Uint8Array | number[]]>,
  'transform' : ActorMethod<[TransformArgs], HttpResponsePayload>,
}
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface _SERVICE extends Test {}
