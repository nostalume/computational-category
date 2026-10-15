(* Finite multigraph instances; comma inheritance owns universals. *)
module Make (F : Finite_sets.S) : sig

  type graph
  type graph_morphism
  val graph : nodes:F.carrier -> edges:(F.value * F.value * F.value) list ->
    (graph,Foundations.Category.error) result
  val nodes : graph -> F.carrier
  val edges : graph -> F.carrier
  val incidence : graph -> F.morphism
  val source : graph_morphism -> graph
  val target : graph_morphism -> graph
  val edge_map : graph_morphism -> F.morphism
  val node_map : graph_morphism -> F.morphism
  val graph_morphism : graph -> edges:F.morphism -> nodes:F.morphism -> graph ->
    (graph_morphism,Foundations.Category.error) result
  val category : (graph,graph_morphism) Foundations.Category.cat
  val cocomplete : (graph,graph_morphism) Universal.Limits.cocomplete_cat
  val complete : (graph,graph_morphism) Universal.Limits.complete_cat
  val product : (graph,graph_morphism) Universal.Limits.product
  (* One loop per vertex, D(S)=(S,S,id,id), not the edge-empty graph. *)
  val loop_graph_functor : (F.carrier,F.morphism,graph,graph_morphism) Foundations.Functor.cat_functor
  val components_adjunction : (graph,graph_morphism,F.carrier,F.morphism) Universal.Adjunction.adjunction
  module Fixed : sig
    (* Objects have exactly the declared nodes; arrows fix them pointwise.
       Category identities require admitted objects, as other dictionaries do. *)
    val category : F.carrier -> (graph,graph_morphism) Foundations.Category.cat
    val fixed_morphism : F.carrier -> graph -> F.morphism -> graph -> (graph_morphism,Foundations.Category.error) result
    val cocomplete : F.carrier -> (graph,graph_morphism) Universal.Limits.cocomplete_cat
    val isomorphisms : F.carrier -> (graph,graph_morphism) Foundations.Category.iso_cat
    val prepend : graph -> (graph,graph_morphism,graph,graph_morphism) Foundations.Functor.cat_functor
    val free_paths : bound:int -> graph ->
      (((graph,graph_morphism) Constructions.Algebras.algebra,
        (graph,graph_morphism) Constructions.Algebras.algebra_morphism,graph_morphism) Universal.Adjunction.universal_arrow,
       Foundations.Category.error) result
  end
  module Labelled : sig
    type labelled
    type labelled_morphism
    val labelled : alphabet:F.carrier -> graph -> F.morphism -> (labelled,Foundations.Category.error) result
    val underlying : labelled -> graph
    val labels : labelled -> F.morphism
    val labelled_morphism : alphabet:F.carrier -> labelled -> graph_morphism -> labelled ->
      (labelled_morphism,Foundations.Category.error) result
    val underlying_morphism : labelled_morphism -> graph_morphism
    val labelled_category : F.carrier -> (labelled,labelled_morphism) Foundations.Category.cat
    val labelled_cocomplete : F.carrier -> (labelled,labelled_morphism) Universal.Limits.cocomplete_cat
  end
  module Rewriting : sig
    type rewrite_result = {
      context : graph; result : graph; context_to_host : graph_morphism;
      context_to_result : graph_morphism; right_to_result : graph_morphism;
    }
    (* Elementary double-pushout rewriting only: all three maps injective;
       dangling edges are an error. No automatic match search or nonmonic rules. *)
    val rewrite : interface_to_left:graph_morphism -> interface_to_right:graph_morphism ->
      matched:graph_morphism -> (rewrite_result,Foundations.Category.error) result
  end
