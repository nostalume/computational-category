(* Comma objects and squares are admitted under coherent lawful L and R.
   All values supplied to one category must use those same functors. *)
open Foundations.Category
type ('oa,'ac,'ob) obj = { left : 'oa; link : 'ac; right : 'ob }
type ('oa,'aa,'ac,'ob,'ab) arrow = {
  src : ('oa,'ac,'ob) obj; left_map : 'aa; right_map : 'ab;
  tgt : ('oa,'ac,'ob) obj;
}
let left_object o = o.left
let right_object o = o.right
let connecting_arrow o = o.link
let source a = a.src
let target a = a.tgt
let left_arrow a = a.left_map
let right_arrow a = a.right_map
let object_ l r left link right =
  let* mapped_left = l.Foundations.Functor.f_omap left in
  let* mapped_right = r.Foundations.Functor.f_omap right in
  if has_endpoints l.Foundations.Functor.f_cod link mapped_left mapped_right then
    Ok {left;link;right}
  else Error (Non_composable "comma object: connecting endpoints")
let equal_object l r a b =
  l.Foundations.Functor.f_dom.equal_obj a.left b.left &&
  r.Foundations.Functor.f_dom.equal_obj a.right b.right &&
  l.Foundations.Functor.f_cod.equal_arr a.link b.link
let arrow l r src (left_map,right_map) tgt =
  if not (has_endpoints l.Foundations.Functor.f_dom left_map src.left tgt.left &&
          has_endpoints r.Foundations.Functor.f_dom right_map src.right tgt.right) then
    Error (Non_composable "comma arrow: component endpoints")
  else
    let* ls = l.Foundations.Functor.f_amap left_map in
    let* rt = r.Foundations.Functor.f_amap right_map in
    let* lhs = compose l.Foundations.Functor.f_cod tgt.link ls in
    let* rhs = compose l.Foundations.Functor.f_cod rt src.link in
    if l.Foundations.Functor.f_cod.equal_arr lhs rhs then
      Ok {src;left_map;right_map;tgt}
    else Error (Non_commuting "comma arrow square")
let category l r =
  let ident o = {src=o;tgt=o;left_map=l.Foundations.Functor.f_dom.ident o.left;
    right_map=r.Foundations.Functor.f_dom.ident o.right} in
  let comp (g,f) =
    if not (equal_object l r f.tgt g.src) then
      Error (Non_composable "comma composition: middle object")
    else
      let* a = compose l.Foundations.Functor.f_dom g.left_map f.left_map in
      let* b = compose r.Foundations.Functor.f_dom g.right_map f.right_map in
      arrow l r f.src (a,b) g.tgt in
  let equal_arr a b = equal_object l r a.src b.src &&
    equal_object l r a.tgt b.tgt &&
    l.Foundations.Functor.f_dom.equal_arr a.left_map b.left_map &&
    r.Foundations.Functor.f_dom.equal_arr a.right_map b.right_map in
  {source;target;ident;comp;equal_obj=equal_object l r;equal_arr}
let left_projection l r =
  {Foundations.Functor.f_dom=category l r;f_cod=l.Foundations.Functor.f_dom;
   f_omap=(fun o -> Ok (left_object o));f_amap=(fun a -> Ok a.left_map)}
let right_projection l r =
  {Foundations.Functor.f_dom=category l r;f_cod=r.Foundations.Functor.f_dom;
   f_omap=(fun o -> Ok (right_object o));f_amap=(fun a -> Ok a.right_map)}

(* Exercise 1: J:(F,I_A)->(I_B,G) preserves both projections. Its inverse
   replaces each connecting arrow by its adjoint transpose. *)
let adjunction_forward adj =
  let f = Universal.Adjunction.left adj and g = Universal.Adjunction.right adj in
  let ia = Foundations.Functor.id_functor f.f_cod and ib = Foundations.Functor.id_functor f.f_dom in
  let objects o =
    let* h = Universal.Adjunction.untranspose adj o.left o.right o.link in
    object_ ib g o.left h o.right in
  {Foundations.Functor.f_dom=category f ia;f_cod=category ib g;f_omap=objects;
   f_amap=(fun a -> let* s = objects a.src in let* t = objects a.tgt in
     arrow ib g s (a.left_map,a.right_map) t)}
let adjunction_backward adj =
  let f = Universal.Adjunction.left adj and g = Universal.Adjunction.right adj in
  let ia = Foundations.Functor.id_functor f.f_cod and ib = Foundations.Functor.id_functor f.f_dom in
  let objects o =
    let* h = Universal.Adjunction.transpose adj o.left o.right o.link in
    object_ f ia o.left h o.right in
  {Foundations.Functor.f_dom=category ib g;f_cod=category f ia;f_omap=objects;
   f_amap=(fun a -> let* s = objects a.src in let* t = objects a.tgt in
     arrow f ia s (a.left_map,a.right_map) t)}
let adjunction_of_isomorphism ~left:f ~right:g ~forward ~backward =
  let ia = Foundations.Functor.id_functor f.Foundations.Functor.f_cod in
  let ib = Foundations.Functor.id_functor f.Foundations.Functor.f_dom in
  let unit b =
    let* fb = f.Foundations.Functor.f_omap b in
    let* o = object_ f ia b (f.Foundations.Functor.f_cod.ident fb) fb in
    let* image = forward.Foundations.Functor.f_omap o in
    if f.Foundations.Functor.f_dom.equal_obj image.left b &&
      f.Foundations.Functor.f_cod.equal_obj image.right fb then Ok image.link
    else Error (Different_base "comma isomorphism: unit projections") in
  let counit a =
    let* ga = g.Foundations.Functor.f_omap a in
    let* o = object_ ib g ga (g.Foundations.Functor.f_cod.ident ga) a in
    let* image = backward.Foundations.Functor.f_omap o in
    if f.Foundations.Functor.f_dom.equal_obj image.left ga &&
      f.Foundations.Functor.f_cod.equal_obj image.right a then Ok image.link
    else Error (Different_base "comma isomorphism: counit projections") in
  Universal.Adjunction.of_unit_counit ~left:f ~right:g ~unit ~counit

(* Component evidence is retained for actual downstream use, e.g. edge labels.
   The ordinary colimit API merely returns the first component. *)
let colimit_with_projections a b cl r d =
  let l = cl.Universal.Preservation.cc_functor in
  let lp = left_projection l r and rp = right_projection l r in
  let* da = Universal.Diagrams.map_diagram lp d in
  let* db = Universal.Diagrams.map_diagram rp d in
  let* ca = a.Universal.Limits.cc_colimit da in
  let* cb = b.Universal.Limits.cc_colimit db in
  let* lc = cl.Universal.Preservation.cc_map ca in
  let* expected = Universal.Diagrams.map_cocone l ca.Universal.Limits.colim_cocone in
  let ccat = Universal.Diagrams.total_cocone_category l.Foundations.Functor.f_cod (Universal.Diagrams.diagram_graph da) in
  if not (ccat.equal_obj expected lc.Universal.Limits.colim_cocone) then
    Error (Different_base "comma preservation: expected mapped cocone")
  else
    let* rc = Universal.Diagrams.map_cocone r cb.Universal.Limits.colim_cocone in
    let* sides = traverse (fun n ->
      let* o = Universal.Diagrams.node_object d n in
      let* side = Universal.Diagrams.cocone_side rc n in
      let* a = compose l.Foundations.Functor.f_cod side o.link in Ok (n,a))
      (Universal.Diagrams.diagram_nodes d) in
    let* candidate = Universal.Diagrams.cocone (Universal.Diagrams.cocone_base lc.Universal.Limits.colim_cocone)
      (Universal.Diagrams.cocone_apex rc) ~sides in
    let* link = lc.Universal.Limits.colim_univ candidate in
    let* apex = object_ l r (Universal.Diagrams.cocone_apex ca.Universal.Limits.colim_cocone)
      (Universal.Diagrams.cocone_apex_arrow link) (Universal.Diagrams.cocone_apex cb.Universal.Limits.colim_cocone) in
    let* sides = traverse (fun n ->
      let* o = Universal.Diagrams.node_object d n in
      let* x = Universal.Diagrams.cocone_side ca.Universal.Limits.colim_cocone n in
      let* y = Universal.Diagrams.cocone_side cb.Universal.Limits.colim_cocone n in
      let* leg = arrow l r o (x,y) apex in Ok (n,leg)) (Universal.Diagrams.diagram_nodes d) in
    let* result = Universal.Diagrams.cocone d apex ~sides in
    let univ other =
      let* oa = Universal.Diagrams.map_cocone lp other in
      let* ob = Universal.Diagrams.map_cocone rp other in
      let* ua = ca.Universal.Limits.colim_univ oa in
      let* ub = cb.Universal.Limits.colim_univ ob in
      let* u = arrow l r apex
        (Universal.Diagrams.cocone_apex_arrow ua,Universal.Diagrams.cocone_apex_arrow ub)
        (Universal.Diagrams.cocone_apex other) in
      Universal.Diagrams.cocone_arrow result u other in
    Ok ({Universal.Limits.colim_cocone=result;colim_univ=univ},ca,cb)
let cocomplete a b cl r =
  let colimit d = let* c,_,_ = colimit_with_projections a b cl r d in Ok c in
  {Universal.Limits.cc_cat=category cl.Universal.Preservation.cc_functor r;cc_colimit=colimit}

let swap_object o = {left=o.right;link=o.link;right=o.left}
let swap_arrow a = {src=swap_object a.tgt;tgt=swap_object a.src;
  left_map=a.right_map;right_map=a.left_map}
let dual_to_swapped l r =
  {Foundations.Functor.f_dom=dual_cat (category l r);
   f_cod=category (Foundations.Functor.dual_functor r) (Foundations.Functor.dual_functor l);
   f_omap=(fun o -> Ok (swap_object o));f_amap=(fun a -> Ok (swap_arrow a))}
let swapped_to_dual l r =
  {Foundations.Functor.f_dom=category (Foundations.Functor.dual_functor r) (Foundations.Functor.dual_functor l);
   f_cod=dual_cat (category l r);
   f_omap=(fun o -> Ok (swap_object o));f_amap=(fun a -> Ok (swap_arrow a))}
let complete a b l cr =
  let r = cr.Universal.Preservation.ct_functor in
  let da = {Universal.Limits.cc_cat=dual_cat a.Universal.Limits.co_cat;
    cc_colimit=Universal.Limits.dual_limit a.Universal.Limits.co_limit} in
  let db = {Universal.Limits.cc_cat=dual_cat b.Universal.Limits.co_cat;
    cc_colimit=Universal.Limits.dual_limit b.Universal.Limits.co_limit} in
  let swapped = cocomplete db da (Universal.Preservation.dual_continuous cr)
    (Foundations.Functor.dual_functor l) in
  let colimit = Universal.Preservation.transport_colimit (dual_to_swapped l r)
    (swapped_to_dual l r) swapped.Universal.Limits.cc_colimit in
  {Universal.Limits.co_cat=category l r;co_limit=Universal.Limits.dual_colimit colimit}

(* Coslice coproducts do not require the constant left functor to preserve
   coproducts: their universal construction is a pushout of the two links. *)
let coslice_coproduct one underlying anchor (x,y) =
  let constant = {Foundations.Functor.f_dom=one;f_cod=underlying.Universal.Limits.cc_cat;
    f_omap=(fun _ -> Ok anchor);f_amap=(fun _ -> Ok (underlying.Universal.Limits.cc_cat.ident anchor))} in
  let id = Foundations.Functor.id_functor underlying.Universal.Limits.cc_cat in
  if not (underlying.Universal.Limits.cc_cat.equal_obj
    (underlying.Universal.Limits.cc_cat.source x.link) anchor &&
    underlying.Universal.Limits.cc_cat.equal_obj (underlying.Universal.Limits.cc_cat.source y.link) anchor) then
    Error (Non_composable "coslice: fixed anchor")
  else
    let* po, factor = Universal.Limits.pushout underlying (x.link,y.link) in
    let* link = compose underlying.Universal.Limits.cc_cat po.Universal.Limits.pushout_leg1 x.link in
    let* apex = object_ constant id x.left link po.Universal.Limits.pushout_obj in
    let* left = arrow constant id x
      (one.ident x.left,po.Universal.Limits.pushout_leg1) apex in
    let* right = arrow constant id y
      (one.ident y.left,po.Universal.Limits.pushout_leg2) apex in
    let univ z f g =
      let cat = category constant id in
      if not (has_endpoints cat f x z && has_endpoints cat g y z) then
        Error (Non_composable "coslice coproduct: leg endpoints")
      else
        let* u = factor z.right f.right_map g.right_map in
        arrow constant id apex (one.ident apex.left,u) z in
    Ok ({Universal.Limits.coprod_obj=apex;coprod_inj1=left;coprod_inj2=right},univ)

