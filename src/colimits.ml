(* ============================================================================
   Colimits — general construction of finite colimits (Ch4.5 Thm 1)
   and colimits in FinSet (Ch4.6, Ch4.7).
   ============================================================================ *)

(* ============================================================================
   Building blocks from Ch4.2 (initial objects, coproducts, coequalizers)
   ============================================================================ *)

(* Initial object in FinSet: empty set *)
let set_initial : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.initial_obj =
  (Finite_sets.emptyset,
   fun a -> Finite_sets.SetArrow (Finite_sets.emptyset, (fun x -> raise (Failure "empty function")), a))

(* Binary coproduct in FinSet: labelled disjoint union.
   All elements are of type 'a tag; sum elements are Pink x / Blue x for x : 'a tag. *)
let set_coproduct ((a, b) : 'a Finite_sets.set * 'a Finite_sets.set) =
  let sumab =
    Finite_sets.mapset (fun x -> Finite_sets.Pink x) a
    @ Finite_sets.mapset (fun x -> Finite_sets.Blue x) b
  in
  let univ (c, Finite_sets.SetArrow (_, f, _), Finite_sets.SetArrow (_, g, _)) =
    let fg = function
      | Finite_sets.Pink x -> f x
      | Finite_sets.Blue x -> g x
      | _ -> raise (Failure "unexpected coproduct value")
    in
    Finite_sets.SetArrow (sumab, fg, c)
  in
  ((sumab,
    Finite_sets.SetArrow (a, (fun x -> Finite_sets.Pink x), sumab),
    Finite_sets.SetArrow (b, (fun x -> Finite_sets.Blue x), sumab)),
   univ)

