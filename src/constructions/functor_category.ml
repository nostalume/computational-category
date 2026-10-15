(* Finite enumerated source categories. Maps/components are immutable snapshots;
   equality is extensional over the entire admitted source, never closure identity. *)
open Foundations.Category
type ('o,'a) domain = {cat:('o,'a) cat;objects:'o list;arrows:'a list}
let unique eq xs =
  List.rev (List.fold_left (fun acc x -> if List.exists (eq x) acc then acc else x::acc) [] xs)
let lookup eq context entries x =
  match List.find_opt (fun (y,_) -> eq x y) entries with
  | Some (_,v) -> Ok v | None -> Error (Outside_domain context)
let finite_domain cat ~objects ~arrows =
  let objects = unique cat.equal_obj objects and arrows = unique cat.equal_arr arrows in
  let object_member x = List.exists (cat.equal_obj x) objects in
  let arrow_member x = List.exists (cat.equal_arr x) arrows in
  let* _ = traverse (fun o ->
    if arrow_member (cat.ident o) then Ok ()
    else Error (Malformed_diagram "finite domain: missing identity")) objects in
  let* _ = traverse (fun f ->
    if not (object_member (cat.source f) && object_member (cat.target f)) then
      Error (Malformed_diagram "finite domain: arrow endpoints")
    else
      let* left = compose cat (cat.ident (cat.target f)) f in
      let* right = compose cat f (cat.ident (cat.source f)) in
      if cat.equal_arr left f && cat.equal_arr right f then Ok ()
      else Error (Non_commuting "finite domain: identity law")) arrows in
  let* _ = traverse (fun f ->
    traverse (fun g ->
      if not (cat.equal_obj (cat.target f) (cat.source g)) then Ok ()
      else
        let* gf = compose cat g f in
        if not (arrow_member gf && has_endpoints cat gf (cat.source f) (cat.target g)) then
          Error (Malformed_diagram "finite domain: composition closure")
        else
          let* _ = traverse (fun h ->
            if not (cat.equal_obj (cat.target g) (cat.source h)) then Ok ()
            else let* hg = compose cat h g in
              let* a = compose cat h gf in let* b = compose cat hg f in
              if cat.equal_arr a b then Ok ()
              else Error (Non_commuting "finite domain: associativity")) arrows in
          Ok ()) arrows) arrows in
  Ok {cat;objects;arrows}
let objects d = d.objects
let arrows d = d.arrows
let domain_category d = d.cat
let same_domain a b =
  let same eq xs ys = List.for_all (fun x -> List.exists (eq x) ys) xs &&
    List.for_all (fun y -> List.exists (eq y) xs) ys in
  same a.cat.equal_obj a.objects b.objects && same a.cat.equal_arr a.arrows b.arrows

type ('oa,'aa,'ob,'ab) finite_functor = {
  domain:('oa,'aa) domain;codomain:('ob,'ab) cat;
  object_entries:('oa * 'ob) list;arrow_entries:('aa * 'ab) list;
}
let object_map f = lookup f.domain.cat.equal_obj "finite functor: object" f.object_entries
let arrow_map f = lookup f.domain.cat.equal_arr "finite functor: arrow" f.arrow_entries
let equal_functor f g =
  same_domain f.domain g.domain &&
  List.for_all (fun (o,x) -> match object_map g o with
    | Ok y -> f.codomain.equal_obj x y | Error _ -> false) f.object_entries &&
  List.for_all (fun (a,x) -> match arrow_map g a with
    | Ok y -> f.codomain.equal_arr x y | Error _ -> false) f.arrow_entries
let finite_functor domain codomain ~objects:omap ~arrows:amap =
  let* object_entries = traverse (fun o -> let* x = omap o in Ok (o,x)) domain.objects in
  let* arrow_entries = traverse (fun a -> let* x = amap a in Ok (a,x)) domain.arrows in
  let f = {domain;codomain;object_entries;arrow_entries} in
  let* _ = traverse (fun o ->
    let* image = object_map f o in let* identity = arrow_map f (domain.cat.ident o) in
    if codomain.equal_arr identity (codomain.ident image) then Ok ()
    else Error (Non_commuting "finite functor: identity")) domain.objects in
  let* _ = traverse (fun a ->
    let* image = arrow_map f a in
    let* source = object_map f (domain.cat.source a) in
    let* target = object_map f (domain.cat.target a) in
    if not (has_endpoints codomain image source target) then
      Error (Non_composable "finite functor: mapped endpoints")
    else
      let* _ = traverse (fun b ->
        if not (domain.cat.equal_obj (domain.cat.target a) (domain.cat.source b)) then Ok ()
        else let* ba = compose domain.cat b a in let* actual = arrow_map f ba in
          let* bb = arrow_map f b in let* expected = compose codomain bb image in
          if codomain.equal_arr actual expected then Ok ()
          else Error (Non_commuting "finite functor: composition")) domain.arrows in
      Ok ()) domain.arrows in
  Ok f
