open Foundations.Category
let one = {source=(fun () -> ());target=(fun () -> ());ident=(fun () -> ());
  equal_obj=(fun () () -> true);equal_arr=(fun () () -> true);
  comp=(fun ((),()) -> Ok ())}
let one_cocomplete =
  let colimit d =
    let* c = Universal.Diagrams.cocone d () ~sides:(List.map (fun n -> n,()) (Universal.Diagrams.diagram_nodes d)) in
    Ok {Universal.Limits.colim_cocone=c;colim_univ=(fun other -> Universal.Diagrams.cocone_arrow c () other)} in
  {Universal.Limits.cc_cat=one;cc_colimit=colimit}
let one_complete =
  {Universal.Limits.co_cat=one;
   co_limit=Universal.Limits.dual_colimit one_cocomplete.Universal.Limits.cc_colimit}
let product a b =
  {source=(fun (f,g) -> a.source f,b.source g);
   target=(fun (f,g) -> a.target f,b.target g);
   ident=(fun (x,y) -> a.ident x,b.ident y);
   equal_obj=(fun (x,y) (u,v) -> a.equal_obj x u && b.equal_obj y v);
   equal_arr=(fun (f,g) (h,k) -> a.equal_arr f h && b.equal_arr g k);
   comp=(fun ((g,h),(f,k)) ->
     let* x = compose a g f in let* y = compose b h k in Ok (x,y))}
let first a b =
  {Foundations.Functor.f_dom=product a b;f_cod=a;f_omap=(fun (x,_) -> Ok x);f_amap=(fun (f,_) -> Ok f)}
let second a b =
  {Foundations.Functor.f_dom=product a b;f_cod=b;f_omap=(fun (_,y) -> Ok y);f_amap=(fun (_,g) -> Ok g)}
let cocomplete_product a b =
  let cat = product a.Universal.Limits.cc_cat b.Universal.Limits.cc_cat in
  let l = first a.Universal.Limits.cc_cat b.Universal.Limits.cc_cat in
  let r = second a.Universal.Limits.cc_cat b.Universal.Limits.cc_cat in
  let colimit d =
    let* da = Universal.Diagrams.map_diagram l d in let* db = Universal.Diagrams.map_diagram r d in
    let* ca = a.Universal.Limits.cc_colimit da in let* cb = b.Universal.Limits.cc_colimit db in
    let* sides = traverse (fun n ->
      let* x = Universal.Diagrams.cocone_side ca.Universal.Limits.colim_cocone n in
      let* y = Universal.Diagrams.cocone_side cb.Universal.Limits.colim_cocone n in Ok (n,(x,y)))
      (Universal.Diagrams.diagram_nodes d) in
    let* result = Universal.Diagrams.cocone d
      (Universal.Diagrams.cocone_apex ca.Universal.Limits.colim_cocone,Universal.Diagrams.cocone_apex cb.Universal.Limits.colim_cocone)
      ~sides in
    let univ other =
      let* x = Universal.Diagrams.map_cocone l other in let* y = Universal.Diagrams.map_cocone r other in
      let* u = ca.Universal.Limits.colim_univ x in let* v = cb.Universal.Limits.colim_univ y in
      Universal.Diagrams.cocone_arrow result
        (Universal.Diagrams.cocone_apex_arrow u,Universal.Diagrams.cocone_apex_arrow v) other in
    Ok {Universal.Limits.colim_cocone=result;colim_univ=univ} in
  {Universal.Limits.cc_cat=cat;cc_colimit=colimit}
let complete_product a b =
  let da = {Universal.Limits.cc_cat=dual_cat a.Universal.Limits.co_cat;
    cc_colimit=Universal.Limits.dual_limit a.Universal.Limits.co_limit} in
  let db = {Universal.Limits.cc_cat=dual_cat b.Universal.Limits.co_cat;
    cc_colimit=Universal.Limits.dual_limit b.Universal.Limits.co_limit} in
  let dual = cocomplete_product da db in
  {Universal.Limits.co_cat=product a.Universal.Limits.co_cat b.Universal.Limits.co_cat;
   co_limit=Universal.Limits.dual_colimit dual.Universal.Limits.cc_colimit}
let slice category anchor =
  Comma.category (Foundations.Functor.id_functor category) (Foundations.Functor.constant one category anchor)
let coslice category anchor =
  Comma.category (Foundations.Functor.constant one category anchor) (Foundations.Functor.id_functor category)

let initial_adjunction cat initial =
  Universal.Adjunction.of_universal ~right:(Foundations.Functor.constant cat one ())
    (fun () -> Ok {Universal.Adjunction.free_object=initial.Universal.Limits.init_obj;
      unit_arrow=();factor=(fun o () -> initial.Universal.Limits.init_univ o)})

