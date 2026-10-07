(* ============================================================================
   Limits — duality-converted limits (Ch4.8) and limits in FinSet (Ch4.9).
   ============================================================================ *)

(* Terminal object in FinSet: singleton set {()} *)
let set_terminal : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.terminal_obj =
  let unit_set = Finite_sets.singleton () in
  let open Obj in
  let const_arrow =
    Finite_sets.SetArrow (Finite_sets.emptyset,
      (fun _ -> Obj.magic ()), unit_set)
  in
  (unit_set, fun _ -> const_arrow)

(* Binary product in FinSet: cartesian product as plain pairs.
   Returns a set with the same element type (pairs are treated as elements). *)
let set_product ((a, b) : 'a Finite_sets.set * 'a Finite_sets.set) :
    ('a Finite_sets.set * 'a Finite_sets.set_arrow * 'a Finite_sets.set_arrow) *
    (('a Finite_sets.set * 'a Finite_sets.set_arrow * 'a Finite_sets.set_arrow) -> 'a Finite_sets.set_arrow) =
  let raw_cross = Finite_sets.cartesian_prod a b in
  let open Obj in
  (* Cast the product to the same element type as the inputs *)
  let a_cross_b : 'a Finite_sets.set = Obj.magic raw_cross in
  let proj_a : 'a Finite_sets.set_arrow =
    Finite_sets.SetArrow (a_cross_b,
      (fun p -> Obj.magic (match Obj.magic p with (x, _) -> x | _ -> raise (Failure "proj"))),
      a)
  and proj_b : 'a Finite_sets.set_arrow =
    Finite_sets.SetArrow (a_cross_b,
      (fun p -> Obj.magic (match Obj.magic p with (_, y) -> y | _ -> raise (Failure "proj"))),
      b)
  in
  let univ (p, f1, f2) =
    let fa = Finite_sets.set_arrow_apply f1 in
    let fb = Finite_sets.set_arrow_apply f2 in
    Finite_sets.SetArrow (p,
      (fun y -> Obj.magic (fa y, fb y)),
      a_cross_b)
  in
  ((a_cross_b, proj_a, proj_b), univ)

(* Equalizer in FinSet: subset of source where f = g *)
let set_equalizer ((f, g) : 'a Finite_sets.set_arrow * 'a Finite_sets.set_arrow) =
  let a = Finite_sets.set_s f in
  let e = List.filter (fun y -> Finite_sets.set_arrow_apply f y = Finite_sets.set_arrow_apply g y) a in
  let open Obj in
  let incl : 'a Finite_sets.set_arrow =
    Finite_sets.SetArrow (e, (fun x -> Obj.magic x), a)
  in
  ((e, incl),
   fun (e1, h1) ->
     Finite_sets.SetArrow (e1,
       (fun y -> Obj.magic (Finite_sets.set_arrow_apply h1 y)),
       e))

(* ============================================================================
   Duality conversion: colimits -> limits (Ch4.8)
   ============================================================================ *)
open Graphs

let dual_graph (Graph (n, e, s, t)) = Graph (n, e, t, s)

let dual_diagram (Diagram (g, f, a)) = Diagram (dual_graph g, f, a)

let dual_cone ((ColimitingCocone (Cocone (a, d, sides), univ)) : ('o, 'a) Graphs.colimiting_cocone) =
  let result_cone = Cone (a, dual_diagram d, sides) in
  let universal (c1 : ('o, 'a) Graphs.cone) =
    let (Cone (a1, d1, f1)) = c1 in
    let c2 = Cocone (a1, dual_diagram d1, f1) in
    let (CoconeArrow (_, co_apex_arrow, _)) = univ c2 in
    ConeArrow (c1, co_apex_arrow, result_cone)
  in
  LimitingCone (result_cone, universal)

let dual_colimit (f : ('o, 'a) Graphs.colimit) : ('o, 'a) Graphs.limit =
  fun d -> dual_cone (f (dual_diagram d))

(* ============================================================================
   Limits in FinSet via duality (Ch4.9)
   ============================================================================ *)
let io_cp_ce_dual_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.io_cp_ce_cat =
  Universal.Io_cp_ce_cat
    (Cat.dual_cat Finite_sets.finset_cat, set_terminal, set_product, set_equalizer)

let finite_limit_finset (d : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Graphs.diagram) :
    ('a Finite_sets.set, 'a Finite_sets.set_arrow) Graphs.limiting_cone =
  let open Graphs in
  let dual_d = dual_diagram d in
  let (ColimitingCocone (coc, univ)) = Colimits.finite_colimit_finset dual_d in
  let result_cone = Cone (cocone_apex coc, dual_diagram (cocone_base coc), cocone_sides coc) in
  let universal (c1 : ('a Finite_sets.set, 'a Finite_sets.set_arrow) cone) =
    let (Cone (a1, d1, f1)) = c1 in
    let c2 = Cocone (a1, dual_diagram d1, f1) in
    let (CoconeArrow (_, co_apex_arrow, _)) = univ c2 in
    ConeArrow (c1, co_apex_arrow, result_cone)
  in
  LimitingCone (result_cone, universal)

let complete_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Graphs.complete_cat =
  Graphs.CompleteCat (Finite_sets.finset_cat, finite_limit_finset)
