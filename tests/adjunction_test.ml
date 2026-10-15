open Computational_category
open Category_test_support.Checks
open Category_test_support.Finite_set_fixture
module F = I
module C = Foundations.Category
module K = Foundations.Functor
module A = Universal.Adjunction
module D = Universal.Diagrams
module L = Universal.Limits
module P = Universal.Preservation
module Q = Constructions.Comma
module E = Constructions.Elementary
module G = Instances.Finite_graphs.Make (F)
let roundtrip_count = ref 0
let unique_count = ref 0

let roundtrips adj b a inputs outputs =
  let left = A.left adj and right = A.right adj in
  check "hom sets have same cardinality" (List.length inputs=List.length outputs);
  List.iter (fun h ->
    incr roundtrip_count;
    let u = get (A.transpose adj b a h) in
    check "transpose/untranspose" (right.K.f_cod.C.equal_arr (get (A.untranspose adj b a u)) h)) inputs;
  List.iter (fun h ->
    incr roundtrip_count;
    let u = get (A.untranspose adj b a h) in
    check "untranspose/transpose" (left.K.f_cod.C.equal_arr (get (A.transpose adj b a u)) h)) outputs;
  ignore (get (A.check_triangles adj b a))

let swap a =
  match F.carrier_to_list a with
  | x::y::_ -> get (F.morphism a (fun z -> if F.equal z x then y else if F.equal z y then x else z) a)
  | _ -> F.identity a
let twisted = A.of_universal ~right:(K.id_functor F.cat) (fun b ->
  Ok {A.free_object=b;unit_arrow=swap b;factor=(fun _ h -> F.compose h (swap b))})

let test_core () =
  let eta = A.unit twisted and eps = A.counit twisted in
  let converted = A.of_unit_counit ~left:(A.left twisted) ~right:(A.right twisted)
    ~unit:(K.natural_component eta) ~counit:(K.natural_component eps) in
  List.iter (fun b -> List.iter (fun a ->
    let inputs = all_maps b a in
    List.iter (fun adj -> roundtrips adj b a inputs inputs)
      [twisted;converted;A.dual twisted |> A.dual]) objects) objects;
  let arrows = List.concat_map (fun b -> List.concat_map (all_maps b) objects) objects in
  let left = A.left twisted in
  List.iter (fun h ->
    ignore (get (K.check_naturality eta h)); ignore (get (K.check_naturality eps h));
    ignore (get (K.check_naturality (K.dual_natural eta) h));
    check "derived left preserves identity" (F.equal_morphism
      (get (left.K.f_amap (F.identity (F.domain h)))) (F.identity (get (left.K.f_omap (F.domain h)))));
    List.iter (fun g -> if F.equal_carrier (F.codomain h) (F.domain g) then
      check "derived left preserves composition" (F.equal_morphism
        (get (left.K.f_amap (get (F.compose g h))))
        (get (F.compose (get (left.K.f_amap g)) (get (left.K.f_amap h)))))) arrows) arrows;
  let bad_unit = A.of_universal ~right:(K.id_functor F.cat) (fun b ->
    Ok {A.free_object=b;unit_arrow=F.identity F.empty;factor=(fun _ h -> Ok h)}) in
  reject "unit endpoints" noncomp (A.universal bad_unit base);
  let bad_factor = A.of_universal ~right:(K.id_functor F.cat) (fun b ->
    Ok {A.free_object=b;unit_arrow=F.identity b;factor=(fun _ _ -> Ok (swap b))}) in
  reject "factor triangle" noncommuting (A.transpose bad_factor base base (F.identity base));
  let bad_counit = A.of_unit_counit ~left:(K.id_functor F.cat) ~right:(K.id_functor F.cat)
    ~unit:(fun b -> Ok (F.identity b)) ~counit:(fun _ -> Ok (F.identity F.empty)) in
  reject "counit endpoints" noncomp (A.transpose bad_counit base base (F.identity base));
  reject "transpose input endpoints" noncomp (A.transpose twisted F.empty base (F.identity base));
  reject "untranspose input endpoints" noncomp (A.untranspose twisted F.empty base (F.identity base));
  let bad = {eta with K.n_component=(fun _ -> Ok (F.identity F.empty))} in
  reject "natural component endpoints" noncomp (K.natural_component bad base);
  let unnatural = {K.n_source=K.id_functor F.cat;n_target=K.id_functor F.cat;
    n_component=(fun b -> Ok (swap b))} in
  let point = ints [1] in
  let injection = get (F.morphism point (fun x -> x) base) in
  reject "general naturality is observable, not presumed proved" noncommuting
    (K.check_naturality unnatural injection);
  let failure = C.Outside_domain "universal supplier" in
  let failed = A.of_universal ~right:(K.id_functor F.cat) (fun _ -> Error failure) in
  reject "choice error unchanged" ((==) failure) ((A.left failed).K.f_omap base);
  reject "factor error unchanged" ((==) failure)
    (A.transpose (A.of_universal ~right:(K.id_functor F.cat) (fun b ->
      Ok {A.free_object=b;unit_arrow=F.identity b;factor=(fun _ _ -> Error failure)})) base base (F.identity base));
  let sampled = ref false in
  let failed_natural = {eta with K.n_source={eta.K.n_source with K.f_omap=(fun _ -> Error failure)};
    n_component=(fun _ -> sampled:=true; Ok (F.identity base))} in
  reject "natural object error unchanged" ((==) failure) (K.natural_component failed_natural base);
  check "natural failure short circuits component" (not !sampled);
  let exception Probe of int ref in
  let sentinel = ref 42 in
  let throwing = A.of_universal ~right:(K.id_functor F.cat) (fun _ -> raise (Probe sentinel)) in
  let threw = try ignore (A.transpose throwing base base (F.identity base)); false with Probe p -> p==sentinel in
  check "universal exception unchanged" threw;
  let initial = E.initial_adjunction F.cat U.initial in
  roundtrips initial () base [()] (all_maps F.empty base);
  let composite = A.compose twisted twisted in
  List.iter (fun b -> List.iter (fun a ->
    roundtrips composite b a (all_maps b a) (all_maps b a)) objects) objects;
  let alpha = {K.n_source=A.left twisted;n_target=A.left converted;
    n_component=(fun b -> Ok (F.identity b))} in
  let beta = A.mate_left twisted converted alpha in
  List.iter (fun b -> ignore (get (A.check_conjugate twisted converted alpha beta b))) objects;
  let recovered = A.mate_right twisted converted beta in
  List.iter (fun b ->
    let x = get (K.natural_component recovered b) in
    check "mate round trip" (F.equal_morphism x (F.identity b))) objects