(* Exercises 5/6 are couniversal choices. Build their right adjoints by the
   one universal-arrow construction in opposite categories. *)
let slice_postcompose complete h =
  let cat = complete.Universal.Limits.co_cat in
  let a = cat.source h and b = cat.target h in
  let id = Foundations.Functor.id_functor cat in
  let ka = Foundations.Functor.constant one cat a and kb = Foundations.Functor.constant one cat b in
  let objects o =
    let* link = compose cat h (Comma.connecting_arrow o) in
    Comma.object_ id kb (Comma.left_object o) link () in
  let sigma = {Foundations.Functor.f_dom=slice cat a;f_cod=slice cat b;f_omap=objects;
    f_amap=(fun u -> let* s = objects (Comma.source u) in let* t = objects (Comma.target u) in
      Comma.arrow id kb s (Comma.left_arrow u,()) t)} in
  let choose v =
    let* pb,factor = Universal.Limits.pullback complete (h,Comma.connecting_arrow v) in
    let* free_object = Comma.object_ id ka pb.Universal.Limits.pullback_obj
      pb.Universal.Limits.pullback_proj1 () in
    let* image = objects free_object in
    let* unit_arrow = Comma.arrow id kb image (pb.Universal.Limits.pullback_proj2,()) v in
    let lift other u =
      let* k = factor (Comma.left_object other) (Comma.connecting_arrow other) (Comma.left_arrow u) in
      Comma.arrow id ka other (k,()) free_object in
    Ok {Universal.Adjunction.free_object;unit_arrow;factor=lift} in
  Universal.Adjunction.dual
    (Universal.Adjunction.of_universal ~right:(Foundations.Functor.dual_functor sigma) choose)

let slice_carrier cat product anchor =
  let id = Foundations.Functor.id_functor cat in
  let constant = Foundations.Functor.constant one cat anchor in
  let forget = {Foundations.Functor.f_dom=slice cat anchor;f_cod=cat;
    f_omap=(fun o -> Ok (Comma.left_object o));f_amap=(fun a -> Ok (Comma.left_arrow a))} in
  let choose o =
    let* p,factor = product (o,anchor) in
    let* free_object = Comma.object_ id constant p.Universal.Limits.prod_obj
      p.Universal.Limits.prod_proj2 () in
    let lift other h =
      let* k = factor (Comma.left_object other) h (Comma.connecting_arrow other) in
      Comma.arrow id constant other (k,()) free_object in
    Ok {Universal.Adjunction.free_object;unit_arrow=p.Universal.Limits.prod_proj1;factor=lift} in
  Universal.Adjunction.dual
    (Universal.Adjunction.of_universal ~right:(Foundations.Functor.dual_functor forget) choose)

module Twisted : sig
  type 'a arrow
  val source : 'a arrow -> 'a
  val target : 'a arrow -> 'a
  val forward : 'a arrow -> 'a
  val backward : 'a arrow -> 'a
  val arrow : ('o,'a) Foundations.Category.cat -> 'a -> 'a * 'a -> 'a -> ('a arrow,Foundations.Category.error) result
  val category : ('o,'a) Foundations.Category.cat -> ('a,'a arrow) Foundations.Category.cat

end = struct
  (* Exercise 8: f = k o f' o h. The second component composes contravariantly. *)
  open Foundations.Category
  type 'a arrow = {src:'a;forward:'a;backward:'a;tgt:'a}
  let source a = a.src
  let target a = a.tgt
  let forward a = a.forward
  let backward a = a.backward
  let arrow cat src (forward,backward) tgt =
    if not (has_endpoints cat forward (cat.source src) (cat.source tgt) &&
            has_endpoints cat backward (cat.target tgt) (cat.target src)) then
      Error (Non_composable "twisted arrow: endpoints")
    else
      let* a = compose cat tgt forward in let* b = compose cat backward a in
      if cat.equal_arr src b then Ok {src;forward;backward;tgt}
      else Error (Non_commuting "twisted arrow square")
  let category cat =
    let ident f = {src=f;tgt=f;forward=cat.ident (cat.source f);
      backward=cat.ident (cat.target f)} in
    let comp (g,f) =
      if not (cat.equal_arr f.tgt g.src) then
        Error (Non_composable "twisted composition")
      else
        let* h = compose cat g.forward f.forward in
        let* k = compose cat f.backward g.backward in
        arrow cat f.src (h,k) g.tgt in
    let equal_arr a b = cat.equal_arr a.src b.src && cat.equal_arr a.tgt b.tgt &&
      cat.equal_arr a.forward b.forward && cat.equal_arr a.backward b.backward in
    {source;target;ident;comp;equal_obj=cat.equal_arr;equal_arr}


end
