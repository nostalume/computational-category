open Foundations.Category
open Foundations.Functor
module D = Universal.Diagrams
module L = Universal.Limits

type ('o,'a) algebra = {carrier:'o;structure:'a}
type ('o,'a) algebra_morphism = {src:('o,'a) algebra;map:'a;tgt:('o,'a) algebra}
let carrier a = a.carrier
let structure a = a.structure
let source h = h.src
let target h = h.tgt
let underlying h = h.map

let algebra f carrier structure =
  let* image = f.f_omap carrier in
  if has_endpoints f.f_dom structure image carrier then Ok {carrier;structure}
  else Error (Non_composable "algebra structure: endpoints")
let algebra_morphism f src map tgt =
  if not (has_endpoints f.f_dom map src.carrier tgt.carrier) then
    Error (Non_composable "algebra homomorphism: endpoints")
  else
    let* image = f.f_amap map in
    let* lhs = Foundations.Category.compose f.f_dom map src.structure in
    let* rhs = Foundations.Category.compose f.f_dom tgt.structure image in
    if f.f_dom.equal_arr lhs rhs then Ok {src;map;tgt}
    else Error (Non_commuting "algebra homomorphism square")
let category f =
  let equal_obj a b = f.f_dom.equal_obj a.carrier b.carrier &&
    f.f_dom.equal_arr a.structure b.structure in
  let equal_arr h k = equal_obj h.src k.src && equal_obj h.tgt k.tgt &&
    f.f_dom.equal_arr h.map k.map in
  {source;target;equal_obj;equal_arr;
   ident=(fun a -> {src=a;map=f.f_dom.ident a.carrier;tgt=a});
   comp=(fun (g,h) ->
     if not (equal_obj h.tgt g.src) then Error (Non_composable "algebra composition")
     else let* map = Foundations.Category.compose f.f_dom g.map h.map in
       algebra_morphism f h.src map g.tgt)}
let forgetful f =
  {f_dom=category f;f_cod=f.f_dom;
   f_omap=(fun a -> Ok a.carrier);f_amap=(fun h -> Ok h.map)}

(* Limits are created by the forgetful functor. No preservation by F is needed:
   the structure is the mediator from the cone with legs structure_n F(p_n). *)
let complete f complete =
  let forget = forgetful f in
  let limit diagram =
    let* base = D.map_diagram forget diagram in
    let* limit = complete.L.co_limit base in
    let c = limit.L.lim_cone in
    let apex = D.cone_apex c in
    let* image = f.f_omap apex in
    let* sides = traverse (fun n ->
      let* a = D.node_object diagram n in
      let* p = D.cone_side c n in let* fp = f.f_amap p in
      let* leg = Foundations.Category.compose f.f_dom a.structure fp in Ok (n,leg))
      (D.diagram_nodes diagram) in
    let* structure_cone = D.cone base image ~sides in
    let* mediator = limit.L.lim_univ structure_cone in
    let* result = algebra f apex (D.cone_apex_arrow mediator) in
    let* sides = traverse (fun n ->
      let* a = D.node_object diagram n in let* p = D.cone_side c n in
      let* h = algebra_morphism f result p a in Ok (n,h)) (D.diagram_nodes diagram) in
    let* cone = D.cone diagram result ~sides in
    let universal other =
      if not (D.same_base diagram (D.cone_base other)) then
        Error (Different_base "algebra limit")
      else
        let* candidate = D.map_cone forget other in
        let* h = limit.L.lim_univ candidate in
        let* lift = algebra_morphism f (D.cone_apex other) (D.cone_apex_arrow h) result in
        D.cone_arrow other lift cone in
    Ok {L.lim_cone=cone;lim_univ=universal} in
  {L.co_cat=category f;co_limit=limit}

module Free = struct
  let initial c =
    let* shape = D.graph ~nodes:[] ~edges:[] in
    let* diagram = D.diagram c.L.cc_cat shape ~objects:[] ~arrows:[] in
    let* colimit = c.L.cc_colimit diagram in
    let init_univ target =
      let* other = D.cocone diagram target ~sides:[] in
      let* h = colimit.L.colim_univ other in Ok (D.cocone_apex_arrow h) in
    Ok {L.init_obj=D.cocone_apex colimit.L.colim_cocone;init_univ}
  let checked_bound bound =
    if bound<0 then Error (Outside_domain "free algebra: negative bound") else Ok ()

  let coproduct ~cocomplete ~isomorphisms ~preserving ~bound seed =
    let* () = checked_bound bound in
    let f = preserving.Universal.Preservation.cc_functor in
    let c = f.f_dom in let* zero = initial cocomplete in
    let rec iter n current acc =
      let* h = zero.L.init_univ current in let* k = inverse isomorphisms h in
      match k with Some _ -> Ok (List.rev (current::acc))
      | None when n=bound -> Error (Iteration_limit bound)
      | None -> let* next = f.f_omap current in iter (n+1) next (current::acc) in
    let* objects = iter 0 seed [] in
    let labels = List.mapi (fun n _ -> string_of_int n) objects in
    let* shape = D.graph ~nodes:labels ~edges:[] in
    let* diagram = D.diagram c shape ~objects:(List.combine labels objects) ~arrows:[] in
    let* sum = cocomplete.L.cc_colimit diagram in
    let* image = preserving.Universal.Preservation.cc_map sum in
    let* expected = D.map_cocone f sum.L.colim_cocone in
    if not ((D.total_cocone_category c shape).equal_obj expected image.L.colim_cocone) then
      Error (Different_base "free coproduct: preservation image") else
    let result = D.cocone_apex sum.L.colim_cocone in
    let* sides = traverse (fun n ->
      let i = int_of_string n in
      let* leg = if i+1<List.length objects then D.cocone_side sum.L.colim_cocone (string_of_int (i+1))
        else
          let* last = f.f_omap (List.nth objects i) in
          let* init = zero.L.init_univ last in let* k = inverse isomorphisms init in
          match k with Some k -> let* out = zero.L.init_univ result in Foundations.Category.compose c out k
          | None -> Error (Non_commuting "free coproduct: F must preserve initial objects") in
      Ok (n,leg)) labels in
    let* candidate = D.cocone (D.cocone_base image.L.colim_cocone) result ~sides in
    let* h = image.L.colim_univ candidate in
    let* free_object = algebra f result (D.cocone_apex_arrow h) in
    let* unit_arrow = D.cocone_side sum.L.colim_cocone "0" in
    let factor target h =
      let rec legs n h =
        if n=List.length objects then Ok [] else
        let* rest = if n+1=List.length objects then Ok [] else
          let* fh = f.f_amap h in
          let* next = Foundations.Category.compose c target.structure fh in legs (n+1) next in
        Ok ((string_of_int n,h)::rest) in
      let* sides = legs 0 h in
      let* other = D.cocone diagram target.carrier ~sides in
      let* u = sum.L.colim_univ other in
      algebra_morphism f free_object (D.cocone_apex_arrow u) target in
    Ok {Universal.Adjunction.free_object;unit_arrow;factor}

  let initial_chain ~cocomplete ~isomorphisms ~bound f =
    let* () = checked_bound bound in
    let* zero = initial cocomplete in let* fzero = f.f_omap zero.L.init_obj in
    let* first = zero.L.init_univ fzero in
    let cache = Hashtbl.create 16 in Hashtbl.add cache 0 first;
    let rec chain n = match Hashtbl.find_opt cache n with Some h -> Ok h | None ->
      let* p = chain (n-1) in let* h = f.f_amap p in Hashtbl.add cache n h; Ok h in
    let* fixed = L.Chain.terminating ~isomorphisms ~bound chain in
    let* h = chain fixed.L.Chain.cutoff in let* inverse = inverse isomorphisms h in
    let* structure = match inverse with Some h -> Ok h | None -> Error (Non_commuting "initial chain: inverse") in
    let* result = algebra f fixed.L.Chain.apex structure in
    let factor target =
      let* h = zero.L.init_univ target.carrier in
      let rec fold n h = if n=fixed.L.Chain.cutoff then algebra_morphism f result h target else
        let* fh = f.f_amap h in
        let* h = Foundations.Category.compose f.f_dom target.structure fh in fold (n+1) h in
      fold 0 h in
    Ok {L.init_obj=result;init_univ=factor}

  let chain ~cocomplete ~isomorphisms ~bound f seed =
    let coprod = L.coproduct cocomplete in
    let object_ o = let* fo = f.f_omap o in coprod (seed,fo) in
    let plus = {f_dom=f.f_dom;f_cod=f.f_cod;
      f_omap=(fun o -> let* p,_ = object_ o in Ok p.L.coprod_obj);
      f_amap=(fun h ->
        let* _,factor = object_ (f.f_dom.source h) in let* q,_ = object_ (f.f_dom.target h) in
        let* fh = f.f_amap h in
        let* right = Foundations.Category.compose f.f_dom q.L.coprod_inj2 fh in
        factor q.L.coprod_obj q.L.coprod_inj1 right)} in
    let* free = initial_chain ~cocomplete ~isomorphisms ~bound plus in
    let result = free.L.init_obj in
    let* p,_ = object_ result.carrier in
    let* unit_arrow = Foundations.Category.compose f.f_dom result.structure p.L.coprod_inj1 in
    let* structure = Foundations.Category.compose f.f_dom result.structure p.L.coprod_inj2 in
    let* free_object = algebra f result.carrier structure in
    let factor target h =
      let* _,combine = object_ target.carrier in
      let* structure = combine target.carrier h target.structure in
      let* other = algebra plus target.carrier structure in
      let* u = free.L.init_univ other in
      algebra_morphism f free_object u.map target in
    Ok {Universal.Adjunction.free_object;unit_arrow;factor}

  let pushout ~cocomplete ~isomorphisms ~bound f seed =
    let* () = checked_bound bound in
    let c = f.f_dom in let* zero = initial cocomplete in
    let* fs = f.f_omap seed in let* fn = zero.L.init_univ seed in let* gn = zero.L.init_univ fs in
    let rec iterate n fn gn generator history =
      if n>=bound then Error (Iteration_limit bound) else
      let* p,factor = L.pushout cocomplete (gn,fn) in
      let next = p.L.pushout_leg2 and structure = p.L.pushout_leg1 in
      let* inv = inverse isomorphisms next in
      match inv with
      | Some inv ->
        let* structure = Foundations.Category.compose c inv structure in
        let* free_object = algebra f (c.source next) structure in
        let factor target h =
          let* map = List.fold_left (fun state combine ->
            let* u = state in let* fu = f.f_amap u in
            let* v = Foundations.Category.compose c target.structure fu in
            combine target.carrier v u) (Ok h) (List.rev history) in
          algebra_morphism f free_object map target in
        Ok {Universal.Adjunction.free_object;unit_arrow=generator;factor}
      | None ->
        let* generator = Foundations.Category.compose c next generator in
        let* gn = f.f_amap next in iterate (n+1) structure gn generator (factor::history) in
    iterate 0 fn gn (c.ident seed) []
end
