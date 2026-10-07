(* ============================================================================
   Relations — spans (Ch4.10).
   A relation from A to B is a span A ← R → B.
   ============================================================================ *)

(* A span is an ordered pair of arrows with common source *)
type ('o, 'a) span = 'a * 'a

(* A span from source a to target b with relation set r.
   The relation set R is a set of pairs (x, y) with x in a and y in b.
   The two arrows are the projections R → a and R → b. *)
let relation_span (a : 'a Finite_sets.set) (r : ('a * 'a) Finite_sets.set) (b : 'a Finite_sets.set) :
    (('a * 'a) Finite_sets.set, ('a * 'a) Finite_sets.set_arrow) span =
  let proj_fst (x, _) = x in
  let proj_snd (_, y) = y in
  (* Cast the projection results back to pairs to keep arrows homogeneous *)
  let open Obj in
  let inj_a (x : 'a) : ('a * 'a) = (x, x) in
  let inj_b (y : 'a) : ('a * 'a) = (y, y) in
  (Finite_sets.SetArrow (r, (fun p -> Obj.magic (proj_fst (Obj.magic p))), r),
   Finite_sets.SetArrow (r, (fun p -> Obj.magic (proj_snd (Obj.magic p))), r))