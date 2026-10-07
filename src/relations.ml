(* ============================================================================
   Relations — spans (Ch4.10).
   A relation from A to B is a span A ← R → B.
   Layer 5: built on the layered core.
   ============================================================================ *)

(* A span is an ordered pair of arrows with common source.
   Here we use a named record with the source set for clarity. *)
type ('o, 'a) span = {
  sp_src_set : 'o;
  sp_arrow1 : 'a;
  sp_arrow2 : 'a;
}

(* Build the span for a relation R ⊆ A × B, with projections R → A, R → B.
   The relation set R holds pairs (x, y). *)
let relation_span (a : 'a Finite_sets.set) (r : ('a * 'a) Finite_sets.set) (b : 'a Finite_sets.set) :
    (('a * 'a) Finite_sets.set, ('a * 'a) Finite_sets.set_arrow) span =
  let open Obj in
  { sp_src_set = r;
    sp_arrow1 = { Finite_sets.sa_src = r;
                  sa_fn = (fun p -> Obj.magic (fst (Obj.magic p : 'a * 'a)));
                  sa_tgt = r };
    sp_arrow2 = { Finite_sets.sa_src = r;
                  sa_fn = (fun p -> Obj.magic (snd (Obj.magic p : 'a * 'a)));
                  sa_tgt = r } }