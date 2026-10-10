(* Finite multigraph instances; comma inheritance owns universals. *)
module Make (F : Finite_sets.S) : sig

  type graph
  type arrow
  val graph : nodes:F.set -> edges:(F.value * F.value * F.value) list ->
    (graph,Foundations.Category.error) result
  val nodes : graph -> F.set
  val edges : graph -> F.set
  val incidence : graph -> F.arrow
  val source : arrow -> graph
  val target : arrow -> graph
  val edge_map : arrow -> F.arrow
  val node_map : arrow -> F.arrow
  val arrow : graph -> edges:F.arrow -> nodes:F.arrow -> graph ->
    (arrow,Foundations.Category.error) result
  val category : (graph,arrow) Foundations.Category.cat
  val cocomplete : (graph,arrow) Universal.Limits.cocomplete_cat
  val complete : (graph,arrow) Universal.Limits.complete_cat
  val product : (graph,arrow) Universal.Limits.product
  module Labelled : sig
    type labelled
    type labelled_arrow
    val labelled : alphabet:F.set -> graph -> F.arrow -> (labelled,Foundations.Category.error) result
    val underlying : labelled -> graph
    val labels : labelled -> F.arrow
    val labelled_arrow : alphabet:F.set -> labelled -> arrow -> labelled ->
      (labelled_arrow,Foundations.Category.error) result
    val underlying_arrow : labelled_arrow -> arrow
    val labelled_category : F.set -> (labelled,labelled_arrow) Foundations.Category.cat
    val labelled_cocomplete : F.set -> (labelled,labelled_arrow) Universal.Limits.cocomplete_cat
  end
  module Rewriting : sig
    type rewrite_result = {
      context : graph; result : graph; context_to_host : arrow;
      context_to_result : arrow; right_to_result : arrow;
    }
    (* Elementary double-pushout rewriting only: all three maps injective;
       dangling edges are an error. No automatic match search or nonmonic rules. *)
    val rewrite : interface_to_left:arrow -> interface_to_right:arrow ->
      matched:arrow -> (rewrite_result,Foundations.Category.error) result
  end
