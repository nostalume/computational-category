(* Finite directed-graph exponentials and classifiers.  They are computed for
   the repository's incidence
   orientation: edges map to (source,target) node pairs. *)
module Make (F : Finite_sets.S) : sig
  type graph
  type graph_morphism
  val graph : nodes:F.carrier -> edges:(F.value * F.value * F.value) list ->
    (graph, Foundations.Category.error) result
  val nodes : graph -> F.carrier
  val edges : graph -> F.carrier
  val incidence : graph -> F.morphism
  val graph_morphism : graph -> edges:F.morphism -> nodes:F.morphism -> graph ->
    (graph_morphism, Foundations.Category.error) result
  val source : graph_morphism -> graph
  val target : graph_morphism -> graph
  val edge_map : graph_morphism -> F.morphism
  val node_map : graph_morphism -> F.morphism
  type exponential_data = {
    exponential : graph;
    evaluation : graph_morphism;
    curry : graph -> graph_morphism ->
      (graph_morphism, Foundations.Category.error) result;
  }
  val exponential : graph -> graph ->
    (exponential_data, Foundations.Category.error) result
  type classifier = {
    omega : graph;
    truth : graph_morphism;
    character : graph_morphism ->
      (graph_morphism, Foundations.Category.error) result;
  }
  val classifier : unit -> classifier
end
