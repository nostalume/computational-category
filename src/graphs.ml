(* ============================================================================
   Graphs and Diagrams — diagram, cocones, cones, colimits, limits (Ch4.4, Ch4.8).
   ============================================================================ *)

(* Graph: nodes, edges, source, target *)
type graph = Graph of
  string list *   (* nodes *)
  string list *   (* edges *)
  (string -> string) *  (* source *)
  (string -> string)    (* target *)

(* Diagram: graph shape + node->object + edge->arrow *)
type ('o, 'a) diagram = Diagram of
  graph *
  (string -> 'o) *
  (string -> 'a)

(* Cocone: apex + base diagram + sides (node -> arrow) *)
type ('o, 'a) cocone = Cocone of
  'o * ('o, 'a) diagram * (string -> 'a)

(* Cocone arrow *)
type ('o, 'a) cocone_arrow = CoconeArrow of
  ('o, 'a) cocone * 'a * ('o, 'a) cocone

(* Colimiting cocone *)
type ('o, 'a) colimiting_cocone = ColimitingCocone of
  ('o, 'a) cocone * (('o, 'a) cocone -> ('o, 'a) cocone_arrow)

(* Colimit: diagram -> colimiting cocone *)
type ('o, 'a) colimit = ('o, 'a) diagram -> ('o, 'a) colimiting_cocone

(* Cococomplete category *)
type ('o, 'a) cocomplete_cat = CocompleteCat of
  ('o, 'a) Cat.cat * ('o, 'a) colimit

(* Cone (dual to cocone) *)
type ('o, 'a) cone = Cone of
  'o * ('o, 'a) diagram * (string -> 'a)

type ('o, 'a) cone_arrow = ConeArrow of
  ('o, 'a) cone * 'a * ('o, 'a) cone

type ('o, 'a) limiting_cone = LimitingCone of
  ('o, 'a) cone * (('o, 'a) cone -> ('o, 'a) cone_arrow)

type ('o, 'a) limit = ('o, 'a) diagram -> ('o, 'a) limiting_cone

type ('o, 'a) complete_cat = CompleteCat of
  ('o, 'a) Cat.cat * ('o, 'a) limit

(* ============================================================================
   Accessors
   ============================================================================ *)
let cocone_apex (Cocone (a, _, _)) = a
let cocone_base (Cocone (_, d, _)) = d
let cocone_sides (Cocone (_, _, s)) = s
let cocone_apex_arrow (CoconeArrow (_, a, _)) = a
let cone_apex (Cone (a, _, _)) = a
let cone_base (Cone (_, d, _)) = d
let cone_sides (Cone (_, _, s)) = s

let diagram_graph (Diagram (g, _, _)) = g
let diagram_nodes (Diagram (Graph (n, _, _, _), _, _)) = n
let diagram_edges (Diagram (Graph (_, e, _, _), _, _)) = e
let diagram_node_objs (Diagram (_, f, _)) = f
let diagram_edge_arrows (Diagram (_, _, g)) = g

let graph_src (Graph (_, _, s, _)) = s
let graph_tgt (Graph (_, _, _, t)) = t