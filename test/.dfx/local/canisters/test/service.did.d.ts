import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Test {
  'generate_new_identity' : ActorMethod<[], [] | [[bigint, Array<string>]]>,
  'get_principal' : ActorMethod<[bigint], Principal>,
  'get_public_key' : ActorMethod<[bigint], Uint8Array | number[]>,
  'hello' : ActorMethod<[string], string>,
  'loopback' : ActorMethod<[bigint, string], [] | [string]>,
  'sign_message' : ActorMethod<[bigint], [] | [Uint8Array | number[]]>,
}
export interface _SERVICE extends Test {}