end = struct
  module U = Finite_set_universals.Make (F)

  open Foundations.Category
  let id = Foundations.Functor.id_functor F.cat
  let x = U.product_functor
  type graph = (F.carrier,F.morphism,F.carrier) Constructions.Comma.obj
  type graph_morphism = (F.carrier,F.morphism,F.morphism,F.carrier,F.morphism) Constructions.Comma.arrow
  let nodes = Constructions.Comma.right_object
  let edges = Constructions.Comma.left_object
  let incidence = Constructions.Comma.connecting_arrow
  let source = Constructions.Comma.source
  let target = Constructions.Comma.target
  let edge_map = Constructions.Comma.left_arrow
  let node_map = Constructions.Comma.right_arrow
  let graph ~nodes ~edges:bindings =
    let es = F.carrier_of_list (List.map (fun (e,_,_) -> e) bindings) in
    if F.cardinality es <> List.length bindings then
      Error (Malformed_graph "FinGraph: duplicate edge binding")
    else
      let* inc = F.morphism_result es (fun e ->
        match List.find_opt (fun (v,_,_) -> F.equal e v) bindings with
        | Some (_,s,t) -> Ok (F.pair s t)
        | None -> Error (Outside_domain "FinGraph incidence")) (F.cartesian_prod nodes nodes) in
      Constructions.Comma.object_ id x es inc nodes
  let graph_morphism src ~edges:emap ~nodes:nmap tgt =
    Constructions.Comma.arrow id x src (emap,nmap) tgt
  let category = Constructions.Comma.category id x
  let colimit_with_components = Constructions.Comma.colimit_with_projections
    U.cocomplete_finset U.cocomplete_finset (Universal.Preservation.id_cocontinuous_functor F.cat) x
  let cocomplete = Constructions.Comma.cocomplete U.cocomplete_finset U.cocomplete_finset
    (Universal.Preservation.id_cocontinuous_functor F.cat) x
  let complete = Constructions.Comma.complete U.complete_finset U.complete_finset id
    U.product_continuous
  let product = Universal.Limits.product complete

  let loop_graph s = graph ~nodes:s ~edges:(List.map (fun x -> x,x,x) (F.carrier_to_list s))
  let loop_graph_functor =
    {Foundations.Functor.f_dom=F.cat;f_cod=category;f_omap=loop_graph;
     f_amap=(fun f -> let* s = loop_graph (F.domain f) in let* t = loop_graph (F.codomain f) in
       graph_morphism s ~edges:f ~nodes:f t)}
  let components_adjunction =
    let choose g =
      let endpoint first = F.morphism_result (edges g) (fun e ->
        let* v = F.eval (incidence g) e in match F.view v with
        | F.Pair (s,t) -> Ok (if first then s else t)
        | _ -> Error (Malformed_graph "components: incidence pair")) (nodes g) in
      let* s = endpoint true in let* t = endpoint false in
      let* quotient,factor = U.coequalizer (s,t) in
      let q = quotient.Universal.Limits.coeq_arrow in
      let free_object = quotient.Universal.Limits.coeq_obj in
      let* image = loop_graph free_object in
      let* emap = F.compose q s in
      let* unit_arrow = graph_morphism g ~edges:emap ~nodes:q image in
      Ok {Universal.Adjunction.free_object;unit_arrow;
        factor=(fun target h -> factor target (node_map h))} in
    Universal.Adjunction.of_universal ~right:loop_graph_functor choose

  module Fixed = struct
    module D = Universal.Diagrams
    module L = Universal.Limits
    module S = Constructions.Spans
    let admit anchor g =
      if F.equal_carrier (nodes g) anchor then Ok () else Error (Different_base "fixed graph nodes")
    let fixed_morphism anchor s map t =
      let* () = admit anchor s in let* () = admit anchor t in
      graph_morphism s ~edges:map ~nodes:(F.identity anchor) t
    let admit_arrow anchor h =
      let* () = admit anchor (source h) in let* () = admit anchor (target h) in
      if F.equal_morphism (node_map h) (F.identity anchor) then Ok ()
      else Error (Non_commuting "fixed graph node map")
    let category anchor =
      {category with comp=(fun (g,h) ->
        let* () = admit_arrow anchor g in let* () = admit_arrow anchor h in
        if not (category.equal_obj (target h) (source g)) then Error (Non_composable "fixed graph composition")
        else let* map = F.compose (edge_map g) (edge_map h) in
          fixed_morphism anchor (source h) map (target g))}
    let from_incidence anchor carrier incidence =
      let* es = traverse (fun e -> let* v = F.eval incidence e in match F.view v with
        | F.Pair (s,t) -> Ok (e,s,t) | _ -> Error (Malformed_graph "fixed graph incidence")) (F.carrier_to_list carrier) in
      graph ~nodes:anchor ~edges:es
    let cocomplete anchor =
      let cat = category anchor in
      let forget = {Foundations.Functor.f_dom=cat;f_cod=F.cat;
        f_omap=(fun g -> let* () = admit anchor g in Ok (edges g));
        f_amap=(fun h -> let* () = admit_arrow anchor h in Ok (edge_map h))} in
      let colimit diagram =
        let* base = D.map_diagram forget diagram in let* sum = U.colimit base in
        let* sides = traverse (fun n -> let* g = D.node_object diagram n in Ok (n,incidence g))
          (D.diagram_nodes diagram) in
        let* incidences = D.cocone base (F.cartesian_prod anchor anchor) ~sides in
        let* h = sum.L.colim_univ incidences in
        let* result = from_incidence anchor (D.cocone_apex sum.L.colim_cocone) (D.cocone_apex_arrow h) in
        let* sides = traverse (fun n -> let* g = D.node_object diagram n in
          let* h = D.cocone_side sum.L.colim_cocone n in let* h = fixed_morphism anchor g h result in Ok (n,h))
          (D.diagram_nodes diagram) in
        let* cocone = D.cocone diagram result ~sides in
        let univ other =
          if not (D.same_base diagram (D.cocone_base other)) then Error (Different_base "fixed graph colimit") else
          let* candidate = D.map_cocone forget other in let* h = sum.L.colim_univ candidate in
          let* h = fixed_morphism anchor result (D.cocone_apex_arrow h) (D.cocone_apex other) in
          D.cocone_arrow cocone h other in
        Ok {L.colim_cocone=cocone;colim_univ=univ} in
      {L.cc_cat=cat;cc_colimit=colimit}
    let isomorphisms anchor =
      {iso_cat=category anchor;iso_inverse=(fun h ->
        let* () = admit_arrow anchor h in
        let* inverse = inverse U.isomorphisms (edge_map h) in match inverse with
        | None -> Ok None | Some k -> let* k = fixed_morphism anchor (target h) k (source h) in Ok (Some k))}
    let endpoints g =
      let endpoint first = F.morphism_result (edges g) (fun e ->
        let* v = F.eval (incidence g) e in match F.view v with
        | F.Pair (s,t) -> Ok (if first then s else t)
        | _ -> Error (Malformed_graph "fixed graph endpoints")) (nodes g) in
      let* s = endpoint true in let* t = endpoint false in Ok (s,t)
    let prepend g =
      let anchor = nodes g in
      let objects h =
        let* () = admit anchor h in let* gs,gt = endpoints g in let* hs,ht = endpoints h in
        let* g = S.span F.cat gs gt in let* h = S.span F.cat hs ht in
        let* composed = S.compose U.complete_finset h g in
        let* incidence = F.morphism_result (S.span_source composed) (fun e ->
          let* s = F.eval (S.span_left composed) e in
          let* t = F.eval (S.span_right composed) e in Ok (F.pair s t)) (F.cartesian_prod anchor anchor) in
        from_incidence anchor (S.span_source composed) incidence in
      let arrows h =
        let* () = admit_arrow anchor h in
        let* _,gt = endpoints g in let* hs,_ = endpoints (source h) in let* ht,_ = endpoints (target h) in
        let* p,_ = U.pullback (gt,hs) in let* _,factor = U.pullback (gt,ht) in
        let* right = F.compose (edge_map h) p.L.pullback_proj2 in
        let* map = factor p.L.pullback_obj p.L.pullback_proj1 right in
        let* s = objects (source h) in let* t = objects (target h) in fixed_morphism anchor s map t in
      {Foundations.Functor.f_dom=category anchor;f_cod=category anchor;f_omap=objects;f_amap=arrows}
    let free_paths ~bound g =
      let c = cocomplete (nodes g) and iso = isomorphisms (nodes g) in
      let preserving = Universal.Preservation.by_comparison (prepend g) c iso in
      Constructions.Algebras.Free.coproduct ~cocomplete:c ~isomorphisms:iso ~preserving ~bound g
  end

  module Labelled = struct
    type labelled = {body:graph;labelling:F.morphism}
    type labelled_morphism = {lsrc:labelled;mapping:graph_morphism;ltgt:labelled}
    let underlying g = g.body
    let labels g = g.labelling
    let underlying_morphism a = a.mapping
    let labelled ~alphabet body labelling =
      if has_endpoints F.cat labelling (edges body) alphabet then Ok {body;labelling}
      else Error (Non_composable "labelled graph: edge labels")
    let labelled_morphism ~alphabet src mapping tgt =
      if not (has_endpoints category mapping src.body tgt.body &&
        F.equal_carrier (F.codomain src.labelling) alphabet &&
        F.equal_carrier (F.codomain tgt.labelling) alphabet) then
        Error (Non_composable "labelled graph arrow: endpoints/alphabet")
      else
        let* carried = F.compose tgt.labelling (edge_map mapping) in
        if F.equal_morphism carried src.labelling then Ok {lsrc=src;mapping;ltgt=tgt}
        else Error (Non_commuting "labelled graph: labels not preserved")
    let labelled_category alphabet =
      let equal_obj a b = category.equal_obj a.body b.body &&
        F.equal_morphism a.labelling b.labelling in
      let ident g = {lsrc=g;mapping=category.ident g.body;ltgt=g} in
      let comp (g,f) =
        if not (equal_obj f.ltgt g.lsrc) then Error (Non_composable "labelled composition")
        else let* a = compose category g.mapping f.mapping in
          labelled_morphism ~alphabet f.lsrc a g.ltgt in
      {source=(fun a -> a.lsrc);target=(fun a -> a.ltgt);ident;comp;equal_obj;
       equal_arr=(fun a b -> equal_obj a.lsrc b.lsrc && equal_obj a.ltgt b.ltgt &&
         category.equal_arr a.mapping b.mapping)}
    let labelled_cocomplete alphabet =
      let cat = labelled_category alphabet in
      let forget = {Foundations.Functor.f_dom=cat;f_cod=category;
        f_omap=(fun g -> Ok (underlying g));f_amap=(fun a -> Ok a.mapping)} in
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
          let* a = labelled_morphism ~alphabet src map apex in Ok (n,a)) (Universal.Diagrams.diagram_nodes d) in
        let* result = Universal.Diagrams.cocone d apex ~sides in
        let univ other =
          let* image = Universal.Diagrams.map_cocone forget other in
          let* u = gc.Universal.Limits.colim_univ image in
          let* a = labelled_morphism ~alphabet apex (Universal.Diagrams.cocone_apex_arrow u)
            (Universal.Diagrams.cocone_apex other) in
          Universal.Diagrams.cocone_arrow result a other in
        Ok {Universal.Limits.colim_cocone=result;colim_univ=univ} in
      {Universal.Limits.cc_cat=cat;cc_colimit=colimit}

  end
  module Rewriting = struct
    type rewrite_result = {
      context:graph;result:graph;context_to_host:graph_morphism;
      context_to_result:graph_morphism;right_to_result:graph_morphism;
    }
    let injective a =
      let* xs = traverse (F.eval a) (F.carrier_to_list (F.domain a)) in
      Ok (F.cardinality (F.carrier_of_list xs) = F.cardinality (F.domain a))
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
          let* xs = traverse (F.eval a) (F.carrier_to_list s) in Ok (F.carrier_of_list xs) in
        let* kept_n = image (node_map l) (nodes (source l)) in
        let* kept_e = image (edge_map l) (edges (source l)) in
        let* deleted_n = image (node_map m) (F.diff (nodes (target l)) kept_n) in
        let* deleted_e = image (edge_map m) (F.diff (edges (target l)) kept_e) in
        let host = target m in
        let remaining_n = F.diff (nodes host) deleted_n in
        let remaining_e = F.diff (edges host) deleted_e in
        let* bindings = traverse (fun e ->
          let* v = F.eval (incidence host) e in match F.view v with
          | F.Pair (s,t) when F.mem s remaining_n && F.mem t remaining_n ->
            Ok (e,s,t)
          | F.Pair _ -> Error (Malformed_graph "DPO: dangling edge")
          | _ -> Error (Malformed_graph "DPO: pair incidence")) (F.carrier_to_list remaining_e) in
        let* context = graph ~nodes:remaining_n ~edges:bindings in
        let* en = F.morphism remaining_e (fun v -> v) (edges host) in
        let* nn = F.morphism remaining_n (fun v -> v) (nodes host) in
        let* context_to_host = graph_morphism context ~edges:en ~nodes:nn host in
        let* em = F.compose (edge_map m) (edge_map l) in
        let* nm = F.compose (node_map m) (node_map l) in
        let* ei = F.morphism_result (edges (source l)) (F.eval em) remaining_e in
        let* ni = F.morphism_result (nodes (source l)) (F.eval nm) remaining_n in
        let* into_context = graph_morphism (source l) ~edges:ei ~nodes:ni context in
        let* po,_ = Universal.Limits.pushout cocomplete (into_context,r) in
        Ok {context;result=po.Universal.Limits.pushout_obj;context_to_host;
          context_to_result=po.Universal.Limits.pushout_leg1;right_to_result=po.Universal.Limits.pushout_leg2}
  end

end
