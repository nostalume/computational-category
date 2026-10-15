open Computational_category
module F = Instances.Finite_sets.Make (struct type t = string let equal = String.equal end)
module U = Instances.Finite_set_universals.Make (F)
module G = Instances.Finite_graphs.Make (F)
open Category_test_support.Checks
let v = F.atom
let set xs = F.carrier_of_list (List.map v xs)
let amap a x = get (F.eval a x)
let comp cat g f = get (Foundations.Category.compose cat g f)
let law_triples = ref 0
let laws cat arrows =
  List.iter (fun f ->
    check "left identity" (cat.Foundations.Category.equal_arr (comp cat (cat.Foundations.Category.ident (cat.Foundations.Category.target f)) f) f);
    check "right identity" (cat.Foundations.Category.equal_arr (comp cat f (cat.Foundations.Category.ident (cat.Foundations.Category.source f))) f);
    List.iter (fun g ->
      if cat.Foundations.Category.equal_obj (cat.Foundations.Category.target f) (cat.Foundations.Category.source g) then
        let gf = comp cat g f in
        List.iter (fun h ->
          if cat.Foundations.Category.equal_obj (cat.Foundations.Category.target g) (cat.Foundations.Category.source h) then begin
            incr law_triples;
            check "associativity" (cat.Foundations.Category.equal_arr
              (comp cat h gf) (comp cat (comp cat h g) f))
          end) arrows
      else reject_any "noncomposable pair" (Foundations.Category.compose cat g f)) arrows) arrows
let graph ns es = get (G.graph ~nodes:(set ns)
  ~edges:(List.map (fun (e,s,t) -> v e,v s,v t) es))
let gmap a b edge node =
  get (G.graph_morphism a ~edges:(get (F.morphism_result (G.edges a) edge (G.edges b)))
    ~nodes:(get (F.morphism_result (G.nodes a) node (G.nodes b))) b)
let lookup xs x =
  match List.find_opt (fun (a,_) -> F.equal x (v a)) xs with
  | Some (_,b) -> Ok (v b) | None -> Error (Foundations.Category.Outside_domain "test binding")
let map_names a b es ns = gmap a b (lookup es) (lookup ns)
let inclusion a b = gmap a b (fun x -> Ok x) (fun x -> Ok x)
let inverse a =
  F.morphism_result (F.codomain a) (fun y ->
    match List.filter (fun x -> F.equal (amap a x) y) (F.carrier_to_list (F.domain a)) with
    | [x] -> Ok x | _ -> Error (Foundations.Category.Non_commuting "not a bijection")) (F.domain a)
let book () =
  let a = graph ["A";"B";"C"] ["E","B","A";"F","B","C"] in
  let b = graph ["A";"B";"C";"D"] ["E","B","A";"F","B","C";"G","A","C";"H","B","D"] in
  let c = graph ["A";"B";"D"] ["F","A","B";"G","A","D";"H","B","D"] in
  let f = inclusion a b in
  let g = map_names a c ["E","F";"F","F"] ["A","B";"B","A";"C","B"] in
  a,b,c,f,g

