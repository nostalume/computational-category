(* Finite labelled diagram shapes and admitted diagram/cone morphisms. *)
open Foundations.Category
type graph = { nodes : string list; edges : (string * string * string) list }
type ('o, 'a) diagram = {
  shape : graph; category : ('o, 'a) cat;
  objects : (string * 'o) list; arrows : (string * 'a) list;
}
type ('o, 'a) cocone = {
  cc_apex : 'o; cc_base : ('o, 'a) diagram; cc_sides : (string * 'a) list;
}
type ('o, 'a) cone = {
  co_apex : 'o; co_base : ('o, 'a) diagram; co_sides : (string * 'a) list;
}
type ('o, 'a) cocone_arrow = {
  cc_domain : ('o, 'a) cocone; cc_arrow : 'a; cc_codomain : ('o, 'a) cocone;
}
type ('o, 'a) cone_arrow = {
  co_domain : ('o, 'a) cone; co_arrow : 'a; co_codomain : ('o, 'a) cone;
}
let rec duplicate = function
  | [] -> None
  | x :: xs -> if List.mem x xs then Some x else duplicate xs
let same_labels a b =
  List.for_all (fun x -> List.mem x b) a && List.for_all (fun x -> List.mem x a) b
let lookup context bindings label =
  match List.assoc_opt label bindings with
  | Some x -> Ok x
  | None -> Error (Outside_domain (context ^ ": undeclared label " ^ label))
let admit_bindings context labels bindings =
  let keys = List.map fst bindings in
  match duplicate keys with
  | Some label -> Error (Malformed_diagram (context ^ ": duplicate binding " ^ label))
  | None ->
    match List.find_opt (fun label -> not (List.mem label keys)) labels with
    | Some label -> Error (Malformed_diagram (context ^ ": missing binding " ^ label))
    | None ->
      match List.find_opt (fun label -> not (List.mem label labels)) keys with
      | Some label -> Error (Malformed_diagram (context ^ ": undeclared binding " ^ label))
      | None -> Ok ()

let graph ~nodes ~edges =
  let ids = List.map (fun (id, _, _) -> id) edges in
  match duplicate nodes, duplicate ids with
  | Some id, _ -> Error (Malformed_graph ("graph: duplicate node " ^ id))
  | _, Some id -> Error (Malformed_graph ("graph: duplicate edge " ^ id))
  | None, None ->
    match List.find_opt (fun (_, s, t) ->
      not (List.mem s nodes && List.mem t nodes)) edges with
    | Some (id, s, t) ->
      let missing = if List.mem s nodes then t else s in
      Error (Malformed_graph ("graph edge " ^ id ^ ": undeclared endpoint " ^ missing))
    | None -> Ok { nodes; edges }

let graph_nodes g = g.nodes
let graph_edges g = List.map (fun (id, _, _) -> id) g.edges
let graph_source g id =
  lookup "graph source" (List.map (fun (i, s, _) -> i, s) g.edges) id
let graph_target g id =
  lookup "graph target" (List.map (fun (i, _, t) -> i, t) g.edges) id

let diagram category shape ~objects ~arrows =
    let* () = admit_bindings "diagram node" shape.nodes objects in
    let* () = admit_bindings "diagram edge" (graph_edges shape) arrows in
    let* _ = traverse (fun (id, s, t) ->
      let* a = lookup "diagram edge" arrows id in
      let* source = lookup "diagram node" objects s in
      let* target = lookup "diagram node" objects t in
      if has_endpoints category a source target then Ok ()
      else Error (Malformed_diagram ("edge endpoints: " ^ id))) shape.edges in
    Ok { shape; category; objects; arrows }

let diagram_graph d = d.shape
let diagram_category d = d.category
let diagram_nodes d = d.shape.nodes
let diagram_edges d = graph_edges d.shape
let node_object d = lookup "diagram node" d.objects
let edge_arrow d = lookup "diagram edge" d.arrows

let same_base a b =
  let cat = a.category in
  same_labels a.shape.nodes b.shape.nodes &&
  same_labels (graph_edges a.shape) (graph_edges b.shape) &&
  List.for_all (fun (id, s, t) ->
    List.exists (fun (j, u, v) -> id = j && s = u && t = v) b.shape.edges) a.shape.edges &&
  List.for_all (fun (id, obj) ->
    match List.assoc_opt id b.objects with
    | Some other -> cat.equal_obj obj other | None -> false) a.objects &&
  List.for_all (fun (id, arr) ->
    match List.assoc_opt id b.arrows with
    | Some other -> cat.equal_arr arr other | None -> false) a.arrows

type direction = Cone | Cocone