(* The two finite chains have exact values n and k/2; no floating-point real
   category or unbounded machine-integer arithmetic is claimed. *)
module Grid = struct
  let ints = [-2;-1;0;1;2]
  let points = [-4;-3;-2;-1;0;1;2;3;4]
  let arrow values s t =
    if List.mem s values && List.mem t values && s<=t then Ok (s,t)
    else Error (C.Outside_domain "finite ordered chain")
  let category values =
    {C.source=fst;target=snd;ident=(fun x -> x,x);equal_obj=Int.equal;
     equal_arr=(fun a b -> a=b);comp=(fun ((m,t),(s,n)) ->
       if m=n then arrow values s t else Error (C.Non_composable "ordered chain"))}
  let ic = category ints and rc = category points
  let functor_ dom cod values map =
    {K.f_dom=dom;f_cod=cod;
     f_omap=(fun x -> if List.mem x values then Ok (map x) else Error (C.Outside_domain "grid object"));
     f_amap=(fun (s,t) -> let open C in let* _ = arrow values s t in Ok (map s,map t))}
  let inclusion = functor_ ic rc ints (fun n -> 2*n)
  let floor k = if k mod 2 < 0 then k/2-1 else k/2
  let ceil k = if k mod 2 > 0 then k/2+1 else k/2
  let ceiling = A.of_unit_counit ~left:(functor_ rc ic points ceil) ~right:inclusion
    ~unit:(fun k -> arrow points k (2*ceil k)) ~counit:(fun n -> arrow ints n n)
  let flooring = A.of_unit_counit ~left:inclusion ~right:(functor_ rc ic points floor)
    ~unit:(fun n -> arrow ints n n) ~counit:(fun k -> arrow points (2*floor k) k)
  let hom values s t = match arrow values s t with Ok h -> [h] | Error _ -> []
  let arrows values = List.concat_map (fun s -> List.concat_map (hom values s) values) values