end = struct
  module U = Finite_set_universals.Make (F)

  open Foundations.Category
  let id = Foundations.Functor.id_functor F.cat
  let x = U.product_functor
  type graph = (F.set,F.arrow,F.set) Constructions.Comma.obj
  type arrow = (F.set,F.arrow,F.arrow,F.set,F.arrow) Constructions.Comma.arrow
  let nodes = Constructions.Comma.right_object
  let edges = Constructions.Comma.left_object
  let incidence = Constructions.Comma.connecting_arrow
  let source = Constructions.Comma.source
  let target = Constructions.Comma.target
  let edge_map = Constructions.Comma.left_arrow
  let node_map = Constructions.Comma.right_arrow
  let graph ~nodes ~edges:bindings =
    let es = F.of_list (List.map (fun (e,_,_) -> e) bindings) in
    if F.cardinality es <> List.length bindings then
      Error (Malformed_graph "FinGraph: duplicate edge binding")
    else
      let* inc = F.arrow_result es (fun e ->
        match List.find_opt (fun (v,_,_) -> F.equal e v) bindings with
        | Some (_,s,t) -> Ok (F.pair s t)
        | None -> Error (Outside_domain "FinGraph incidence")) (F.cartesian_prod nodes nodes) in
      Constructions.Comma.object_ id x es inc nodes
  let arrow src ~edges:emap ~nodes:nmap tgt =
    Constructions.Comma.arrow id x src (emap,nmap) tgt
  let category = Constructions.Comma.category id x
  let colimit_with_components = Constructions.Comma.colimit_with_projections
    U.cocomplete_finset U.cocomplete_finset (Universal.Preservation.id_cocontinuous_functor F.cat) x
  let cocomplete = Constructions.Comma.cocomplete U.cocomplete_finset U.cocomplete_finset
    (Universal.Preservation.id_cocontinuous_functor F.cat) x
  let complete = Constructions.Comma.complete U.complete_finset U.complete_finset id
    U.product_continuous
  let product = Universal.Limits.product complete

  module Labelled = struct
    type labelled = {body:graph;labelling:F.arrow}
    type labelled_arrow = {lsrc:labelled;mapping:arrow;ltgt:labelled}
    let underlying g = g.body
    let labels g = g.labelling
    let underlying_arrow a = a.mapping
    let labelled ~alphabet body labelling =
      if has_endpoints F.cat labelling (edges body) alphabet then Ok {body;labelling}
      else Error (Non_composable "labelled graph: edge labels")
    let labelled_arrow ~alphabet src mapping tgt =
      if not (has_endpoints category mapping src.body tgt.body &&
        F.seteq (F.target src.labelling) alphabet &&
        F.seteq (F.target tgt.labelling) alphabet) then
        Error (Non_composable "labelled graph arrow: endpoints/alphabet")
      else
        let* carried = F.compose tgt.labelling (edge_map mapping) in
        if F.equal_arrow carried src.labelling then Ok {lsrc=src;mapping;ltgt=tgt}
        else Error (Non_commuting "labelled graph: labels not preserved")
    let labelled_category alphabet =
      let equal_obj a b = category.equal_obj a.body b.body &&
        F.equal_arrow a.labelling b.labelling in
      let ident g = {lsrc=g;mapping=category.ident g.body;ltgt=g} in
      let comp (g,f) =
        if not (equal_obj f.ltgt g.lsrc) then Error (Non_composable "labelled composition")
        else let* a = compose category g.mapping f.mapping in
          labelled_arrow ~alphabet f.lsrc a g.ltgt in
      {source=(fun a -> a.lsrc);target=(fun a -> a.ltgt);ident;comp;equal_obj;
       equal_arr=(fun a b -> equal_obj a.lsrc b.lsrc && equal_obj a.ltgt b.ltgt &&
         category.equal_arr a.mapping b.mapping)}
    let labelled_cocomplete alphabet =
      let cat = labelled_category alphabet in
      let forget = {Foundations.Functor.f_dom=cat;f_cod=category;
        f_omap=underlying;f_amap=(fun a -> Ok a.mapping)} in
      let colimit d =
        let* gd = Universal.Diagrams.map_diagram forget d in
        let* gc,ec,_ = colimit_with_components gd in
        let* sides = traverse (fun n ->
          let* g = Universal.Diagrams.node_object d n in Ok (n,g.labelling)) (Universal.Diagrams.diagram_nodes d) in
        let* labels_cone = Universal.Diagrams.cocone (Universal.Diagrams.cocone_base ec.Universal.Limits.colim_cocone)
          alphabet ~sides in
        let* labels_arrow = ec.Universal.Limits.colim_univ labels_cone in
        let* apex = labelled ~alphabet (Universal.Diagrams.cocone_apex gc.Universal.Limits.colim_cocone)
          (Universal.Diagrams.cocone_apex_arrow labels_arrow) in
        let* sides = traverse (fun n ->
          let* src = Universal.Diagrams.node_object d n in
          let* map = Universal.Diagrams.cocone_side gc.Universal.Limits.colim_cocone n in
          let* a = labelled_arrow ~alphabet src map apex in Ok (n,a)) (Universal.Diagrams.diagram_nodes d) in
        let* result = Universal.Diagrams.cocone d apex ~sides in
        let univ other =
          let* image = Universal.Diagrams.map_cocone forget other in
          let* u = gc.Universal.Limits.colim_univ image in
          let* a = labelled_arrow ~alphabet apex (Universal.Diagrams.cocone_apex_arrow u)
            (Universal.Diagrams.cocone_apex other) in
          Universal.Diagrams.cocone_arrow result a other in
        Ok {Universal.Limits.colim_cocone=result;colim_univ=univ} in
      {Universal.Limits.cc_cat=cat;cc_colimit=colimit}

  end
  module Rewriting = struct
    type rewrite_result = {
      context:graph;result:graph;context_to_host:arrow;
      context_to_result:arrow;right_to_result:arrow;
    }
    let injective a =
      let* xs = traverse (F.apply a) (F.to_list (F.source a)) in
      Ok (F.cardinality (F.of_list xs) = F.cardinality (F.source a))
    let monic a =
      let* e = injective (edge_map a) in let* n = injective (node_map a) in Ok (e && n)
    let rewrite ~interface_to_left:l ~interface_to_right:r ~matched:m =
      if not (category.equal_obj (source l) (source r) &&
              category.equal_obj (target l) (source m)) then
        Error (Non_composable "DPO: interface and match endpoints")
      else
        let* ml = monic l in let* mr = monic r in let* mm = monic m in
        if not (ml && mr && mm) then
        Error (Malformed_graph "DPO: injective rule legs and match required")
      else
        let image a s =
          let* xs = traverse (F.apply a) (F.to_list s) in Ok (F.of_list xs) in
        let* kept_n = image (node_map l) (nodes (source l)) in
        let* kept_e = image (edge_map l) (edges (source l)) in
        let* deleted_n = image (node_map m) (F.diff (nodes (target l)) kept_n) in
        let* deleted_e = image (edge_map m) (F.diff (edges (target l)) kept_e) in
        let host = target m in
        let remaining_n = F.diff (nodes host) deleted_n in
        let remaining_e = F.diff (edges host) deleted_e in
        let* bindings = traverse (fun e ->
          let* v = F.apply (incidence host) e in match F.view v with
          | F.Pair (s,t) when F.member s remaining_n && F.member t remaining_n ->
            Ok (e,s,t)
          | F.Pair _ -> Error (Malformed_graph "DPO: dangling edge")
          | _ -> Error (Malformed_graph "DPO: pair incidence")) (F.to_list remaining_e) in
        let* context = graph ~nodes:remaining_n ~edges:bindings in
        let* en = F.arrow remaining_e (fun v -> v) (edges host) in
        let* nn = F.arrow remaining_n (fun v -> v) (nodes host) in
        let* context_to_host = arrow context ~edges:en ~nodes:nn host in
        let* em = F.compose (edge_map m) (edge_map l) in
        let* nm = F.compose (node_map m) (node_map l) in
        let* ei = F.arrow_result (edges (source l)) (F.apply em) remaining_e in
        let* ni = F.arrow_result (nodes (source l)) (F.apply nm) remaining_n in
        let* into_context = arrow (source l) ~edges:ei ~nodes:ni context in
        let* po,_ = Universal.Limits.pushout cocomplete (into_context,r) in
        Ok {context;result=po.Universal.Limits.pushout_obj;context_to_host;
          context_to_result=po.Universal.Limits.pushout_leg1;right_to_result=po.Universal.Limits.pushout_leg2}
  end

end
