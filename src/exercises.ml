(* ============================================================================
   Exercise 1: Pushouts in Set (Ch4.2.3 / Ch4.7)
   ============================================================================ *)

(* A pushout of f : a → b and g : a → c in a category is a pair of arrows
   p : b → d and q : c → d such that the square commutes and the universal
   condition holds. In Set/FinSet, pushouts are constructed as a disjoint union
   followed by a quotient by an equivalence relation.

   The construction:
   Let f : a → b and g : a → c. Let b ] c be the disjoint union of b and c
   with injection functions jb : b → b ] c and jc : c → b ] c.
   Define the relation → by x → y iff there is a z ∈ a with jbf(z) = x and
   jcg(z) = y. Let d be the set of equivalence classes of b ] c under the
   equivalence closure of →. Then d is the pushout object.

   The cocone has:
   - base = b ] c (the disjoint union)
   - sides: from node a is the labeling function (pink/blue), from node b is
     the identification function, from node c is the identification function.
*)

(* ============================================================================
   Helper: Disjoint union of two sets using Pink/Blue labelling
   ============================================================================ *)
let disjoint_union a b =
  Finite_sets.mapset (fun x -> Finite_sets.Pink x) a
  @ Finite_sets.mapset (fun x -> Finite_sets.Blue x) b

(* ============================================================================
   pushout_diagram: Build the pushout diagram graph for FinSet.
   Graph type in this codebase: Graph of (nodes) * (edges) * (source fn) * (target fn).
   ============================================================================ *)
let pushout_diagram (f : 'a Finite_sets.set_arrow) (g : 'a Finite_sets.set_arrow) : Graphs.diagram =
  let node_a = Finite_sets.set_s f in
  let node_b = Finite_sets.set_t f in
  let node_c = Finite_sets.set_t g in
  (* 4-tuple for Graph: (nodes, edges, src_fn, tgt_fn) *)
  let edges =
    Graphs.Graph (["a"; "b"; "c"], ["f"; "g"],
      (fun n -> match n with "f" -> node_a | "g" -> node_a | _ -> raise (Failure "bad node")),
      (fun n -> match n with "f" -> node_b | "g" -> node_c | _ -> raise (Failure "bad node"))) in
  let node_objs = [node_a; node_b; node_c] in
  let edge_arrs = [Finite_sets.SetArrow (node_a, f, node_b); Finite_sets.SetArrow (node_a, g, node_c)] in
  Graphs.Diagram (edges, node_objs, edge_arrs)

(* ============================================================================
   pullback_finset: compute the pullback of g with f' in FinSet
   ============================================================================ *)
let pullback_finset (f : 'a Finite_sets.set_arrow) (g : 'a Finite_sets.set_arrow) =
  let g_shape =
    Graphs.Graph (["b"; "c"; "a"], ["f"; "g"],
      (fun n -> match n with "f" -> "b" | "g" -> "a" | _ -> raise (Failure "bad node")),
      (fun n -> match n with "f" -> "a" | "g" -> "a" | _ -> raise (Failure "node")) in
  let node_obj n =
    match n with
    | "b" -> Finite_sets.set_t f
    | "c" -> Finite_sets.set_t g
    | "a" -> Finite_sets.set_s f
    | _ -> raise (Failure "node")
  in
  let edge_arr e =
    match e with
    | "f" -> f
    | "g" -> g
    | _ -> raise (Failure "edge")
  in
  let pb_diagram = Graphs.Diagram (g_shape, node_obj, edge_arr) in
  let (Limits.CompleteCat (_, limit)) = Limits.complete_finset in
  let (Limits.LimitingCone (cone, univ)) = limit pb_diagram in
  let apex = Limits.cone_apex cone in
  let sides = Limits.cone_sides cone in
  ((sides "b", sides "c"), apex, univ)

(* ============================================================================
   relation_compose_finset: Compose relations via pullback (Ch4.10)
   ============================================================================ *)
let relation_compose_finset ((f', g') : ('a Finite_sets.set, 'a Finite_sets.set_arrow) span)
    ((f, g) : ('a Finite_sets.set, 'a Finite_sets.set_arrow) span) =
  (* Compose (f,g) with (f',g'): pullback of g with f' *)
  let ((p, p'), _, _) = pullback_finset g f' in
  (Finite_sets.set_comp f p, Finite_sets.set_comp g' p')
end