end
let test_orders () =
  List.iter (fun k -> List.iter (fun n ->
    roundtrips Grid.ceiling k n (Grid.hom Grid.points k (2*n))
      (Grid.hom Grid.ints (Grid.ceil k) n);
    roundtrips Grid.flooring n k (Grid.hom Grid.ints n (Grid.floor k))
      (Grid.hom Grid.points (2*n) k)) Grid.ints) Grid.points;
  List.iter (fun h -> ignore (get (K.check_naturality (A.unit Grid.ceiling) h));
    ignore (get (K.check_naturality (A.counit Grid.flooring) h))) (Grid.arrows Grid.points);
  List.iter (fun h -> ignore (get (K.check_naturality (A.unit Grid.flooring) h));
    ignore (get (K.check_naturality (A.counit Grid.ceiling) h))) (Grid.arrows Grid.ints);
  check "negative odd floor/ceiling" (Grid.floor (-3)=(-2) && Grid.ceil (-3)=(-1));
  reject "grid out-of-range object" outside ((A.left Grid.ceiling).K.f_omap 5)

let test_comma_free () =
  let forward = Q.adjunction_forward twisted and backward = Q.adjunction_backward twisted in
  let rebuilt = Q.adjunction_of_isomorphism ~left:(A.left twisted) ~right:(A.right twisted)
    ~forward ~backward in
  List.iter (fun b -> List.iter (fun a ->
    List.iter (fun h ->
      let o = get (Q.object_ (A.left twisted) (K.id_functor F.cat) b h a) in
      let image = get (forward.K.f_omap o) in
      check "comma projections unchanged" (F.equal_carrier (Q.left_object image) b && F.equal_carrier (Q.right_object image) a);
      let back = get (backward.K.f_omap image) in
      check "comma object inverse" (forward.K.f_dom.C.equal_obj back o);
      let identity = forward.K.f_dom.C.ident o in
      check "comma arrow inverse" (forward.K.f_dom.C.equal_arr
        (get (backward.K.f_amap (get (forward.K.f_amap identity)))) identity)) (all_maps b a);
    roundtrips rebuilt b a (all_maps b a) (all_maps b a)) objects) objects;
  let f = A.left twisted in
  let os = List.concat_map (fun b -> List.concat_map (fun a ->
    List.map (fun h -> get (Q.object_ f (K.id_functor F.cat) b h a)) (all_maps b a)) objects) objects in
  List.iter (fun s -> List.iter (fun t ->
    List.iter (fun l -> List.iter (fun r ->
      match Q.arrow f (K.id_functor F.cat) s (l,r) t with
      | Error _ -> ()
      | Ok h ->
        let image = get (forward.K.f_amap h) in
        check "comma morphism projections unchanged" (F.equal_morphism (Q.left_arrow image) l &&
          F.equal_morphism (Q.right_arrow image) r);
        check "comma nonidentity morphism inverse" (forward.K.f_dom.C.equal_arr
          (get (backward.K.f_amap image)) h))
      (all_maps (Q.right_object s) (Q.right_object t)))
      (all_maps (Q.left_object s) (Q.left_object t))) os) os;
  let wrong_forward = {forward with K.f_omap=(fun _ ->
    Q.object_ (K.id_functor F.cat) (A.right twisted) F.empty (F.identity F.empty) F.empty)} in
  let bad = Q.adjunction_of_isomorphism ~left:(A.left twisted) ~right:(A.right twisted)
    ~forward:wrong_forward ~backward in
  reject "comma isomorphism projection violation" (function C.Different_base _ -> true | _ -> false)
    (K.natural_component (A.unit bad) base);
  let shape = get (D.graph ~nodes:["x"] ~edges:[]) in
  let b = ints [1;2] and a = ints [1] in
  let db = get (D.diagram F.cat shape ~objects:["x",b] ~arrows:[]) in
  let da = get (D.diagram F.cat shape ~objects:["x",a] ~arrows:[]) in
  let base = get (D.diagram_arrow db da ~components:["x",get (F.morphism b (fun _ -> v 1) a)]) in
  let free = L.Free.fixed_colimit F.cat shape U.colimit in
  let adj = L.Free.adjunction free in
  let other = get (D.cocone da a ~sides:["x",F.identity a]) in
  let u = get (A.transpose adj db other base) in
  check "free-to-adjunction transpose" ((A.right adj).K.f_cod.C.equal_arr
    (get (A.untranspose adj db other u)) base);
  ignore (get (A.check_triangles adj db other));
  let cofree = L.Cofree.fixed_limit F.cat shape U.limit in
  let adj = L.Cofree.adjunction cofree in
  let other = get (D.cone db b ~sides:["x",F.identity b]) in
  let u = get (A.untranspose adj other da base) in
  check "cofree-to-adjunction transpose" ((A.left adj).K.f_cod.C.equal_arr
    (get (A.transpose adj other da u)) base);
  ignore (get (A.check_triangles adj other da))

