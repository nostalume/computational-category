(* Bounded finite-domain law/oracle checks; general proofs are in the guide. *)
open Computational_category
module F = Instances.Finite_sets.Make (struct type t=int let equal (a:int) b=a=b end)
module U = Instances.Finite_set_universals.Make (F)
module K = Constructions.Functor_category
open Category_test_support.Checks
let set xs = F.carrier_of_list (List.map F.atom xs)
let objects = F.powerset (set [1;2])
let rec choices = function
  | [] -> [[]]
  | (x,ys)::rest -> List.concat_map (fun y ->
    List.map (fun tail -> (x,y)::tail) (choices rest)) ys
let maps a b = List.map (fun entries -> get (F.morphism_result a (fun x ->
  match List.find_opt (fun (y,_) -> F.equal x y) entries with
  | Some (_,z) -> Ok z | None -> Error (Foundations.Category.Outside_domain "mapping oracle")) b))
  (choices (List.map (fun x -> x,F.carrier_to_list b) (F.carrier_to_list a)))
module Walk = struct
  let cat = {Foundations.Category.source=fst;target=snd;ident=(fun x -> x,x);
    equal_obj=Bool.equal;equal_arr=(fun a b -> a=b);
    comp=(fun ((m,t),(s,n)) -> if m=n && (not s || n) && (not m || t)
      then Ok (s,t) else Error (Foundations.Category.Non_composable "walk"))}
  let domain = get (K.finite_domain cat ~objects:[false;true]
    ~arrows:[false,false;false,true;true,true])
end
let const a = get (K.constant_functor Walk.domain F.cat a)
let const_nat f fn = get (K.natural_transformation f f (fun _ ->
  let a = get (K.object_map f false) in F.morphism a fn a))
let triples = ref 0
let natural_count = ref 0
let mediator_count = ref 0
let laws cat arrows =
  let cp g f = get (Foundations.Category.compose cat g f) in
  List.iter (fun f ->
    check "natural left identity" (cat.Foundations.Category.equal_arr (cp (cat.Foundations.Category.ident (cat.Foundations.Category.target f)) f) f);
    check "natural right identity" (cat.Foundations.Category.equal_arr (cp f (cat.Foundations.Category.ident (cat.Foundations.Category.source f))) f);
    List.iter (fun g -> if cat.Foundations.Category.equal_obj (cat.Foundations.Category.target f) (cat.Foundations.Category.source g) then
      List.iter (fun h -> if cat.Foundations.Category.equal_obj (cat.Foundations.Category.target g) (cat.Foundations.Category.source h) then begin
        incr triples;
        check "vertical associativity" (cat.Foundations.Category.equal_arr (cp h (cp g f)) (cp (cp h g) f))
      end) arrows) arrows) arrows
let all_natural f g =
  let a = get (K.object_map f false) and b = get (K.object_map f true) in
  let x = get (K.object_map g false) and y = get (K.object_map g true) in
  List.concat_map (fun first -> List.filter_map (fun second ->
    match K.natural_transformation f g (fun o -> Ok (if o then second else first)) with
    | Ok n -> incr natural_count;Some n
    | Error (Foundations.Category.Non_commuting _) -> None
    | Error _ -> failwith "unexpected natural oracle admission") (maps b y)) (maps a x)