let test_morphisms () =
  let a = set ["a";"b"] in
  let shape = get (Universal.Diagrams.graph ~nodes:["s";"t"] ~edges:["e","s","t"]) in
  let d = get (Universal.Diagrams.diagram F.cat shape ~objects:["s",a;"t",a]
    ~arrows:["e",F.identity a]) in
  let dc = Universal.Diagrams.diagrams_category F.cat shape in
  let id = dc.Foundations.Category.ident d in laws dc [id];
  let swap = get (F.morphism a (fun x -> if F.equal x (v "a") then v "b" else v "a") a) in
  reject_any "diagram naturality" (Universal.Diagrams.diagram_arrow d d ~components:["s",swap;"t",F.identity a]);
  let both = get (Universal.Diagrams.diagram_arrow d d ~components:["s",swap;"t",swap]) in
  laws dc [id;both];
  let cc = get (U.colimit d) and lc = get (U.limit d) in
  let cm = get (Universal.Limits.map_colimit id cc cc) and lm = get (Universal.Limits.map_limit id lc lc) in
  let tc = Universal.Diagrams.total_cocone_category F.cat shape in
  let tl = Universal.Diagrams.total_cone_category F.cat shape in
  laws tc [cm]; laws tl [lm];
  check "chosen colimit map identity" (F.equal_morphism (Universal.Diagrams.cocone_map_apex cm)
    (F.identity (Universal.Diagrams.cocone_apex cc.Universal.Limits.colim_cocone)));
  check "chosen limit map identity" (F.equal_morphism (Universal.Diagrams.cone_map_apex lm)
    (F.identity (Universal.Diagrams.cone_apex lc.Universal.Limits.lim_cone)));
  let mapped = get (Universal.Diagrams.map_diagram U.product_functor d) in
  check "mapped product object" (F.cardinality (get (Universal.Diagrams.node_object mapped "s")) = 4);
  let preserved = get (U.product_continuous.Universal.Preservation.ct_map lc) in
  let self = get (preserved.Universal.Limits.lim_univ preserved.Universal.Limits.lim_cone) in
  check "X preserves universal identity" (F.equal_morphism (Universal.Diagrams.cone_apex_arrow self)
    (F.identity (Universal.Diagrams.cone_apex preserved.Universal.Limits.lim_cone)));
  let failure = Foundations.Category.Outside_domain "diagram object construction" in
  let object_calls = ref 0 and arrow_calls = ref 0 in
  let failing = {Foundations.Functor.f_dom=F.cat;f_cod=F.cat;
    f_omap=(fun _ -> incr object_calls; Error failure);
    f_amap=(fun h -> incr arrow_calls; Ok h)} in
  reject "diagram object failure unchanged" ((==) failure) (Universal.Diagrams.map_diagram failing d);
  check "diagram failure stops remaining objects and arrows" (!object_calls=1 && !arrow_calls=0);
  let empty_shape = get (Universal.Diagrams.graph ~nodes:[] ~edges:[]) in
  let empty = get (Universal.Diagrams.diagram F.cat empty_shape ~objects:[] ~arrows:[]) in
  ignore (get (Universal.Diagrams.map_diagram failing empty));
  check "empty diagram samples no objects" (!object_calls=1);
  let co = get (Universal.Diagrams.cocone empty a ~sides:[]) in
  let li = get (Universal.Diagrams.cone empty a ~sides:[]) in
  reject "cocone apex failure unchanged" ((==) failure) (Universal.Diagrams.map_cocone failing co);
  reject "cone apex failure unchanged" ((==) failure) (Universal.Diagrams.map_cone failing li);
  check "empty cone/cocone still maps apex" (!object_calls=3 && !arrow_calls=0);
  let calls = ref 0 in
  let apex_failing = {failing with Foundations.Functor.f_omap=(fun x ->
    incr calls; if !calls=3 then Error failure else Ok x)} in
  let co = get (Universal.Diagrams.cocone d a ~sides:["s",F.identity a;"t",F.identity a]) in
  let li = get (Universal.Diagrams.cone d a ~sides:["s",F.identity a;"t",F.identity a]) in
  List.iter (fun map ->
    calls:=0; arrow_calls:=0;
    reject "nonempty apex failure unchanged" ((==) failure) (map ());
    check "apex failure stops side maps" (!calls=3 && !arrow_calls=1))
    [(fun () -> Result.map (fun _ -> ()) (Universal.Diagrams.map_cocone apex_failing co));
     (fun () -> Result.map (fun _ -> ()) (Universal.Diagrams.map_cone apex_failing li))];
  let exception Object_probe of int ref in
  let sentinel = ref 21 in
  let throwing = {failing with Foundations.Functor.f_omap=(fun _ -> raise (Object_probe sentinel))} in
  let threw = try ignore (Universal.Diagrams.map_diagram throwing d); false
    with Object_probe p -> p == sentinel in
  check "diagram object exception unchanged" threw;
  let id = Foundations.Functor.id_functor F.cat in
  reject "comma left object failure unchanged" ((==) failure)
    (Constructions.Comma.object_ failing id a (F.identity a) a);
  reject "comma right object failure unchanged" ((==) failure)
    (Constructions.Comma.object_ id failing a (F.identity a) a);
  calls:=0;
  let right = {id with Foundations.Functor.f_omap=(fun x -> incr calls; Ok x)} in
  reject "comma left failure stops right map" ((==) failure)
    (Constructions.Comma.object_ failing right a (F.identity a) a);
  check "comma right map not called" (!calls=0)