let identity_functor domain =
  {domain;codomain=domain.cat;
   object_entries=List.map (fun o -> o,o) domain.objects;
   arrow_entries=List.map (fun a -> a,a) domain.arrows}
let constant_functor domain target object_ =
  finite_functor domain target ~objects:(fun _ -> Ok object_)
    ~arrows:(fun _ -> Ok (target.ident object_))
type ('oa,'aa,'ob,'ab) natural_transformation = {
  src:('oa,'aa,'ob,'ab) finite_functor;tgt:('oa,'aa,'ob,'ab) finite_functor;
  components:('oa * 'ab) list;
}
let source a = a.src
let target a = a.tgt
let component a = lookup a.src.domain.cat.equal_obj "natural component" a.components
let natural_transformation src tgt components =
  if not (same_domain src.domain tgt.domain) then
    Error (Different_base "natural transformation: source categories")
  else
    let* components = traverse (fun o ->
      let* a = components o in let* s = object_map src o in let* t = object_map tgt o in
      if has_endpoints src.codomain a s t then Ok (o,a)
      else Error (Non_composable "natural component endpoints")) src.domain.objects in
    let result = {src;tgt;components} in
    let* _ = traverse (fun f ->
      let* fs = arrow_map src f in let* ft = arrow_map tgt f in
      let* a = component result (src.domain.cat.source f) in
      let* b = component result (src.domain.cat.target f) in
      let* left = compose src.codomain ft a in let* right = compose src.codomain b fs in
      if src.codomain.equal_arr left right then Ok ()
      else Error (Non_commuting "naturality square")) src.domain.arrows in
    Ok result
let equal_natural_transformation a b =
  equal_functor a.src b.src && equal_functor a.tgt b.tgt &&
  List.for_all (fun (o,x) -> match component b o with
    | Ok y -> a.src.codomain.equal_arr x y | Error _ -> false) a.components
let category _domain target =
  let ident f = {src=f;tgt=f;
    components=List.map (fun (o,x) -> o,target.ident x) f.object_entries} in
  let comp (g,f) =
    if not (equal_functor f.tgt g.src) then Error (Non_composable "vertical composition")
    else natural_transformation f.src g.tgt (fun o ->
      let* a = component f o in let* b = component g o in compose target b a) in
  {source;target=(fun a -> a.tgt);ident;comp;equal_obj=equal_functor;equal_arr=equal_natural_transformation}
(* The diagonal C -> C^J needs no sampling of arbitrary object callbacks:
   its maps are defined from admitted J and the supplied lawful C dictionary. *)
let diagonal domain target =
  let object_fn o = {domain;codomain=target;
    object_entries=List.map (fun a -> a,o) domain.objects;
    arrow_entries=List.map (fun a -> a,target.ident o) domain.arrows} in
  {Foundations.Functor.f_dom=target;f_cod=category domain target;f_omap=(fun o -> Ok (object_fn o));
   f_amap=(fun h -> natural_transformation (object_fn (target.source h))
     (object_fn (target.target h)) (fun _ -> Ok h))}
let compose_functors g f =
  finite_functor f.domain g.codomain ~objects:(fun o ->
    let* x = object_map f o in object_map g x) ~arrows:(fun a ->
    let* x = arrow_map f a in arrow_map g x)
let horizontal beta alpha =
  let* src = compose_functors beta.src alpha.src in
  let* tgt = compose_functors beta.tgt alpha.tgt in
  natural_transformation src tgt (fun a ->
    let* fa = object_map alpha.tgt a in let* b = component beta fa in
    let* aa = component alpha a in let* ga = arrow_map beta.src aa in
    compose beta.src.codomain b ga)
let dual_domain d = {d with cat=dual_cat d.cat}
let dual_functor f = {f with domain=dual_domain f.domain;codomain=dual_cat f.codomain}
let dual_natural_transformation a = {src=dual_functor a.tgt;tgt=dual_functor a.src;components=a.components}

