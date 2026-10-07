(* ============================================================================
   Graphs and Diagrams — diagram, cocones, cones, colimits, limits (Ch4.4, Ch4.8).
   Layer 3: all structures use named records instead of tuples.
   ============================================================================ *)

(* Finite graph: nodes, edges, source, target *)
type graph = {
  g_nodes : string list;
  g_edges : string list;
  g_src : string -> string;
  g_tgt : string -> string;
}

(* Diagram: graph shape + node -> object + edge -> arrow *)
type ('o, 'a) diagram = {
  shape : graph;
  obj_at : string -> 'o;
  arrow_at : string -> 'a;
}

(* Cocone: apex + base diagram + sides (node -> arrow) *)
type ('o, 'a) cocone = {
  apex : 'o;
  base : ('o, 'a) diagram;
  sides : string -> 'a;
}

(* Cocone arrow: a map between two cocones over the same base *)
type ('o, 'a) cocone_arrow = {
  ca_domain : ('o, 'a) cocone;
  ca_arrow : 'a;
  ca_codomain : ('o, 'a) cocone;
}

(* Colimiting cocone: a cocone plus its universality *)
type ('o, 'a) colimiting_cocone = {
  colim_cocone : ('o, 'a) cocone;
  colim_univ : ('o, 'a) cocone -> ('o, 'a) cocone_arrow;
}

(* Colimit: diagram -> colimiting cocone *)
type ('o, 'a) colimit = ('o, 'a) diagram -> ('o, 'a) colimiting_cocone

(* Cococomplete category *)
type ('o, 'a) cocomplete_cat = {
  cc_cat : ('o, 'a) Cat.cat;
  cc_colimit : ('o, 'a) colimit;
}

(* Cone (dual to cocone): used for limits *)
type ('o, 'a) cone = {
  cone_apex : 'o;
  cone_base : ('o, 'a) diagram;
  cone_sides : string -> 'a;
}

type ('o, 'a) cone_arrow = {
  ca_domain : ('o, 'a) cone;
  ca_arrow : 'a;
  ca_codomain : ('o, 'a) cone;
}

type ('o, 'a) limiting_cone = {
  lim_cone : ('o, 'a) cone;
  lim_univ : ('o, 'a) cone -> ('o, 'a) cone_arrow;
}

type ('o, 'a) limit = ('o, 'a) diagram -> ('o, 'a) limiting_cone

type ('o, 'a) complete_cat = {
  co_cat : ('o, 'a) Cat.cat;
  co_limit : ('o, 'a) limit;
}

(* ============================================================================
   Accessors (kept for compatibility with existing call sites)
   ============================================================================ *)
let cocone_apex c = c.apex
let cocone_base c = c.base
let cocone_sides c = c.sides
let cocone_apex_arrow ca = ca.ca_arrow
let cone_apex c = c.cone_apex
let cone_base c = c.cone_base
let cone_sides c = c.cone_sides

let diagram_graph d = d.shape
let diagram_nodes d = d.shape.g_nodes
let diagram_edges d = d.shape.g_edges
let diagram_node_objs d = d.obj_at
let diagram_edge_arrows d = d.arrow_at

let graph_src g = g.g_src
let graph_tgt g = g.g_tgt