module Bool_cat = struct
  let valid (s,t) = not s || t
  let cat = {Foundations.Category.source=fst;target=snd;ident=(fun x -> x,x);
    equal_obj=Bool.equal;equal_arr=(fun a b -> a=b);
    comp=(fun ((m,t),(s,n)) -> if m=n && valid (m,t) && valid (s,n)
      then Ok (s,t) else Error (Foundations.Category.Non_composable "boolean"))}
end
let test_comma () =
  let id = Foundations.Functor.id_functor Bool_cat.cat in
  let cat = Constructions.Comma.category id id in
  let objs = List.map (fun (a,b) -> get (Constructions.Comma.object_ id id a (a,b) b))
    [false,false;false,true;true,true] in
  let arrows = List.concat_map (fun a -> List.filter_map (fun b ->
    let l = Constructions.Comma.left_object a,Constructions.Comma.left_object b in
    let r = Constructions.Comma.right_object a,Constructions.Comma.right_object b in
    if Bool_cat.valid l && Bool_cat.valid r then
      Some (get (Constructions.Comma.arrow id id a (l,r) b)) else None) objs) objs in
  laws cat arrows;
  let iso = Constructions.Comma.dual_to_swapped id id in
  let back = Constructions.Comma.swapped_to_dual id id in
  List.iter (fun o -> check "comma dual object inverse"
    (cat.Foundations.Category.equal_obj (get (back.Foundations.Functor.f_omap (get (iso.Foundations.Functor.f_omap o)))) o)) objs;
  List.iter (fun a -> check "comma dual arrow inverse" (cat.Foundations.Category.equal_arr
    (get (back.Foundations.Functor.f_amap (get (iso.Foundations.Functor.f_amap a)))) a)) arrows;
  let fid = Foundations.Functor.id_functor F.cat in let a = set ["a";"b"] in
  let o = get (Constructions.Comma.object_ fid fid a (F.identity a) a) in
  let swap = get (F.morphism a (fun x -> if F.equal x (v "a") then v "b" else v "a") a) in
  reject_any "comma square" (Constructions.Comma.arrow fid fid o (swap,F.identity a) o);
  reject_any "comma object endpoints" (Constructions.Comma.object_ fid fid F.empty (F.identity a) a);
  let exn = Failure "comma callback" in
  let bad = {fid with Foundations.Functor.f_amap=(fun _ -> raise exn)} in
  check "callback propagates" (try ignore (Constructions.Comma.arrow bad fid o
    (F.identity a,F.identity a) o);false with e -> e==exn)

