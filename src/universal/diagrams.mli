(* Complete immutable bindings; dictionary lawfulness and stability remain caller premises. *)
type graph
type ('o, 'a) diagram
type ('o, 'a) cocone
type ('o, 'a) cone
type ('o, 'a) cocone_arrow
type ('o, 'a) cone_arrow

val graph :
  nodes:string list -> edges:(string * string * string) list ->
  (graph, Foundations.Category.error) result
val graph_nodes : graph -> string list
val graph_edges : graph -> string list
val graph_source : graph -> string -> (string, Foundations.Category.error) result
val graph_target : graph -> string -> (string, Foundations.Category.error) result
val diagram :
  ('o, 'a) Foundations.Category.cat -> graph ->
  objects:(string * 'o) list -> arrows:(string * 'a) list ->
  (('o, 'a) diagram, Foundations.Category.error) result
val diagram_graph : ('o, 'a) diagram -> graph
val diagram_category : ('o, 'a) diagram -> ('o, 'a) Foundations.Category.cat
val diagram_nodes : ('o, 'a) diagram -> string list
val diagram_edges : ('o, 'a) diagram -> string list
val node_object : ('o, 'a) diagram -> string -> ('o, Foundations.Category.error) result
val edge_arrow : ('o, 'a) diagram -> string -> ('a, Foundations.Category.error) result
val same_base : ('o, 'a) diagram -> ('o, 'a) diagram -> bool
val cocone :
  ('o, 'a) diagram -> 'o -> sides:(string * 'a) list ->
  (('o, 'a) cocone, Foundations.Category.error) result
val cone :
  ('o, 'a) diagram -> 'o -> sides:(string * 'a) list ->
  (('o, 'a) cone, Foundations.Category.error) result
val cocone_apex : ('o, 'a) cocone -> 'o
val cocone_base : ('o, 'a) cocone -> ('o, 'a) diagram
val cocone_side : ('o, 'a) cocone -> string -> ('a, Foundations.Category.error) result
val cone_apex : ('o, 'a) cone -> 'o
val cone_base : ('o, 'a) cone -> ('o, 'a) diagram
val cone_side : ('o, 'a) cone -> string -> ('a, Foundations.Category.error) result
val cocone_arrow :
  ('o, 'a) cocone -> 'a -> ('o, 'a) cocone ->
  (('o, 'a) cocone_arrow, Foundations.Category.error) result
val cone_arrow :
  ('o, 'a) cone -> 'a -> ('o, 'a) cone ->
  (('o, 'a) cone_arrow, Foundations.Category.error) result
val cocone_apex_arrow : ('o, 'a) cocone_arrow -> 'a
val cocone_arrow_domain : ('o, 'a) cocone_arrow -> ('o, 'a) cocone
val cocone_arrow_codomain : ('o, 'a) cocone_arrow -> ('o, 'a) cocone
val cone_apex_arrow : ('o, 'a) cone_arrow -> 'a
val cone_arrow_domain : ('o, 'a) cone_arrow -> ('o, 'a) cone
val cone_arrow_codomain : ('o, 'a) cone_arrow -> ('o, 'a) cone

val dual_graph : graph -> graph
val dual_diagram : ('o, 'a) diagram -> ('o, 'a) diagram
val dual_cocone : ('o, 'a) cocone -> ('o, 'a) cone
val dual_cone : ('o, 'a) cone -> ('o, 'a) cocone
val dual_cocone_arrow : ('o, 'a) cocone_arrow -> ('o, 'a) cone_arrow
val dual_cone_arrow : ('o, 'a) cone_arrow -> ('o, 'a) cocone_arrow
type ('o,'a) diagram_arrow
val diagram_arrow : ('o,'a) diagram -> ('o,'a) diagram ->
  components:(string * 'a) list -> (('o,'a) diagram_arrow,Foundations.Category.error) result
val diagram_arrow_domain : ('o,'a) diagram_arrow -> ('o,'a) diagram
val diagram_arrow_codomain : ('o,'a) diagram_arrow -> ('o,'a) diagram
val diagram_component : ('o,'a) diagram_arrow -> string -> ('a,Foundations.Category.error) result
val diagrams_category : ('o,'a) Foundations.Category.cat -> graph ->
  (('o,'a) diagram,('o,'a) diagram_arrow) Foundations.Category.cat
type ('o,'a) cocone_map
type ('o,'a) cone_map
val cocone_map : ('o,'a) cocone -> ('o,'a) diagram_arrow -> 'a ->
  ('o,'a) cocone -> (('o,'a) cocone_map,Foundations.Category.error) result
val cone_map : ('o,'a) cone -> ('o,'a) diagram_arrow -> 'a ->
  ('o,'a) cone -> (('o,'a) cone_map,Foundations.Category.error) result
val cocone_map_domain : ('o,'a) cocone_map -> ('o,'a) cocone
val cocone_map_codomain : ('o,'a) cocone_map -> ('o,'a) cocone
val cocone_map_base : ('o,'a) cocone_map -> ('o,'a) diagram_arrow
val cocone_map_apex : ('o,'a) cocone_map -> 'a
val cone_map_domain : ('o,'a) cone_map -> ('o,'a) cone
val cone_map_codomain : ('o,'a) cone_map -> ('o,'a) cone
val cone_map_base : ('o,'a) cone_map -> ('o,'a) diagram_arrow
val cone_map_apex : ('o,'a) cone_map -> 'a
val total_cocone_category : ('o,'a) Foundations.Category.cat -> graph ->
  (('o,'a) cocone,('o,'a) cocone_map) Foundations.Category.cat
val total_cone_category : ('o,'a) Foundations.Category.cat -> graph ->
  (('o,'a) cone,('o,'a) cone_map) Foundations.Category.cat

(* Restrictions preserve admission without invoking dictionary callbacks.
   discrete_tail drops the first node and all edges; without_first_edge drops
   only the first edge (an edgeless diagram is unchanged). *)
val discrete_tail : ('o,'a) diagram -> ('o,'a) diagram
val without_first_edge : ('o,'a) diagram -> ('o,'a) diagram
val graph_bindings : graph -> (string * string * string) list
val cocone_sides : ('o,'a) cocone -> (string * 'a) list
val map_diagram : ('oa,'aa,'ob,'ab) Foundations.Functor.cat_functor ->
  ('oa,'aa) diagram -> (('ob,'ab) diagram,Foundations.Category.error) result
val map_cocone : ('oa,'aa,'ob,'ab) Foundations.Functor.cat_functor ->
  ('oa,'aa) cocone -> (('ob,'ab) cocone,Foundations.Category.error) result
val map_cone : ('oa,'aa,'ob,'ab) Foundations.Functor.cat_functor ->
  ('oa,'aa) cone -> (('ob,'ab) cone,Foundations.Category.error) result
