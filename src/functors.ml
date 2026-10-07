(* ============================================================================
   Functors — functor type, identity functor, product functor (Ch3.5),
   cocontinuous functors (Ch4.4).
   ============================================================================ *)

(* Functor type — named record. Renamed from 'functor' because that is a
   reserved OCaml keyword. *)
type ('oa, 'aa, 'ob, 'ab) cat_functor = {
  f_dom : ('oa, 'aa) Cat.cat;
  f_omap : 'oa -> 'ob;
  f_amap : 'aa -> 'ab;
  f_cod : ('ob, 'ab) Cat.cat;
}

(* Identity functor *)
let id_functor (c : ('o, 'a) Cat.cat) =
  { f_dom = c; f_omap = (fun x -> x); f_amap = (fun x -> x); f_cod = c }

(* Product functor X: FinSet -> FinSet (Ch3.5.2).
   On objects: A |-> A x A.  On arrows: f |-> f x f.
   The cartesian product yields ('a * 'a) elements; we cast to keep
   arrows homogeneous (see Limitations in README). *)
let product_functor : ('a Finite_sets.set, 'a Finite_sets.set_arrow, 'a Finite_sets.set, 'a Finite_sets.set_arrow) cat_functor =
  let obj_map a = Obj.magic (Finite_sets.cartesian_prod a a) in
  let arr_map f =
    let a = Finite_sets.set_s f in
    let b = Finite_sets.set_t f in
    let a2 = Finite_sets.cartesian_prod a a in
    let b2 = Finite_sets.cartesian_prod b b in
    let fn = Finite_sets.set_arrow_apply f in
    let raw : ('a * 'a) Finite_sets.set_arrow =
      { Finite_sets.sa_src = a2; sa_fn = (fun (x, y) -> (fn x, fn y)); sa_tgt = b2 }
    in
    Obj.magic raw
  in
  { f_dom = Finite_sets.finset_cat;
    f_omap = obj_map;
    f_amap = arr_map;
    f_cod = Finite_sets.finset_cat }

(* Dual functor (Ch3.6): same maps between dual categories *)
let dual_functor (f : ('oa, 'aa, 'ob, 'ab) cat_functor) =
  { f_dom = Cat.dual_cat f.f_dom;
    f_omap = f.f_omap;
    f_amap = f.f_amap;
    f_cod = Cat.dual_cat f.f_cod }

(* Cocontinuous functor (Ch4.4): functor + map between colimiting cocones *)
type ('oa, 'aa, 'ob, 'ab) cocontinuous_functor = {
  cc_functor : ('oa, 'aa, 'ob, 'ab) cat_functor;
  cc_map : ('oa, 'aa) Graphs.colimiting_cocone -> ('ob, 'ab) Graphs.colimiting_cocone;
}

(* Identity functor is cocontinuous *)
let id_cocontinuous_functor (c : ('o, 'a) Cat.cat) =
  { cc_functor = id_functor c; cc_map = (fun cc -> cc) }