let admit_sides direction base apex sides =
  let cat = base.category in
    let* () = admit_bindings "cone/cocone side" base.shape.nodes sides in
    let* _ = traverse (fun (node, obj) ->
      let* side = lookup "cone/cocone side" sides node in
      let source, target = match direction with
        | Cone -> apex, obj | Cocone -> obj, apex in
      if has_endpoints cat side source target then Ok ()
      else Error (Malformed_diagram ("cone/cocone side endpoints: " ^ node))) base.objects in
    let* _ = traverse (fun (edge, s, t) ->
      let* f = edge_arrow base edge in
      let* left = lookup "cone/cocone side" sides s in
      let* right = lookup "cone/cocone side" sides t in
      let* composed, expected = match direction with
        | Cone -> let* a = compose cat f left in Ok (a, right)
        | Cocone -> let* a = compose cat right f in Ok (a, left) in
      if cat.equal_arr composed expected then Ok ()
      else Error (Non_commuting ("cone/cocone edge: " ^ edge))) base.shape.edges in
    Ok ()

let cocone base apex ~sides =
  let* () = admit_sides Cocone base apex sides in
  Ok { cc_base = base; cc_apex = apex; cc_sides = sides }
let cone base apex ~sides =
  let* () = admit_sides Cone base apex sides in
  Ok { co_base = base; co_apex = apex; co_sides = sides }

let cocone_apex c = c.cc_apex
let cocone_base c = c.cc_base
let cocone_side c = lookup "cocone side" c.cc_sides
let cone_apex c = c.co_apex
let cone_base c = c.co_base
let cone_side c = lookup "cone side" c.co_sides

let cocone_arrow domain arrow codomain =
  let cat = domain.cc_base.category in
  if not (same_base domain.cc_base codomain.cc_base) then
    Error (Different_base "cocone arrow")
  else if not (has_endpoints cat arrow domain.cc_apex codomain.cc_apex) then
    Error (Non_composable "cocone arrow endpoints")
  else
    let* _ = traverse (fun node ->
      let* a = cocone_side domain node in
      let* b = cocone_side codomain node in
      let* composite = compose cat arrow a in
      if cat.equal_arr composite b then Ok ()
      else Error (Non_commuting ("cocone arrow side: " ^ node))) domain.cc_base.shape.nodes in
    Ok { cc_domain = domain; cc_arrow = arrow; cc_codomain = codomain }

let cone_arrow domain arrow codomain =
  let cat = domain.co_base.category in
  if not (same_base domain.co_base codomain.co_base) then
    Error (Different_base "cone arrow")
  else if not (has_endpoints cat arrow domain.co_apex codomain.co_apex) then
    Error (Non_composable "cone arrow endpoints")
  else
    let* _ = traverse (fun node ->
      let* a = cone_side domain node in
      let* b = cone_side codomain node in
      let* composite = compose cat b arrow in
      if cat.equal_arr composite a then Ok ()
      else Error (Non_commuting ("cone arrow side: " ^ node))) domain.co_base.shape.nodes in
    Ok { co_domain = domain; co_arrow = arrow; co_codomain = codomain }

let cocone_apex_arrow c = c.cc_arrow
let cocone_arrow_domain c = c.cc_domain
let cocone_arrow_codomain c = c.cc_codomain
let cone_apex_arrow c = c.co_arrow
let cone_arrow_domain c = c.co_domain
let cone_arrow_codomain c = c.co_codomain

(* Removing nodes only occurs in discrete diagrams; removing an edge leaves
   every node. These private restrictions preserve admitted binding invariants. *)
let dual_graph g =
  { g with edges = List.map (fun (id, s, t) -> id, t, s) g.edges }
let dual_diagram d =
  { d with shape = dual_graph d.shape; category = dual_cat d.category }
let dual_cocone c =
  { co_apex = c.cc_apex; co_base = dual_diagram c.cc_base; co_sides = c.cc_sides }
let dual_cone c =
  { cc_apex = c.co_apex; cc_base = dual_diagram c.co_base; cc_sides = c.co_sides }
let dual_cocone_arrow a =
  { co_domain = dual_cocone a.cc_codomain; co_arrow = a.cc_arrow;
    co_codomain = dual_cocone a.cc_domain }
let dual_cone_arrow a =
  { cc_domain = dual_cone a.co_codomain; cc_arrow = a.co_arrow;
    cc_codomain = dual_cone a.co_domain }

