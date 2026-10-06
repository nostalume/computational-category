(* ============================================================================
   Functors — functor type, identity functor, product functor (Ch3.5),
   cocontinuous functors (Ch4.4).
   ============================================================================ *)

(* Functor type *)
type ('oa, 'aa, 'ob, 'ab) functor = FFunctor of
  ('oa, 'aa) Cat.cat * ('oa -> 'ob) * ('aa -> 'ab) * ('ob, 'ab) Cat.cat

(* Identity functor *)
let id_functor (c : ('o, 'a) Cat.cat) =
  FFunctor (c, fun x -> x, fun x -> x, c)

(* Product functor X: FinSet -> FinSet (Ch3.5.2) *)
let product_functor : ('a Finite_sets.set, 'a Finite_sets.set_arrow, 'a Finite_sets.set, 'a Finite_sets.set_arrow) functor =
  let prod_arrow (Finite_sets.SetArrow (A, f, B)) (Finite_sets.SetArrow (C, g, D)) =
    Finite_sets.SetArrow (
      Finite_sets.mapset (fun (x, y) -> Finite_sets.Pair (Finite_sets.Just x, Finite_sets.Just y))
        (Finite_sets.cartesian_prod A C),
      (fun (x, y) -> (f x, g y)),
      Finite_sets.mapset (fun (x, y) -> Finite_sets.Pair (Finite_sets.Just x, Finite_sets.Just y))
        (Finite_sets.cartesian_prod B D)
    )
  in
  FFunctor (
    Finite_sets.finset_cat,
    (fun a -> Finite_sets.mapset (fun (x, y) -> Finite_sets.Pair (Finite_sets.Just x, Finite_sets.Just y))
       (Finite_sets.cartesian_prod a a)),
    (fun f -> prod_arrow f f),
    Finite_sets.finset_cat
  )

(* Dual functor (Ch3.6): same functions between dual categories *)
let dual_functor (FFunctor (A, fo, fa, B)) =
  FFunctor (Cat.dual_cat A, fo, fa, Cat.dual_cat B)

(* Cocontinuous functor (Ch4.4): functor + map between colimiting cocones *)
type ('oa, 'aa, 'ob, 'ab) cocontinuous_functor =
  CocontinuousFunctor of
    ('oa, 'aa, 'ob, 'ab) functor *
    (('oa, 'aa) Graphs.colimiting_cocone -> ('ob, 'ab) Graphs.colimiting_cocone)

(* Identity functor is cocontinuous *)
let id_cocontinuous_functor (c : ('o, 'a) Cat.cat) =
  CocontinuousFunctor (id_functor c, fun cc -> cc)