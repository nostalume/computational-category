(* ============================================================================
   Relations — spans, relation composition via pullbacks (Ch4.10).
   ============================================================================ *)

(* A span is an ordered pair of arrows with common source *)
type ('o, 'a) span = 'a * 'a

(* Relation as a span: projection functions from a set of pairs *)
let unjust x =
  match x with
  | Finite_sets.Just v -> v
  | _ -> raise (Failure "expected Just")

let relation_span (a : 'a Finite_sets.set) (r : 'a Finite_sets.set) (b : 'a Finite_sets.set) : ('a Finite_sets.set, 'a Finite_sets.set_arrow) span =
  (Finite_sets.SetArrow (r, (fun p -> match p with
      | Finite_sets.Pair (x, _) -> unjust x | _ -> raise (Failure "span")), a),
   Finite_sets.SetArrow (r, (fun p -> match p with
      | Finite_sets.Pair (_, y) -> unjust y | _ -> raise (Failure "span")), b))

(* ============================================================================
   Pullback in FinSet via the complete category (Ch4.10)
   ============================================================================ *)

(* pullback of f: b -> a and g: c -> a is the limit of the cospan *)
let pullback_finset (f : 'a Finite_sets.set_arrow) (g : 'a Finite_sets.set_arrow) =
  (* Build the pullback diagram: nodes b, c with edges f,g to a *)
  let g_shape =
    Graphs.Graph (["b"; "c"; "a"], ["f"; "g"],
      (fun n -> match n with "f" -> "b" | _ -> "c"),
      (fun n -> match n with "f" -> "a" | _ -> "a"))
  in
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
   Relation composition via pullback (Ch4.10)
   ============================================================================ *)
let relation_compose_finset ((f', g') : ('a Finite_sets.set, 'a Finite_sets.set_arrow) span)
    ((f, g) : ('a Finite_sets.set, 'a Finite_sets.set_arrow) span) =
  (* Compose (f,g) with (f',g'): pullback of g with f' *)
  let ((p, p'), _, _) = pullback_finset g f' in
  (Finite_sets.set_comp f p, Finite_sets.set_comp g' p')