type ('o, 'a) diagram_arrow = {
  da_domain : ('o, 'a) diagram; da_codomain : ('o, 'a) diagram;
  da_components : (string * 'a) list;
}
let same_shape a b =
  same_labels a.nodes b.nodes && same_labels (graph_edges a) (graph_edges b) &&
  List.for_all (fun e -> List.mem e b.edges) a.edges
let diagram_arrow domain codomain ~components =
  let cat = domain.category in
  if not (same_shape domain.shape codomain.shape) then
    Error (Different_base "diagram arrow: labelled shape")
  else
    let* () = admit_bindings "diagram arrow" domain.shape.nodes components in
    let* _ = traverse (fun n ->
      let* a = lookup "diagram component" components n in
      let* s = node_object domain n in let* t = node_object codomain n in
      if has_endpoints cat a s t then Ok ()
      else Error (Non_composable ("diagram component: " ^ n))) domain.shape.nodes in
    let* _ = traverse (fun (e,s,t) ->
      let* f = edge_arrow domain e in let* g = edge_arrow codomain e in
      let* u = lookup "diagram component" components s in
      let* v = lookup "diagram component" components t in
      let* gu = compose cat g u in let* vf = compose cat v f in
      if cat.equal_arr gu vf then Ok ()
      else Error (Non_commuting ("diagram arrow edge: " ^ e))) domain.shape.edges in
    Ok { da_domain = domain; da_codomain = codomain; da_components = components }
let diagram_arrow_domain a = a.da_domain
let diagram_arrow_codomain a = a.da_codomain
let diagram_component a = lookup "diagram component" a.da_components
let equal_diagram_arrow cat a b =
  same_base a.da_domain b.da_domain && same_base a.da_codomain b.da_codomain &&
  List.for_all (fun (n,x) -> match List.assoc_opt n b.da_components with
    | Some y -> cat.equal_arr x y | None -> false) a.da_components
let diagrams_category cat _shape =
  let ident d = { da_domain = d; da_codomain = d;
    da_components = List.map (fun (n,o) -> n,cat.ident o) d.objects } in
  let comp (g,f) =
    if not (same_base f.da_codomain g.da_domain) then
      Error (Non_composable "diagram composition: middle base")
    else
      let* components = traverse (fun n ->
        let* a = diagram_component f n in let* b = diagram_component g n in
        let* c = compose cat b a in Ok (n,c)) f.da_domain.shape.nodes in
      diagram_arrow f.da_domain g.da_codomain ~components in
  { source = diagram_arrow_domain; target = diagram_arrow_codomain;
    ident; comp; equal_obj = same_base; equal_arr = equal_diagram_arrow cat }

type ('o, 'a) cocone_map = {
  cm_domain : ('o,'a) cocone; cm_base : ('o,'a) diagram_arrow;
  cm_apex : 'a; cm_codomain : ('o,'a) cocone;
}
type ('o, 'a) cone_map = {
  lm_domain : ('o,'a) cone; lm_base : ('o,'a) diagram_arrow;
  lm_apex : 'a; lm_codomain : ('o,'a) cone;
}
let cocone_map domain base arrow codomain =
  let cat = domain.cc_base.category in
  if not (same_base domain.cc_base base.da_domain &&
          same_base codomain.cc_base base.da_codomain) then
    Error (Different_base "cocone map")
  else if not (has_endpoints cat arrow domain.cc_apex codomain.cc_apex) then
    Error (Non_composable "cocone map apex")
  else
    let* _ = traverse (fun n ->
      let* s = cocone_side domain n in let* t = cocone_side codomain n in
      let* u = diagram_component base n in
      let* left = compose cat arrow s in let* right = compose cat t u in
      if cat.equal_arr left right then Ok ()
      else Error (Non_commuting ("cocone map: " ^ n))) domain.cc_base.shape.nodes in
    Ok {cm_domain=domain;cm_base=base;cm_apex=arrow;cm_codomain=codomain}
let cone_map domain base arrow codomain =
  let cat = domain.co_base.category in
  if not (same_base domain.co_base base.da_domain &&
          same_base codomain.co_base base.da_codomain) then
    Error (Different_base "cone map")
  else if not (has_endpoints cat arrow domain.co_apex codomain.co_apex) then
    Error (Non_composable "cone map apex")
  else
    let* _ = traverse (fun n ->
      let* s = cone_side domain n in let* t = cone_side codomain n in
      let* u = diagram_component base n in
      let* left = compose cat u s in let* right = compose cat t arrow in
      if cat.equal_arr left right then Ok ()
      else Error (Non_commuting ("cone map: " ^ n))) domain.co_base.shape.nodes in
    Ok {lm_domain=domain;lm_base=base;lm_apex=arrow;lm_codomain=codomain}
let cocone_map_domain a = a.cm_domain
let cocone_map_codomain a = a.cm_codomain
let cocone_map_base a = a.cm_base
let cocone_map_apex a = a.cm_apex
let cone_map_domain a = a.lm_domain
let cone_map_codomain a = a.lm_codomain
let cone_map_base a = a.lm_base
let cone_map_apex a = a.lm_apex
let equal_cocone cat a b =
  same_base a.cc_base b.cc_base && cat.equal_obj a.cc_apex b.cc_apex &&
  List.for_all (fun (n,x) -> match List.assoc_opt n b.cc_sides with
    | Some y -> cat.equal_arr x y | None -> false) a.cc_sides
let equal_cone cat a b =
  same_base a.co_base b.co_base && cat.equal_obj a.co_apex b.co_apex &&
  List.for_all (fun (n,x) -> match List.assoc_opt n b.co_sides with
    | Some y -> cat.equal_arr x y | None -> false) a.co_sides
let total_cocone_category cat shape =
  let dc = diagrams_category cat shape in
  let ident c = {cm_domain=c;cm_base=dc.ident c.cc_base;
    cm_apex=cat.ident c.cc_apex;cm_codomain=c} in
  let comp (g,f) =
    if not (equal_cocone cat f.cm_codomain g.cm_domain) then
      Error (Non_composable "cocone map composition")
    else let* base = compose dc g.cm_base f.cm_base in
      let* apex = compose cat g.cm_apex f.cm_apex in
      cocone_map f.cm_domain base apex g.cm_codomain in
  let equal_arr a b =
    equal_cocone cat a.cm_domain b.cm_domain &&
    equal_cocone cat a.cm_codomain b.cm_codomain &&
    dc.equal_arr a.cm_base b.cm_base && cat.equal_arr a.cm_apex b.cm_apex in
  {source=cocone_map_domain;target=cocone_map_codomain;ident;comp;
   equal_obj=equal_cocone cat;equal_arr}
let total_cone_category cat shape =
  let dc = diagrams_category cat shape in
  let ident c = {lm_domain=c;lm_base=dc.ident c.co_base;
    lm_apex=cat.ident c.co_apex;lm_codomain=c} in
  let comp (g,f) =
    if not (equal_cone cat f.lm_codomain g.lm_domain) then
      Error (Non_composable "cone map composition")
    else let* base = compose dc g.lm_base f.lm_base in
      let* apex = compose cat g.lm_apex f.lm_apex in
      cone_map f.lm_domain base apex g.lm_codomain in
  let equal_arr a b =
    equal_cone cat a.lm_domain b.lm_domain &&
    equal_cone cat a.lm_codomain b.lm_codomain &&
    dc.equal_arr a.lm_base b.lm_base && cat.equal_arr a.lm_apex b.lm_apex in
  {source=cone_map_domain;target=cone_map_codomain;ident;comp;
   equal_obj=equal_cone cat;equal_arr}

(* Shape restrictions used by finite universals. These preserve admitted bindings
   without sampling category callbacks again. The tail is always discrete. *)
let discrete_tail d =
  let nodes = match d.shape.nodes with [] -> [] | _ :: nodes -> nodes in
  { d with shape = { nodes; edges = [] };
           objects = List.filter (fun (n, _) -> List.mem n nodes) d.objects;
           arrows = [] }
let without_first_edge d =
  match d.shape.edges with
  | [] -> d
  | (edge, _, _) :: edges ->
    { d with shape = { d.shape with edges };
             arrows = List.remove_assoc edge d.arrows }
let graph_bindings g = g.edges
let cocone_sides c = c.cc_sides
open Foundations.Functor
let map_diagram f d =
  let open Foundations.Category in
  let* objects = traverse (fun n ->
    let* o = node_object d n in Ok (n,f.f_omap o)) (diagram_nodes d) in
  let* arrows = traverse (fun e ->
    let* a = edge_arrow d e in let* b = f.f_amap a in Ok (e,b))
    (diagram_edges d) in
  diagram f.f_cod (diagram_graph d) ~objects ~arrows
let map_cocone f c =
  let open Foundations.Category in let* base = map_diagram f (cocone_base c) in
  let* sides = traverse (fun n ->
    let* a = cocone_side c n in let* b = f.f_amap a in Ok (n,b))
    (diagram_nodes (cocone_base c)) in
  cocone base (f.f_omap (cocone_apex c)) ~sides
let map_cone f c =
  let open Foundations.Category in let* base = map_diagram f (cone_base c) in
  let* sides = traverse (fun n ->
    let* a = cone_side c n in let* b = f.f_amap a in Ok (n,b))
    (diagram_nodes (cone_base c)) in
  cone base (f.f_omap (cone_apex c)) ~sides