let graph ns es = get (G.graph ~nodes:(ints ns)
  ~edges:(List.map (fun (e,s,t) -> v e,v s,v t) es))
let graph_maps s t =
  List.concat_map (fun nodes -> List.filter_map (fun edges ->
    match G.graph_morphism s ~nodes ~edges t with Ok h -> Some h | Error _ -> None)
    (all_maps (G.edges s) (G.edges t))) (all_maps (G.nodes s) (G.nodes t))
let test_components () =
  let graphs = [graph [] [];graph [1;2] [];graph [1;2] [3,1,2];
    graph [1;2] [3,2,1;4,1,1];graph [1;2;3] [4,1,2;5,2,1]] in
  let adj = G.components_adjunction in
  List.iter (fun g -> List.iter (fun s ->
    let cg = get ((A.left adj).K.f_omap g) and ds = get (G.loop_graph_functor.K.f_omap s) in
    roundtrips adj g s (graph_maps g ds) (all_maps cg s);
    check "loop graph has one edge per vertex" (F.equal_carrier (G.edges ds) s)) objects) graphs;
  let g = List.nth graphs 4 in
  let q = get (A.universal adj g) in
  let labels = G.node_map q.A.unit_arrow in
  check "component semipath quotient" (F.equal (get (F.eval labels (v 1))) (get (F.eval labels (v 2))) &&
    not (F.equal (get (F.eval labels (v 1))) (get (F.eval labels (v 3)))));
  List.iter (fun g -> List.iter (fun h -> List.iter (fun f ->
    ignore (get (K.check_naturality (A.unit adj) f));
    List.iter (fun k -> List.iter (fun j ->
      check "component functor composition" (F.equal_morphism
        (get ((A.left adj).K.f_amap (get (C.compose G.category j f))))
        (get (F.compose (get ((A.left adj).K.f_amap j)) (get ((A.left adj).K.f_amap f))))))
      (graph_maps h k)) graphs) (graph_maps g h)) graphs) (List.filter (fun g -> F.cardinality (G.nodes g)<=2) graphs)

let slice_object anchor carrier link =
  get (Q.object_ (K.id_functor F.cat) (K.constant E.one F.cat anchor) carrier link ())
let slice_maps anchor s t =
  List.filter_map (fun h -> match Q.arrow (K.id_functor F.cat) (K.constant E.one F.cat anchor)
    s (h,()) t with Ok h -> Some h | Error _ -> None) (all_maps (Q.left_object s) (Q.left_object t))
let test_slices () =
  let a = ints [1;2] and b = ints [1] in
  let h = get (F.morphism a (fun _ -> v 1) b) in
  let adj = E.slice_postcompose U.complete_finset h in
  let sources = List.concat_map (fun c -> List.map (slice_object a c) (all_maps c a)) objects in
  let targets = List.concat_map (fun c -> List.map (slice_object b c) (all_maps c b)) objects in
  List.iter (fun s -> List.iter (fun t ->
    let sigma = get ((A.left adj).K.f_omap s) and pullback = get ((A.right adj).K.f_omap t) in
    roundtrips adj s t (slice_maps a s pullback) (slice_maps b sigma t)) targets) sources;
  let t = slice_object b b (F.identity b) in
  let pulled = get ((A.right adj).K.f_omap t) in
  check "pullback fibers duplicate along noninjective h" (F.cardinality (Q.left_object pulled)=2);
  let carrier = E.slice_carrier F.cat U.product a in
  List.iter (fun s -> List.iter (fun t ->
    let right = get ((A.right carrier).K.f_omap t) in
    roundtrips carrier s t (slice_maps a s right) (all_maps (Q.left_object s) t)) objects) sources;
  List.iter (fun s -> List.iter (fun t -> List.iter (fun h ->
    ignore (get (K.check_naturality (A.unit adj) h));
    ignore (get (K.check_naturality (A.unit carrier) h))) (slice_maps a s t)) sources) sources

