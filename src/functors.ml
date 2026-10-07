(* ============================================================================
   Functors — functor type, identity functor, product functor (Ch3.5),
   cocontinuous functors (Ch4.4).
   ============================================================================ *)

(* Functor type — renamed from 'functor' to avoid OCaml keyword conflict *)
type ('oa, 'aa, 'ob, 'ab) f_functor = FFunctor of
  ('oa, 'aa) Cat.cat * ('oa -> 'ob) * ('aa -> 'ab) * ('ob, 'ab) Cat.cat

(* Identity functor *)
let id_functor (c : ('o, 'a) Cat.cat) =
  FFunctor (c, (fun x -> x), (fun x -> x), c)

(* Product functor X: FinSet -> FinSet (Ch3.5.2).
   On objects: A |-> A x A.  On arrows: f |-> f x f.
   The cartesian product yields ('a * 'a) elements; we cast to keep
   arrows homogeneous (see Limitations in README). *)
let product_functor : ('a Finite_sets.set, 'a Finite_sets.set_arrow, 'a Finite_sets.set, 'a Finite_sets.set_arrow) f_functor =
  let obj_map a = Obj.magic (Finite_sets.cartesian_prod a a) in
  let arr_map f =
    let a = Finite_sets.set_s f in
    let b = Finite_sets.set_t f in
    let a2 = Finite_sets.cartesian_prod a a in
    let b2 = Finite_sets.cartesian_prod b b in
    let fn = Finite_sets.set_arrow_apply f in
    (* Cast the pair-arrow to a homogeneous set_arrow *)
    let raw : ('a * 'a) Finite_sets.set_arrow =
      Finite_sets.SetArrow (a2, (fun (x, y) -> (fn x, fn y)), b2)
    in
    Obj.magic raw
  in
  FFunctor (Finite_sets.finset_cat, obj_map, arr_map, Finite_sets.finset_cat)

(* Dual functor (Ch3.6): same functions between dual categories *)
let dual_functor (f : ('oa, 'aa, 'ob, 'ab) f_functor) =
  let (FFunctor (a, fo, fa, b)) = f in
  FFunctor (Cat.dual_cat a, fo, fa, Cat.dual_cat b)

(* Cocontinuous functor (Ch4.4): functor + map between colimiting cocones *)
type ('oa, 'aa, 'ob, 'ab) cocontinuous_functor =
  CocontinuousFunctor of
    ('oa, 'aa, 'ob, 'ab) f_functor *
    (('oa, 'aa) Graphs.colimiting_cocone -> ('ob, 'ab) Graphs.colimiting_cocone)

(* Identity functor is cocontinuous *)
let id_cocontinuous_functor (c : ('o, 'a) Cat.cat) =
  let ff = id_functor c in
  CocontinuousFunctor (ff, (fun cc -> cc))