let test_graph_pushout () =
  let _,b,c,f,g = book () in
  let po,univ = get (Universal.Limits.pushout G.cocomplete (f,g)) in
  let apex = po.Universal.Limits.pushout_obj in
  check "book four nodes" (F.cardinality (G.nodes apex)=4);
  check "book five edges" (F.cardinality (G.edges apex)=5);
  check "graph pushout square" (G.category.Foundations.Category.equal_arr
    (comp G.category po.Universal.Limits.pushout_leg1 f) (comp G.category po.Universal.Limits.pushout_leg2 g));
  let expected = graph ["pB";"pA";"bD";"cD"]
    ["pE","pB","pA";"bH","pB","bD";"bG","pA","pA";"cH","pA","cD";"cG","pB","cD"] in
  let h = map_names b expected ["E","pE";"F","pE";"G","bG";"H","bH"]
    ["A","pA";"B","pB";"C","pA";"D","bD"] in
  let k = map_names c expected ["F","pE";"G","cG";"H","cH"]
    ["A","pB";"B","pA";"D","cD"] in
  let u = get (univ expected h k) in
  let inv = get (G.graph_morphism expected ~edges:(get (inverse (G.edge_map u)))
    ~nodes:(get (inverse (G.node_map u))) apex) in
  check "book graph iso inverse 1" (G.category.Foundations.Category.equal_arr (comp G.category inv u)
    (G.category.Foundations.Category.ident apex));
  check "book graph iso inverse 2" (G.category.Foundations.Category.equal_arr (comp G.category u inv)
    (G.category.Foundations.Category.ident expected));
  check "book graph mediator leg" (G.category.Foundations.Category.equal_arr
    (comp G.category u po.Universal.Limits.pushout_leg1) h);
  let self = get (univ apex po.Universal.Limits.pushout_leg1 po.Universal.Limits.pushout_leg2) in
  check "graph universal identity" (G.category.Foundations.Category.equal_arr self (G.category.Foundations.Category.ident apex))

let test_graph_limits () =
  let a,b,_,f,_ = book () in
  let p,univ = get (G.product (a,b)) in
  check "graph product nodes" (F.cardinality (G.nodes p.Universal.Limits.prod_obj)=12);
  check "graph product edges" (F.cardinality (G.edges p.Universal.Limits.prod_obj)=8);
  let paired = get (univ a (G.category.Foundations.Category.ident a) f) in
  check "graph product left" (G.category.Foundations.Category.equal_arr
    (comp G.category p.Universal.Limits.prod_proj1 paired) (G.category.Foundations.Category.ident a));
  check "graph product right" (G.category.Foundations.Category.equal_arr
    (comp G.category p.Universal.Limits.prod_proj2 paired) f);
  let empty = graph [] [] in
  let e,_ = get (G.product (a,empty)) in
  check "empty graph product" (F.is_empty (G.nodes e.Universal.Limits.prod_obj));
  reject_any "graph dangling endpoints" (G.graph ~nodes:(set ["a"]) ~edges:[v "e",v "a",v "b"]);
  reject_any "graph duplicate edges" (G.graph ~nodes:(set ["a"])
    ~edges:[v "e",v "a",v "a";v "e",v "a",v "a"])

let test_product_slice () =
  let pc = Constructions.Elementary.product F.cat Constructions.Elementary.one in
  let a = set ["a"] in laws pc [F.identity a,()];
  let caps = Constructions.Elementary.cocomplete_product U.cocomplete_finset
    Constructions.Elementary.one_cocomplete in
  let d,univ = get (Universal.Limits.coproduct caps ((a,()),(a,()))) in
  check "component coproduct" (F.cardinality (fst d.Universal.Limits.coprod_obj)=2);
  let u = get (univ (a,()) (F.identity a,()) (F.identity a,())) in
  check "component mediator" (F.cardinality (F.domain (fst u))=2);
  let complete=Constructions.Elementary.complete_product U.complete_finset
    Constructions.Elementary.one_complete in
  let p,_=get (Universal.Limits.product complete ((a,()),(set ["a";"b"],()))) in
  check "component product" (F.cardinality (fst p.Universal.Limits.prod_obj)=2);
  let anchor = a in
  let constant = Foundations.Functor.constant Constructions.Elementary.one F.cat anchor in
  let id = Foundations.Functor.id_functor F.cat in
  let b = set ["a";"b"] and c = set ["a";"c"] in
  let x = get (Constructions.Comma.object_ constant id () (get (F.morphism a (fun x->x) b)) b) in
  let y = get (Constructions.Comma.object_ constant id () (get (F.morphism a (fun x->x) c)) c) in
  let cp,_ = get (Constructions.Comma.coslice_coproduct Constructions.Elementary.one
    U.cocomplete_finset anchor (x,y)) in
  check "coslice glues anchor rather than disjoint coproduct"
    (F.cardinality (Constructions.Comma.right_object cp.Universal.Limits.coprod_obj)=3);
  let slice = Constructions.Elementary.slice F.cat anchor in
  let si = get (Constructions.Comma.object_ id constant a (F.identity a) ()) in
  laws slice [slice.Foundations.Category.ident si]

