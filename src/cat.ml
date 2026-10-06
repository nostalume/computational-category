(* ============================================================================
   Cat — the category type and operations.
   ============================================================================ *)

(* Category: ('o object, 'a arrow) *)
type ('o, 'a) cat = Cat of
  ('a -> 'o) *     (* source *)
  ('a -> 'o) *     (* target *)
  ('o -> 'a) *     (* identity *)
  ('a * 'a -> 'a)  (* composition *)

let cat_source (Cat (s, _, _, _)) = s
let cat_target (Cat (_, t, _, _)) = t
let cat_ident (Cat (_, _, i, _)) = i
let cat_comp (Cat (_, _, _, c)) = c

(* Compose two arrows: compose c g f = g ∘ f *)
let compose c g f = cat_comp c (g, f)

(* Dual category: swap source/target, reverse composition *)
let dual_cat (Cat (s, t, i, c)) =
  Cat (t, s, i, fun (g, f) -> c (f, g))