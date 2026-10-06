(* ============================================================================
   Limits — duality-converted limits (Ch4.8) and limits in FinSet (Ch4.9).
   ============================================================================ *)

(* ============================================================================
   Terminal object, product, equalizer for FinSet (Ch4.9)
   ============================================================================ *)

(* Terminal object in FinSet: one element set {TTrue} *)
let set_terminal =
  (Finite_sets.singleton Finite_sets.TTrue,
   fun a -> Finite_sets.SetArrow (a, (fun _ -> Finite_sets.TTrue), Finite_sets.singleton Finite_sets.TTrue))

(* Binary product in FinSet: labelled cartesian product.
   All FinSet elements are 'a tag; product pairs are Pair x y. *)
let set_product ((a, b) : 'a Finite_sets.tag Finite_sets.set * 'a Finite_sets.tag Finite_sets.set) =
  let a_cross_b =
    Finite_sets.mapset (fun (x, y) -> Finite_sets.Pair (x, y)) (Finite_sets.cartesian_prod a b)
  in
  let proj_a =
    Finite_sets.SetArrow (a_cross_b, (fun p -> match p with
      | Finite_sets.Pair (x, _) -> x | _ -> raise (Failure "proj")), a)
  in
  let proj_b =
    Finite_sets.SetArrow (a_cross_b, (fun p -> match p with
      | Finite_sets.Pair (_, y) -> y | _ -> raise (Failure "proj")), b)
  in
  let univ (p, f1, f2) =
    Finite_sets.SetArrow (p,
      (fun y -> Finite_sets.Pair (Finite_sets.set_arrow_apply f1 y,
                                 Finite_sets.set_arrow_apply f2 y)),
      a_cross_b)
  in
  ((a_cross_b, proj_a, proj_b), univ)

(* Equalizer in FinSet: subset of source where f = g *)
let set_equalizer ((f, g) : 'a Finite_sets.tag Finite_sets.set_arrow * 'a Finite_sets.tag Finite_sets.set_arrow) =
  let a = Finite_sets.set_s f in
  let e = List.filter (fun y -> Finite_sets.set_arrow_apply f y = Finite_sets.set_arrow_apply g y) a in
  ((e, Finite_sets.SetArrow (e, (fun x -> x), a)),
   fun (e1, h1) -> Finite_sets.SetArrow (e1, (fun y -> Finite_sets.set_arrow_apply h1 y), e))

(* ============================================================================
   Duality conversion: colimits -> limits (Ch4.8)
   ============================================================================ *)

(* Dual of a graph: swap source and target *)
open Graphs

let dual_graph (Graph (n, e, s, t)) = Graph (n, e, t, s)

(* Dual of a diagram *)
let dual_diagram (Diagram (g, f, a)) = Diagram (dual_graph g, f, a)

(* Convert colimiting cocone to limiting cone *)
let dual_cone ((ColimitingCocone (Cocone (a, d, sides), univ)) : ('o, 'a) Graphs.colimiting_cocone) =
  let result_cone = Cone (a, dual_diagram d, sides) in
  let universal (c1 : ('o, 'a) Graphs.cone) =
    let (Cone (a1, d1, f1)) = c1 in
    let c2 = Cocone (a1, dual_diagram d1, f1) in
    let (CoconeArrow (_, co_apex_arrow, _)) = univ c2 in
    ConeArrow (c1, co_apex_arrow, result_cone)
  in
  LimitingCone (result_cone, universal)

(* Convert colimit function to limit function *)
let dual_colimit (f : ('o, 'a) Graphs.colimit) : ('o, 'a) Graphs.limit =
  fun d -> dual_cone (f (dual_diagram d))

(* ============================================================================
   Limits in FinSet via duality (Ch4.9)
   ============================================================================ *)
let io_cp_ce_dual_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.io_cp_ce_cat =
  Universal.Io_cp_ce_cat
    (Cat.dual_cat Finite_sets.finset_cat, set_terminal, set_product, set_equalizer)

let finite_limit_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Graphs.limit =
  dual_colimit (Colimits.finite_colimit io_cp_ce_dual_finset)

let complete_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Graphs.complete_cat =
  Graphs.CompleteCat (Finite_sets.finset_cat, finite_limit_finset)