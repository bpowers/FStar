module X64.Vale.StateLemmas_i
open X64.Machine_s
open X64.Vale.State_i
open FStar.UInt
module S = X64.Semantics_s
module M = TransparentMap

#reset-options "--initial_fuel 2 --max_fuel 2"

let state_to_S (s:state) : S.state = {
  S.ok = s.ok;
  S.regs = (fun r -> S.u (s.regs r));
  S.flags = S.u (int_to_nat64 s.flags);
  S.mem =
    (let mappings i = S.u (Map.sel s.mem i) in
    S.mem_make mappings (Map.domain s.mem));
}

let state_of_S (s:S.state) : state =
  let { S.ok = ok; S.regs = regs; S.flags = flags; S.mem = mem } = s in {
    ok = ok;
    regs = (fun r -> UInt64.v (regs r));
    flags = UInt64.v flags;
    mem =
      (let mappings i = UInt64.v (Map.sel mem i) in
      S.mem_make mappings (Map.domain mem));
  }

let lemma_to_ok s = ()
let lemma_to_flags s = ()
let lemma_to_mem_contains s i = ()
let lemma_to_mem_sel s i = ()
let lemma_to_reg s r = ()
let lemma_to_eval_operand s o = ()
let lemma_to_valid_operand s o = ()

let lemma_of_to s =
  assert (state_eq s (state_of_S (state_to_S s)));
  ()

let lemma_to_of s =
  let s' = state_of_S s in
  let s'' = state_to_S s' in
  let { S.ok = ok; S.regs = regs; S.flags = flags; S.mem = mem } = s in
  let { S.ok = ok''; S.regs = regs''; S.flags = flags''; S.mem = mem'' } = s'' in
  assert (feq regs regs'');
  assert (Map.equal mem mem'');
  ()