let test_twisted () =
  let module T = Category_test_support.Toy_category in
  let arrows = [T.F;T.G;T.H;T.K;T.Id T.A;T.Id T.B;T.Id T.C] in
  let twisted = List.concat_map (fun f -> List.concat_map (fun g ->
    List.concat_map (fun h -> List.filter_map (fun k ->
      match Constructions.Elementary.Twisted.arrow T.cat f (h,k) g with
      | Ok a -> Some a | Error _ -> None) arrows) arrows) arrows) arrows in
  laws (Constructions.Elementary.Twisted.category T.cat) twisted

let test_labels_rewriting () =
  let alphabet = set ["x";"y"] in
  let a = graph ["a"] ["e","a","a"] in
  let labels = get (F.morphism (G.edges a) (fun _ -> v "x") alphabet) in
  let la = get (G.Labelled.labelled ~alphabet a labels) in
  let lc = G.Labelled.labelled_cocomplete alphabet in
  let cp,univ = get (Universal.Limits.coproduct lc (la,la)) in
  check "labelled graph coproduct" (F.cardinality (G.edges (G.Labelled.underlying cp.Universal.Limits.coprod_obj))=2);
  let id = lc.Universal.Limits.cc_cat.Foundations.Category.ident la in
  let u = get (univ la id id) in
  check "labelled coproduct equation" (lc.Universal.Limits.cc_cat.Foundations.Category.equal_arr
    (comp lc.Universal.Limits.cc_cat u cp.Universal.Limits.coprod_inj1) id);
  let wrong = get (G.Labelled.labelled ~alphabet a
    (get (F.morphism (G.edges a) (fun _ -> v "y") alphabet))) in
  reject_any "label preservation" (G.Labelled.labelled_morphism ~alphabet la (G.category.Foundations.Category.ident a) wrong);
  let k = graph ["a"] [] in
  let left = graph ["a";"b"] ["e","a","b"] in
  let right = graph ["a";"c"] ["f","a","c"] in
  let l = inclusion k left and r = inclusion k right in
  let rewritten = get (G.Rewriting.rewrite ~interface_to_left:l ~interface_to_right:r
    ~matched:(G.category.Foundations.Category.ident left)) in
  check "DPO removes and adds node" (F.cardinality (G.nodes rewritten.G.Rewriting.result)=2);
  check "DPO removes and adds edge" (F.cardinality (G.edges rewritten.G.Rewriting.result)=1);
  let badhost = graph ["a";"b";"z"] ["e","a","b";"dangling","z","b"] in
  reject_any "DPO dangling condition" (G.Rewriting.rewrite ~interface_to_left:l ~interface_to_right:r
    ~matched:(inclusion left badhost));
  let collapsed = gmap left a (fun _ -> Ok (v "e")) (fun _ -> Ok (v "a")) in
  reject_any "DPO noninjective match" (G.Rewriting.rewrite ~interface_to_left:l ~interface_to_right:r ~matched:collapsed)

let () =
  List.iter (fun (label,test) -> test (); Printf.printf "PASS %s\n%!" label)
    ["diagram and universal functor maps",test_morphisms;
     "comma admission, laws and duality",test_comma;
     "book graph pushout",test_graph_pushout;
     "graph products and limits",test_graph_limits;
     "product and slice categories",test_product_slice;
     "twisted arrow category",test_twisted;
     "edge labels and DPO rewriting",test_labels_rewriting];
  Printf.printf "Construction coverage: %d law triples.\n%!" !law_triples

