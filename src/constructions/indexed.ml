(* Exercise 12. Strict indexed categories with one representation across fibers.
   Lawful strict indexing and preservation/adjunction capabilities are premises;
   membership, endpoints and returned triangles are checked, not erased by casts. *)
module type INDEXED = sig
  type base_obj
  type base_arr
  type fiber_obj
  type fiber_arr
  val base : (base_obj,base_arr) Foundations.Category.cat
  val fiber : base_obj -> (fiber_obj,fiber_arr) Foundations.Category.cat
  val valid_object : base_obj -> fiber_obj -> bool
  val transport : base_arr ->
    ((fiber_obj,fiber_arr,fiber_obj,fiber_arr) Foundations.Functor.cat_functor,Foundations.Category.error) result
end
module Make (I : INDEXED) = struct
  open Foundations.Category
  type obj = {index:I.base_obj;value:I.fiber_obj}
  type arrow = {src:obj;base_map:I.base_arr;fiber_map:I.fiber_arr;tgt:obj}
  let index o = o.index
  let value o = o.value
  let source a = a.src
  let target a = a.tgt
  let base_map a = a.base_map
  let fiber_map a = a.fiber_map
  let object_ index value =
    if I.valid_object index value then Ok {index;value}
    else Error (Malformed_diagram "indexed object: fiber membership")
  let equal_object a b =
    I.base.equal_obj a.index b.index && (I.fiber a.index).equal_obj a.value b.value
  let arrow src base_map fiber_map tgt =
    if not (has_endpoints I.base base_map src.index tgt.index) then
      Error (Non_composable "indexed arrow: base endpoints")
    else
      let* f = I.transport base_map in
      let mapped = f.Foundations.Functor.f_omap src.value in
      if not (I.valid_object tgt.index mapped &&
        has_endpoints (I.fiber tgt.index) fiber_map mapped tgt.value) then
        Error (Non_composable "indexed arrow: fiber endpoints")
      else Ok {src;base_map;fiber_map;tgt}
  let category =
    let ident o = {src=o;tgt=o;base_map=I.base.ident o.index;
      fiber_map=(I.fiber o.index).ident o.value} in
    let comp (g,f) =
      if not (equal_object f.tgt g.src) then Error (Non_composable "indexed composition")
      else
        let* transported = I.transport g.base_map in
        let* moved = transported.Foundations.Functor.f_amap f.fiber_map in
        let* payload = compose (I.fiber g.tgt.index) g.fiber_map moved in
        let* base = compose I.base g.base_map f.base_map in
        arrow f.src base payload g.tgt in
    {source;target;ident;comp;equal_obj=equal_object;
     equal_arr=(fun a b -> equal_object a.src b.src && equal_object a.tgt b.tgt &&
       I.base.equal_arr a.base_map b.base_map &&
       (I.fiber a.tgt.index).equal_arr a.fiber_map b.fiber_map)}
  let projection =
    {Foundations.Functor.f_dom=category;f_cod=I.base;f_omap=index;f_amap=(fun a -> Ok a.base_map)}
  let cocomplete base fiber preserve =
    let colimit d =
      let* bd = Universal.Diagrams.map_diagram projection d in
      let* bc = base.Universal.Limits.cc_colimit bd in
      let c = Universal.Diagrams.cocone_apex bc.Universal.Limits.colim_cocone in
      let* transports = traverse (fun n ->
        let* a = Universal.Diagrams.cocone_side bc.Universal.Limits.colim_cocone n in
        let* f = I.transport a in Ok (n,f)) (Universal.Diagrams.diagram_nodes d) in
      let* objects = traverse (fun n ->
        let* o = Universal.Diagrams.node_object d n in
        let f = List.assoc n transports in
        let* admitted = object_ c (f.Foundations.Functor.f_omap o.value) in Ok (n,admitted.value))
        (Universal.Diagrams.diagram_nodes d) in
      let* arrows = traverse (fun e ->
        let* a = Universal.Diagrams.edge_arrow d e in
        let* t = Universal.Diagrams.graph_target (Universal.Diagrams.diagram_graph d) e in
        let f = List.assoc t transports in
        let* u = f.Foundations.Functor.f_amap a.fiber_map in Ok (e,u)) (Universal.Diagrams.diagram_edges d) in
      let* fd = Universal.Diagrams.diagram (I.fiber c) (Universal.Diagrams.diagram_graph d) ~objects ~arrows in
      let* fc = (fiber c).Universal.Limits.cc_colimit fd in
      let* apex = object_ c (Universal.Diagrams.cocone_apex fc.Universal.Limits.colim_cocone) in
      let* sides = traverse (fun n ->
        let* src = Universal.Diagrams.node_object d n in
        let* b = Universal.Diagrams.cocone_side bc.Universal.Limits.colim_cocone n in
        let* f = Universal.Diagrams.cocone_side fc.Universal.Limits.colim_cocone n in
        let* a = arrow src b f apex in Ok (n,a)) (Universal.Diagrams.diagram_nodes d) in
      let* result = Universal.Diagrams.cocone d apex ~sides in
      let univ other =
        let* ob = Universal.Diagrams.map_cocone projection other in
        let* u = bc.Universal.Limits.colim_univ ob in
        let base_u = Universal.Diagrams.cocone_apex_arrow u in
        let* transfer = I.transport base_u in
        let* preserved = preserve base_u fc in
        let* expected = Universal.Diagrams.map_cocone transfer fc.Universal.Limits.colim_cocone in
        let equality = Universal.Diagrams.total_cocone_category (I.fiber (Universal.Diagrams.cocone_apex other).index)
          (Universal.Diagrams.diagram_graph fd) in
        if not (equality.equal_obj expected preserved.Universal.Limits.colim_cocone) then
          Error (Different_base "indexed preservation: mapped colimit")
        else
          let* sides = traverse (fun n ->
            let* a = Universal.Diagrams.cocone_side other n in Ok (n,a.fiber_map)) (Universal.Diagrams.diagram_nodes d) in
          let* candidate = Universal.Diagrams.cocone (Universal.Diagrams.cocone_base preserved.Universal.Limits.colim_cocone)
            (Universal.Diagrams.cocone_apex other).value ~sides in
          let* f = preserved.Universal.Limits.colim_univ candidate in
          let* a = arrow apex base_u (Universal.Diagrams.cocone_apex_arrow f) (Universal.Diagrams.cocone_apex other) in
          Universal.Diagrams.cocone_arrow result a other in
      Ok {Universal.Limits.colim_cocone=result;colim_univ=univ} in
    {Universal.Limits.cc_cat=category;cc_colimit=colimit}

  type right_adjoint = {
    right : (I.fiber_obj,I.fiber_arr,I.fiber_obj,I.fiber_arr) Foundations.Functor.cat_functor;
    to_right : I.fiber_obj -> I.fiber_obj -> I.fiber_arr -> (I.fiber_arr,error) result;
    from_right : I.fiber_obj -> I.fiber_obj -> I.fiber_arr -> (I.fiber_arr,error) result;
  }
  (* Transposition callbacks must be natural inverse bijections; check the
     visible endpoints in both directions and preserve unexpected exceptions. *)
  let transpose base adj a b h =
    let* f = I.transport base in
    if not (has_endpoints (I.fiber (I.base.target base)) h (f.Foundations.Functor.f_omap a) b) then
      Error (Non_composable "indexed transpose: input")
    else let* u = adj.to_right a b h in
      if has_endpoints (I.fiber (I.base.source base)) u a (adj.right.Foundations.Functor.f_omap b)
      then Ok u else Error (Non_composable "indexed transpose: output")
  let untranspose base adj a b h =
    if not (has_endpoints (I.fiber (I.base.source base)) h a (adj.right.Foundations.Functor.f_omap b)) then
      Error (Non_composable "indexed untranspose: input")
    else
      let* f = I.transport base in let* u = adj.from_right a b h in
      if has_endpoints (I.fiber (I.base.target base)) u (f.Foundations.Functor.f_omap a) b
      then Ok u else Error (Non_composable "indexed untranspose: output")
  let complete base fiber right_adjoints =
    let limit d =
      let* bd = Universal.Diagrams.map_diagram projection d in
      let* bl = base.Universal.Limits.co_limit bd in
      let c = Universal.Diagrams.cone_apex bl.Universal.Limits.lim_cone in
      let* pullbacks = traverse (fun n ->
        let* leg = Universal.Diagrams.cone_side bl.Universal.Limits.lim_cone n in
        let* adj = right_adjoints leg in Ok (n,(leg,adj))) (Universal.Diagrams.diagram_nodes d) in
      let* objects = traverse (fun n ->
        let* o = Universal.Diagrams.node_object d n in let _,adj = List.assoc n pullbacks in
        let* admitted = object_ c (adj.right.Foundations.Functor.f_omap o.value) in
        Ok (n,admitted.value)) (Universal.Diagrams.diagram_nodes d) in
      let* arrows = traverse (fun e ->
        let* s = Universal.Diagrams.graph_source (Universal.Diagrams.diagram_graph d) e in
        let* t = Universal.Diagrams.graph_target (Universal.Diagrams.diagram_graph d) e in
        let* a = Universal.Diagrams.edge_arrow d e in let* so = Universal.Diagrams.node_object d s in
        let* to_ = Universal.Diagrams.node_object d t in
        let sl,sa = List.assoc s pullbacks and tl,ta = List.assoc t pullbacks in
        let pulled = sa.right.Foundations.Functor.f_omap so.value in
        let* counit = untranspose sl sa pulled so.value ((I.fiber c).ident pulled) in
        let* trans = I.transport a.base_map in
        let* moved = trans.Foundations.Functor.f_amap counit in
        let* leg = compose (I.fiber to_.index) a.fiber_map moved in
        let* mate = transpose tl ta pulled to_.value leg in Ok (e,mate))
        (Universal.Diagrams.diagram_edges d) in
      let* fd = Universal.Diagrams.diagram (I.fiber c) (Universal.Diagrams.diagram_graph d) ~objects ~arrows in
      let* fl = (fiber c).Universal.Limits.co_limit fd in
      let* apex = object_ c (Universal.Diagrams.cone_apex fl.Universal.Limits.lim_cone) in
      let* sides = traverse (fun n ->
        let* tgt = Universal.Diagrams.node_object d n in let leg,adj = List.assoc n pullbacks in
        let* projection = Universal.Diagrams.cone_side fl.Universal.Limits.lim_cone n in
        let* payload = untranspose leg adj apex.value tgt.value projection in
        let* a = arrow apex leg payload tgt in Ok (n,a)) (Universal.Diagrams.diagram_nodes d) in
      let* result = Universal.Diagrams.cone d apex ~sides in
      let univ other =
        let* ob = Universal.Diagrams.map_cone projection other in
        let* u = bl.Universal.Limits.lim_univ ob in let base_u = Universal.Diagrams.cone_apex_arrow u in
        let* transfer = I.transport base_u in
        let* moved_object = object_ c (transfer.Foundations.Functor.f_omap (Universal.Diagrams.cone_apex other).value) in
        let moved = moved_object.value in
        let* sides = traverse (fun n ->
          let* a = Universal.Diagrams.cone_side other n in
          let* o = Universal.Diagrams.node_object d n in let leg,adj = List.assoc n pullbacks in
          let* payload = transpose leg adj moved o.value a.fiber_map in Ok (n,payload))
          (Universal.Diagrams.diagram_nodes d) in
        let* candidate = Universal.Diagrams.cone fd moved ~sides in
        let* f = fl.Universal.Limits.lim_univ candidate in
        let* a = arrow (Universal.Diagrams.cone_apex other) base_u (Universal.Diagrams.cone_apex_arrow f) apex in
        Universal.Diagrams.cone_arrow other a result in
      Ok {Universal.Limits.lim_cone=result;lim_univ=univ} in
    {Universal.Limits.co_cat=category;co_limit=limit}
end