(* Coequalizer in FinSet: equivalence class construction (Ch4.6) *)
let rec set_coequalizer ((Finite_sets.SetArrow (s, f, b), Finite_sets.SetArrow (_, g, _))) =
  let ident = Finite_sets.set_ident in
  if Finite_sets.is_empty s then
    ((b, ident b), fun (_, j) -> j)
  else if Finite_sets.cardinality s = 1 then
    let (y, _) = Finite_sets.singleton_split s in
    if f y = g y then
      ((b, ident b), fun (_, j) -> j)
    else
      let b' = Finite_sets.diff b [g y] in
      let ff z = if z = g y then f y else z in
      ((b', Finite_sets.SetArrow (b, ff, b')),
       fun (d', Finite_sets.SetArrow (_, j, _)) -> Finite_sets.SetArrow (b', j, d'))
  else
    let (a, a') = Finite_sets.split s in
    let ((_, q), univ) = set_coequalizer (Finite_sets.SetArrow (a, f, b), Finite_sets.SetArrow (a, g, b)) in
    let ((d, r), univ') =
      set_coequalizer
        (Finite_sets.set_comp q (Finite_sets.SetArrow (a', f, b)),
         Finite_sets.set_comp q (Finite_sets.SetArrow (a', g, b)))
    in
    ((d, Finite_sets.set_comp r q),
     fun (d', j) -> univ' (d', univ (d', j)))

(* ============================================================================
   Finite coproducts from initial object and binary coproducts (Ch4.5 Lemma 1)
   ============================================================================ *)
let rec finite_coproduct (c : ('o, 'a) Cat.cat)
    (init : ('o, 'a) Universal.initial_obj)
    (b_coprod : ('o, 'a) Universal.coproduct)
    (d : ('o, 'a) Graphs.diagram) : ('o, 'a) Graphs.colimiting_cocone =
  let open Graphs in
  let nodes = diagram_nodes d in
  if Finite_sets.is_empty nodes then
    let (i, i_univ) = init in
    let i_cocone = Cocone (i, d, fun n -> raise (Failure "empty base")) in
    (ColimitingCocone (i_cocone, fun c1 -> CoconeArrow (i_cocone, i_univ (cocone_apex c1), c1)))
  else
    let (n, n_rest) = Finite_sets.singleton_split nodes in
    let reduced = Diagram (diagram_graph d, diagram_node_objs d, diagram_edge_arrows d) in
    let (ColimitingCocone (coc, univc)) = finite_coproduct c init b_coprod reduced in
    let apex = cocone_apex coc in
    let obj_at_n = diagram_node_objs d n in
    let ((b, f, g), univcp) = b_coprod (apex, obj_at_n) in
    let result_cocone =
      Cocone (b, d, fun m -> if m = n then g else Cat.compose c f (cocone_sides coc m))
    in
    let universal c1 =
      let u = cocone_apex_arrow (univc c1) in
      let v = univcp (cocone_apex c1, u, cocone_sides c1 n) in
      CoconeArrow (result_cocone, v, c1)
    in
    ColimitingCocone (result_cocone, universal)

(* ============================================================================
   add_edge: coequalize to account for diagram edges (Ch4.5 Lemma 2)
   ============================================================================ *)
let add_edge (c : ('o, 'a) Cat.cat) (coeq : ('o, 'a) Universal.coequalizer)
    ((Graphs.ColimitingCocone (coc, univ)), e) =
  let open Graphs in
  let d = cocone_base coc in
  let g = diagram_graph d in
  let (_, edges, src, tgt) =
    match g with Graph (n, e', s, t) -> (n, e', s, t)
  in
  let node_objs = diagram_node_objs d in
  let edge_arrows = diagram_edge_arrows d in
  let side = cocone_sides coc in
  let ((b, h), ce_univ) =
    coeq (side (src e), Cat.compose c (side (tgt e)) (edge_arrows e))
  in
  let result_graph = Graph (diagram_nodes d, edges @ [e], src, tgt) in
  let result_diagram = Diagram (result_graph, node_objs, edge_arrows) in
  let result_cocone = Cocone (b, result_diagram, fun n -> Cat.compose c h (side n)) in
  let universal c1 =
    let u = cocone_apex_arrow (univ c1) in
    let v = ce_univ (cocone_apex c1, u) in
    CoconeArrow (result_cocone, v, c1)
  in
  ColimitingCocone (result_cocone, universal)

(* ============================================================================
   finite_colimit: arbitrary finite colimits (Ch4.5 Thm 1)
   ============================================================================ *)
let rec finite_colimit (cC : ('o, 'a) Universal.io_cp_ce_cat) (d : ('o, 'a) Graphs.diagram) =
  let open Graphs in
  let (Io_cp_ce_cat (c, init, b_coprod, coeq)) = cC in
  let edges = diagram_edges d in
  if Finite_sets.is_empty edges then
    finite_coproduct c init b_coprod d
  else
    let (e, e_rest) = Finite_sets.singleton_split edges in
    let (_, _, src, tgt) =
      match diagram_graph d with Graph (n, _, s, t) -> (n, [], s, t)
    in
    let d1 = Diagram (Graph (diagram_nodes d, e_rest, src, tgt), diagram_node_objs d, diagram_edge_arrows d) in
    add_edge c coeq (finite_colimit cC d1, e)

(* ============================================================================
   Colimits in FinSet (Ch4.6)
   ============================================================================ *)
let io_cp_ce_finset : ('a Finite_sets.tag Finite_sets.set, 'a Finite_sets.tag Finite_sets.set_arrow) Universal.io_cp_ce_cat =
  Universal.Io_cp_ce_cat
    (Finite_sets.finset_cat, set_initial, set_coproduct, set_coequalizer)

let finite_colimit_finset : ('a Finite_sets.tag Finite_sets.set, 'a Finite_sets.tag Finite_sets.set_arrow) Graphs.colimit =
  fun d -> finite_colimit io_cp_ce_finset d

let cocomplete_finset : ('a Finite_sets.tag Finite_sets.set, 'a Finite_sets.tag Finite_sets.set_arrow) Graphs.cocomplete_cat =
  Graphs.CocompleteCat (Finite_sets.finset_cat, (fun d -> finite_colimit io_cp_ce_finset d))