let test_admission () =
  reject_any "missing source identities" (K.finite_domain Walk.cat ~objects:[false;true]
    ~arrows:[false,true]);
  let object_calls=ref 0 and arrow_calls=ref 0 in
  let a = set [1;2] in
  let f = get (K.finite_functor Walk.domain F.cat
    ~objects:(fun _ -> incr object_calls;Ok a)
    ~arrows:(fun _ -> incr arrow_calls;Ok (F.identity a))) in
  check "map snapshot cardinality" (!object_calls=2 && !arrow_calls=3);
  let n_calls=ref 0 in
  let n = get (K.natural_transformation f f (fun _ -> incr n_calls;Ok (F.identity a))) in
  for _=1 to 20 do ignore (get (K.object_map f false));
    ignore (get (K.arrow_map f (false,true)));ignore (get (K.component n false)) done;
  check "snapshots not recalled" (!object_calls=2 && !arrow_calls=3 && !n_calls=2);
  let magnitude a b = abs a = abs b in
  let mc = {Foundations.Category.source=fst;target=snd;ident=(fun a -> a,a);
    comp=(fun ((s,t),(u,v)) -> if magnitude v s then Ok (u,t)
      else Error (Foundations.Category.Non_composable "magnitude category"));
    equal_obj=magnitude;equal_arr=(fun (s,t) (u,v) -> magnitude s u && magnitude t v)} in
  let md = get (K.finite_domain mc ~objects:[1;-1] ~arrows:[1,1;-1,-1]) in
  let md' = get (K.finite_domain mc ~objects:[-1] ~arrows:[-1,-1]) in
  let mf = get (K.constant_functor md F.cat a) in
  let mg = get (K.constant_functor md' F.cat (F.carrier_of_list (List.rev (F.carrier_to_list a)))) in
  check "finite-domain nonstructural equality" (List.length (K.objects md)=1 &&
    List.length (K.arrows md)=1 && K.equal_functor mf mg &&
    F.equal_carrier (get (K.object_map mf (-1))) a);
  ignore (get (K.natural_transformation mf mg (fun _ -> Ok (F.identity a))));
  let swap = get (F.morphism a (fun x -> if F.equal x (F.atom 1) then F.atom 2 else F.atom 1) a) in
  reject_any "non-natural components" (K.natural_transformation f f (fun o -> Ok (if o then swap else F.identity a)));
  reject_any "wrong identity map" (K.finite_functor Walk.domain F.cat ~objects:(fun _ -> Ok a)
    ~arrows:(fun _ -> Ok swap));
  reject_any "outside finite arrows" (K.arrow_map f (true,false));
  let diagonal=K.diagonal Walk.domain F.cat in
  let constant=Foundations.Functor.constant Constructions.Elementary.one
    (K.category Walk.domain F.cat) f in
  let cone=get (K.natural_transformation (get (diagonal.Foundations.Functor.f_omap a)) f (fun _ -> Ok (F.identity a))) in
  let comma=get (Constructions.Comma.object_ diagonal constant a cone ()) in
  let cone_category=Constructions.Comma.category diagonal constant in
  let ident=cone_category.Foundations.Category.ident comma in
  check "cones as comma objects" (cone_category.Foundations.Category.equal_arr
    (get (Foundations.Category.compose cone_category ident ident)) ident);
  let exn = Failure "object callback" in
  check "functor exception" (try ignore (K.finite_functor Walk.domain F.cat
    ~objects:(fun _ -> raise exn) ~arrows:(fun _ -> Ok (F.identity a)));false with e -> e==exn);
  let empty = get (K.finite_domain Constructions.Elementary.one ~objects:[] ~arrows:[]) in
  let e = get (K.constant_functor empty F.cat a) in
  let ec = K.category empty F.cat in laws ec [ec.Foundations.Category.ident e];
  let diagram = get (Universal.Diagrams.graph ~nodes:[] ~edges:[]) in
  let d = get (Universal.Diagrams.diagram ec diagram ~objects:[] ~arrows:[]) in
  ignore (get ((K.cocomplete empty U.cocomplete_finset).Universal.Limits.cc_colimit d));
  ignore (get ((K.complete empty U.complete_finset).Universal.Limits.co_limit d))

let test_vertical () =
  let fs = List.concat_map (fun a -> List.concat_map (fun b ->
    List.map (fun f -> get (K.finite_functor Walk.domain F.cat
      ~objects:(fun o -> Ok (if o then b else a))
      ~arrows:(fun (s,t) -> Ok (if s=t then F.identity (if s then b else a) else f))))
      (maps a b)) objects) objects in
  check "eighteen walking-arrow functors" (List.length fs=18);
  let ns = List.concat_map (fun f -> List.concat_map (all_natural f) fs) fs in
  laws (K.category Walk.domain F.cat) ns;
  List.iter (fun f -> check "double dual functor"
    (K.equal_functor f (K.dual_functor (K.dual_functor f)))) fs;
  List.iter (fun n -> check "double dual natural"
    (K.equal_natural_transformation n (K.dual_natural_transformation (K.dual_natural_transformation n)))) ns

let test_horizontal () =
  let all_arrows = List.concat_map (fun a -> List.concat_map (maps a) objects) objects in
  let d = get (K.finite_domain F.cat ~objects ~arrows:all_arrows) in
  let id = K.identity_functor d in
  let prod = get (K.finite_functor d F.cat ~objects:(fun a -> Ok (F.cartesian_prod a a))
    ~arrows:U.product_functor.Foundations.Functor.f_amap) in
  let diagonal = get (K.natural_transformation id prod (fun a ->
    F.morphism a (fun x -> F.pair x x) (F.cartesian_prod a a))) in
  let projection = get (K.natural_transformation prod id (fun a ->
    F.morphism_result (F.cartesian_prod a a) (fun x -> match F.view x with
      | F.Pair (l,_) -> Ok l | _ -> Error (Foundations.Category.Outside_domain "projection")) a)) in
  let f = const (set [1;2]) in
  let alpha = const_nat f (fun _ -> F.atom 1) in
  let beta = const_nat f (fun x -> if F.equal x (F.atom 1) then F.atom 2 else F.atom 1) in
  let fc = K.category Walk.domain F.cat and bc = K.category d F.cat in
  let vertical_a = get (Foundations.Category.compose fc beta alpha) in
  let vertical_b = get (Foundations.Category.compose bc projection diagonal) in
  let lhs = get (K.horizontal vertical_b vertical_a) in
  let first = get (K.horizontal diagonal alpha) in
  let second = get (K.horizontal projection beta) in
  let rhs = get (Foundations.Category.compose fc second first) in
  check "horizontal/vertical interchange" (K.equal_natural_transformation lhs rhs);
  let small = const (set [1]) in
  let inclusion = get (K.natural_transformation small f (fun _ ->
    F.morphism (set [1]) (fun x -> x) (set [1;2]))) in
  let crossed = get (K.horizontal diagonal inclusion) in
  List.iter (fun a ->
    let leg = get (K.component inclusion a) in
    let at_source = get (K.component diagonal (get (K.object_map small a))) in
    let alternative = get (Foundations.Category.compose F.cat (get (K.arrow_map prod leg)) at_source) in
    check "horizontal different source and target" (F.equal_morphism
      (get (K.component crossed a)) alternative)) (K.objects Walk.domain);
  List.iter (fun a ->
    let aa = get (K.component alpha a) in
    let beta_at = get (K.component diagonal (get (K.object_map f a))) in
    let other = get (Foundations.Category.compose F.cat (get (K.arrow_map prod aa)) beta_at) in
    check "both horizontal diagonals"
      (F.equal_morphism (get (K.component first a)) other)) (K.objects Walk.domain)

let test_pointwise () =
  let fc = K.category Walk.domain F.cat in
  let cc = K.cocomplete Walk.domain U.cocomplete_finset in
  let lc = K.complete Walk.domain U.complete_finset in
  let f = const (set [1;2]) and g = const (set [1]) in
  let cp,univ = get (Universal.Limits.coproduct cc (f,g)) in
  let to_g = get (K.natural_transformation f g (fun _ -> F.morphism (set [1;2]) (fun _ -> F.atom 1) (set [1]))) in
  let u = get (univ g to_g (fc.Foundations.Category.ident g)) in
  check "pointwise coproduct equation" (fc.Foundations.Category.equal_arr
    (get (Foundations.Category.compose fc u cp.Universal.Limits.coprod_inj1)) to_g);
  let candidates = all_natural cp.Universal.Limits.coprod_obj g in
  let valid = List.filter (fun k ->
    fc.Foundations.Category.equal_arr (get (Foundations.Category.compose fc k cp.Universal.Limits.coprod_inj1)) to_g &&
    fc.Foundations.Category.equal_arr (get (Foundations.Category.compose fc k cp.Universal.Limits.coprod_inj2)) (fc.Foundations.Category.ident g)) candidates in
  incr mediator_count;check "pointwise coproduct unique" (List.length valid=1);
  let product,univp = get (Universal.Limits.product lc (f,g)) in
  let into = get (univp f (fc.Foundations.Category.ident f) to_g) in
  check "pointwise product equation" (fc.Foundations.Category.equal_arr
    (get (Foundations.Category.compose fc product.Universal.Limits.prod_proj1 into)) (fc.Foundations.Category.ident f));
  let candidates = all_natural f product.Universal.Limits.prod_obj in
  let valid = List.filter (fun k ->
    fc.Foundations.Category.equal_arr (get (Foundations.Category.compose fc product.Universal.Limits.prod_proj1 k)) (fc.Foundations.Category.ident f) &&
    fc.Foundations.Category.equal_arr (get (Foundations.Category.compose fc product.Universal.Limits.prod_proj2 k)) to_g) candidates in
  incr mediator_count;check "pointwise product unique" (List.length valid=1);
  let alpha = const_nat f (fun _ -> F.atom 1) in
  let po,up = get (Universal.Limits.pushout cc (alpha,fc.Foundations.Category.ident f)) in
  let _ = get (up f (fc.Foundations.Category.ident f) alpha) in
  let pb,ub = get (Universal.Limits.pullback lc (alpha,fc.Foundations.Category.ident f)) in
  ignore (get (ub f (fc.Foundations.Category.ident f) alpha));
  check "functor pushout computed" (F.cardinality (get (K.object_map po.Universal.Limits.pushout_obj false))=2);
  check "functor pullback computed" (F.cardinality (get (K.object_map pb.Universal.Limits.pullback_obj true))=2)

let test_nonconstant_universals () =
  let one=set [1] and two=set [1;2] in
  let injection=get (F.morphism one (fun x->x) two) in
  let f=get (K.finite_functor Walk.domain F.cat ~objects:(fun o -> Ok (if o then two else one))
    ~arrows:(fun (s,t) -> Ok (if s=t then F.identity (if s then two else one) else injection))) in
  let fc=K.category Walk.domain F.cat in
  let cp,univ=get (Universal.Limits.coproduct (K.cocomplete Walk.domain U.cocomplete_finset) (f,f)) in
  let apex=cp.Universal.Limits.coprod_obj in
  check "nonconstant pointwise objects" (F.cardinality (get (K.object_map apex false))=2 &&
    F.cardinality (get (K.object_map apex true))=4);
  let mapped=get (K.arrow_map apex (false,true)) in
  check "nonconstant pointwise arrow endpoints" (F.equal_carrier (F.domain mapped) (get (K.object_map apex false)) &&
    F.equal_carrier (F.codomain mapped) (get (K.object_map apex true)));
  let target=const two in
  let leg=get (K.natural_transformation f target (fun o -> Ok (if o then F.identity two else injection))) in
  let mediator=get (univ target leg leg) in
  let candidates=List.filter (fun n ->
    fc.Foundations.Category.equal_arr (get (Foundations.Category.compose fc n cp.Universal.Limits.coprod_inj1)) leg &&
    fc.Foundations.Category.equal_arr (get (Foundations.Category.compose fc n cp.Universal.Limits.coprod_inj2)) leg) (all_natural apex target) in
  incr mediator_count;
  check "nonconstant pointwise unique mediator" (List.length candidates=1 &&
    fc.Foundations.Category.equal_arr (List.hd candidates) mediator);
  let prod,univ=get (Universal.Limits.product (K.complete Walk.domain U.complete_finset) (f,f)) in
  let pair=get (univ f (fc.Foundations.Category.ident f) (fc.Foundations.Category.ident f)) in
  check "nonconstant dual product projection" (fc.Foundations.Category.equal_arr
    (get (Foundations.Category.compose fc prod.Universal.Limits.prod_proj1 pair)) (fc.Foundations.Category.ident f))

let () =
  List.iter (fun (name,test) -> test ();Printf.printf "PASS %s\n%!" name)
    ["finite functor admission and snapshots",test_admission;
     "vertical natural transformations and duality",test_vertical;
     "horizontal composition and interchange",test_horizontal;
     "pointwise colimits and limits",(fun () -> test_pointwise ();test_nonconstant_universals ())];
  Printf.printf "Functor-category coverage: %d natural admissions, %d law triples, %d exhaustive selected mediators.\n%!"
    !natural_count !triples !mediator_count