let unique_cocone cat hom colimit candidate =
  let source = colimit.L.colim_cocone in
  let actual = get (colimit.L.colim_univ candidate) |> D.cocone_apex_arrow in
  let candidates = List.filter (fun h -> List.for_all (fun n ->
    cat.C.equal_arr (get (C.compose cat h (get (D.cocone_side source n))))
      (get (D.cocone_side candidate n))) (D.diagram_nodes (D.cocone_base source)))
    (hom (D.cocone_apex source) (D.cocone_apex candidate)) in
  incr unique_count;
  check "preserved colimit unique mediator" (List.length candidates=1 && cat.C.equal_arr (List.hd candidates) actual)
let test_preservation () =
  let shape = get (D.graph ~nodes:["x";"y"] ~edges:[]) in
  let d = get (D.diagram F.cat shape ~objects:["x",ints [1];"y",ints [2]] ~arrows:[]) in
  let c = get (U.colimit d) in
  let preserved = get ((P.adjoint_cocontinuous twisted).P.cc_map c) in
  let mapped = D.cocone_base preserved.L.colim_cocone in
  List.iter (fun apex -> List.iter (fun f -> List.iter (fun g ->
    let candidate = get (D.cocone mapped apex ~sides:["x",f;"y",g]) in
    unique_cocone F.cat all_maps preserved candidate)
    (all_maps (get (D.node_object mapped "y")) apex))
    (all_maps (get (D.node_object mapped "x")) apex)) objects;
  let limit = get (U.limit d) in
  let continuous = get ((P.adjoint_continuous twisted).P.ct_map limit) in
  let source = continuous.L.lim_cone in
  let candidate = get (D.cone (D.cone_base source) base ~sides:
    ["x",get (F.morphism base (fun _ -> v 1) (ints [1]));"y",get (F.morphism base (fun _ -> v 2) (ints [2]))]) in
  let actual = get (continuous.L.lim_univ candidate) |> D.cone_apex_arrow in
  let possible = List.filter (fun h -> List.for_all (fun n -> F.equal_morphism
    (get (F.compose (get (D.cone_side source n)) h)) (get (D.cone_side candidate n))) ["x";"y"])
    (all_maps base (D.cone_apex source)) in
  incr unique_count;
  check "dual preserved limit unique" (List.length possible=1 && F.equal_morphism (List.hd possible) actual);
  let failure = C.Outside_domain "preservation supplier" in
  let broken = {c with L.colim_univ=(fun _ -> Error failure)} in
  let p = get ((P.adjoint_cocontinuous twisted).P.cc_map broken) in
  reject "preserved mediator supplier failure unchanged" ((==) failure)
    (p.L.colim_univ p.L.colim_cocone);
  let wrong = get (D.cocone (get (D.diagram F.cat (get (D.graph ~nodes:[] ~edges:[]))
    ~objects:[] ~arrows:[])) base ~sides:[]) in
  reject "preservation different base" (function C.Different_base _ -> true | _ -> false)
    (preserved.L.colim_univ wrong);
  let shapes = [get (D.graph ~nodes:[] ~edges:[]);get (D.graph ~nodes:["x"] ~edges:[])] in
  List.iter (fun shape ->
    let gd = get (D.diagram G.category shape ~objects:(List.map (fun n -> n,graph [1;2] [3,1,2])
      (D.graph_nodes shape)) ~arrows:[]) in
    let gc = get (G.cocomplete.L.cc_colimit gd) in
    let pc = get ((P.adjoint_cocontinuous G.components_adjunction).P.cc_map gc) in
    let pd = D.cocone_base pc.L.colim_cocone in
    List.iter (fun apex ->
      let sides = List.map (fun n -> n,get (F.morphism_result (get (D.node_object pd n))
        (fun _ -> match F.carrier_to_list apex with x::_ -> Ok x | [] -> Error (C.Outside_codomain "empty")) apex))
        (D.graph_nodes shape) in
      let candidate = get (D.cocone pd apex ~sides) in unique_cocone F.cat all_maps pc candidate)
      [ints [1];base]) shapes

let () =
  List.iter (fun (name,test) -> test (); Printf.printf "PASS %s\n%!" name)
    ["general adjunction capabilities",test_core;"exact ordered adjunctions",test_orders;
     "comma equivalence and fixed-shape adjunctions",test_comma_free;
     "graph component adjunction",test_components;"slice adjunctions",test_slices;
     "preservation by adjoints",test_preservation];
  Printf.printf "Adjunction coverage: %d hom round trips, %d exhaustive selected mediators.\n%!"
    !roundtrip_count !unique_count
