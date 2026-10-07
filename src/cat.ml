(* ============================================================================
   Cat — the category type and operations.
   Layer 1: category interface.
   ============================================================================ *)

(* Category: ('o object, 'a arrow).
   Fields are named to avoid positional confusion. *)
type ('o, 'a) cat = {
  source : 'a -> 'o;
  target : 'a -> 'o;
  ident  : 'o -> 'a;
  comp   : 'a * 'a -> 'a;
}

let cat_source c = c.source
let cat_target c = c.target
let cat_ident c = c.ident
let cat_comp c = c.comp

(* Compose two arrows: compose c g f = g ∘ f *)
let compose c g f = c.comp (g, f)

(* Result-based composition: returns Error instead of raising.
   Callers must handle failure explicitly, making it composable. *)
let compose_result c g f =
  let sg = c.target f in
  let tg = c.source g in
  if sg = tg then Ok (c.comp (g, f))
  else Error "non-composable arrows: codomain of f <> domain of g"

(* Dual category: swap source/target, reverse composition *)
let dual_cat c =
  { source = c.target;
    target = c.source;
    ident  = c.ident;
    comp   = (fun (g, f) -> c.comp (f, g)) }