let evaluate_diagram target d object_ =
  let* objects = traverse (fun n ->
    let* f = Universal.Diagrams.node_object d n in let* o = object_map f object_ in Ok (n,o))
    (Universal.Diagrams.diagram_nodes d) in
  let* arrows = traverse (fun e ->
    let* a = Universal.Diagrams.edge_arrow d e in let* x = component a object_ in Ok (e,x))
    (Universal.Diagrams.diagram_edges d) in
  Universal.Diagrams.diagram target (Universal.Diagrams.diagram_graph d) ~objects ~arrows

let cocomplete domain target =
  let fc = category domain target.Universal.Limits.cc_cat in
  let colimit d =
    let* cached = traverse (fun o ->
      let* evaluated = evaluate_diagram target.Universal.Limits.cc_cat d o in
      let* c = target.Universal.Limits.cc_colimit evaluated in Ok (o,c)) domain.objects in
    let point = lookup domain.cat.equal_obj "pointwise colimit object" cached in
    let* apex = finite_functor domain target.Universal.Limits.cc_cat ~objects:(fun o ->
      let* c = point o in Ok (Universal.Diagrams.cocone_apex c.Universal.Limits.colim_cocone))
      ~arrows:(fun f ->
        let* s = point (domain.cat.source f) in let* t = point (domain.cat.target f) in
        let* sides = traverse (fun n ->
          let* fn = Universal.Diagrams.node_object d n in let* a = arrow_map fn f in
          let* leg = Universal.Diagrams.cocone_side t.Universal.Limits.colim_cocone n in
          let* side = compose target.Universal.Limits.cc_cat leg a in Ok (n,side))
          (Universal.Diagrams.diagram_nodes d) in
        let* other = Universal.Diagrams.cocone (Universal.Diagrams.cocone_base s.Universal.Limits.colim_cocone)
          (Universal.Diagrams.cocone_apex t.Universal.Limits.colim_cocone) ~sides in
        let* u = s.Universal.Limits.colim_univ other in Ok (Universal.Diagrams.cocone_apex_arrow u)) in
    let* sides = traverse (fun n ->
      let* f = Universal.Diagrams.node_object d n in
      let* a = natural_transformation f apex (fun o ->
        let* c = point o in Universal.Diagrams.cocone_side c.Universal.Limits.colim_cocone n) in Ok (n,a))
      (Universal.Diagrams.diagram_nodes d) in
    let* result = Universal.Diagrams.cocone d apex ~sides in
    let univ other =
      let* a = natural_transformation apex (Universal.Diagrams.cocone_apex other) (fun o ->
        let* c = point o in
        let* target_obj = object_map (Universal.Diagrams.cocone_apex other) o in
        let* sides = traverse (fun n ->
          let* nt = Universal.Diagrams.cocone_side other n in let* x = component nt o in Ok (n,x))
          (Universal.Diagrams.diagram_nodes d) in
        let* candidate = Universal.Diagrams.cocone (Universal.Diagrams.cocone_base c.Universal.Limits.colim_cocone) target_obj ~sides in
        let* u = c.Universal.Limits.colim_univ candidate in Ok (Universal.Diagrams.cocone_apex_arrow u)) in
      Universal.Diagrams.cocone_arrow result a other in
    Ok {Universal.Limits.colim_cocone=result;colim_univ=univ} in
  {Universal.Limits.cc_cat=fc;cc_colimit=colimit}
let complete domain target =
  let opposite = {Universal.Limits.cc_cat=dual_cat target.Universal.Limits.co_cat;
    cc_colimit=Universal.Limits.dual_limit target.Universal.Limits.co_limit} in
  let dual = cocomplete (dual_domain domain) opposite in
  let ordinary = category domain target.Universal.Limits.co_cat in
  let forward = {Foundations.Functor.f_dom=dual_cat ordinary;f_cod=dual.Universal.Limits.cc_cat;
    f_omap=(fun f -> Ok (dual_functor f));f_amap=(fun a -> Ok (dual_natural_transformation a))} in
  let backward = {Foundations.Functor.f_dom=dual.Universal.Limits.cc_cat;f_cod=dual_cat ordinary;
    f_omap=(fun f -> Ok (dual_functor f));f_amap=(fun a -> Ok (dual_natural_transformation a))} in
  {Universal.Limits.co_cat=ordinary;co_limit=Universal.Limits.dual_colimit
    (Universal.Preservation.transport_colimit forward backward dual.Universal.Limits.cc_colimit)}
