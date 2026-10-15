open Computational_category
open Category_test_support.Checks
open Category_test_support.Finite_set_fixture
module F = I
module C = Foundations.Category
module K = Foundations.Functor
module A = Constructions.Algebras
module J = Universal.Adjunction
module L = Universal.Limits
module D = Universal.Diagrams
module P = Universal.Preservation
module G = Instances.Finite_graphs.Make(F)
let unique_count = ref 0
let law_count = ref 0
let limited = function C.Iteration_limit _ -> true | _ -> false
let noncomp = function C.Non_composable _ -> true | _ -> false
let noncomm = function C.Non_commuting _ -> true | _ -> false
let constant obj = K.constant F.cat F.cat obj
let zero = constant F.empty
let pointed = constant (ints [9])
let hom f s t = List.filter_map (fun h -> match A.algebra_morphism f s h t with
  | Ok h -> Some h | Error _ -> None) (all_maps (A.carrier s) (A.carrier t))
let unique f choice target seed =
  let u = get (choice.J.factor target seed) in
  check "free generator triangle" (F.equal_morphism
    (get (F.compose (A.underlying u) choice.J.unit_arrow)) seed);
  let candidates = List.filter (fun h -> F.equal_morphism
    (get (F.compose (A.underlying h) choice.J.unit_arrow)) seed) (hom f choice.J.free_object target) in
  incr unique_count;
  check "free factor independently unique" (List.length candidates=1 &&
    (A.category f).C.equal_arr (List.hd candidates) u)

let test_admission () =
  let f = K.id_functor F.cat in
  let swap = get (F.morphism base (fun x -> if F.equal x (v 1) then v 2 else v 1) base) in
  let a = get (A.algebra f base (F.identity base)) and b = get (A.algebra f base swap) in
  let singleton = ints [1] in
  let identity_alg = get (A.algebra f singleton (F.identity singleton)) in
  check "Id algebra extra operation cannot be silently forgotten" (hom f identity_alg b=[]);
  reject "wrong structure" noncomp (A.algebra f base (F.identity F.empty));
  reject "wrong hom endpoints" noncomp (A.algebra_morphism f a (F.identity F.empty) a);
  reject "noncommuting hom" noncomm (A.algebra_morphism f a (F.identity base) b);
  let cat = A.category f in
  let all = List.concat_map (fun o -> List.map (fun h -> get (A.algebra f o h)) (all_maps o o)) objects in
  List.iter (fun a -> List.iter (fun b -> List.iter (fun h ->
    check "algebra identity" (cat.C.equal_arr (get (C.compose cat (cat.C.ident b) h)) h);
    List.iter (fun c -> List.iter (fun k -> List.iter (fun d -> List.iter (fun j ->
      incr law_count;
      check "algebra associativity" (cat.C.equal_arr
        (get (C.compose cat j (get (C.compose cat k h))))
        (get (C.compose cat (get (C.compose cat j k)) h)))) (hom f c d)) all) (hom f b c)) all)
    (hom f a b)) all) all;
  let failure = C.Outside_domain "algebra object supplier" in
  let bad = {f with K.f_omap=(fun _ -> Error failure)} in
  reject "algebra supplier error unchanged" ((==) failure) (A.algebra bad base (F.identity base));
  let exception Probe of int ref in let token=ref 9 in
  let throwing = {f with K.f_amap=(fun _ -> raise (Probe token))} in
  check "algebra callback exception unchanged"
    (try ignore (A.algebra_morphism throwing a (F.identity base) a);false with Probe p -> p==token)

let test_limits () =
  (* The constant two-element functor does not preserve binary products. *)
  let f = constant base in
  let a = get (A.algebra f base (F.identity base)) in
  let swap = get (F.morphism base (fun x -> if F.equal x (v 1) then v 2 else v 1) base) in
  let b = get (A.algebra f base swap) in
  let shape = get (D.graph ~nodes:["a";"b"] ~edges:[]) in
  let cat = A.category f in
  let diagram = get (D.diagram cat shape ~objects:["a",a;"b",b] ~arrows:[]) in
  let complete = A.complete f U.complete_finset in
  let result = get (complete.L.co_limit diagram) in
  let apex = D.cone_apex result.L.lim_cone in
  check "limit created without F preservation" (F.cardinality (A.carrier apex)=4);
  List.iter (fun obj -> List.iter (fun structure ->
    let target = get (A.algebra f obj structure) in
    List.iter (fun l -> List.iter (fun r ->
      let cone = get (D.cone diagram target ~sides:["a",l;"b",r]) in
      let actual = get (result.L.lim_univ cone) |> D.cone_apex_arrow in
      let candidates = List.filter (fun h -> List.for_all (fun n ->
        cat.C.equal_arr (get (C.compose cat (get (D.cone_side result.L.lim_cone n)) h))
          (get (D.cone_side cone n))) ["a";"b"]) (hom f target apex) in
      incr unique_count;
      check "algebra limit independently unique" (List.length candidates=1 && cat.C.equal_arr (List.hd candidates) actual))
      (hom f target b)) (hom f target a)) (all_maps base obj)) objects;
  let altered = get (D.diagram cat shape ~objects:["a",b;"b",a] ~arrows:[]) in
  let wrong = get (D.cone altered apex ~sides:["a",get (D.cone_side result.L.lim_cone "b");
    "b",get (D.cone_side result.L.lim_cone "a")]) in
  reject "algebra base cannot be erased by forgetful" (function C.Different_base _ -> true | _ -> false)
    (result.L.lim_univ wrong);
  let empty = get (D.diagram cat (get (D.graph ~nodes:[] ~edges:[])) ~objects:[] ~arrows:[]) in
  let terminal = get (complete.L.co_limit empty) in
  check "terminal algebra" (F.cardinality (A.carrier (D.cone_apex terminal.L.lim_cone))=1);
  let failure = C.Outside_domain "underlying limit supplier" in
  let broken = {U.complete_finset with L.co_limit=(fun _ -> Error failure)} in
  reject "limit supplier unchanged" ((==) failure) ((A.complete f broken).L.co_limit diagram)

let test_iterations () =
  let iso = U.isomorphisms and c = U.cocomplete_finset in
  let point = ints [1] in
  let injection = get (F.morphism point (fun x -> x) base) in
  let swap = get (F.morphism base (fun x -> if F.equal x (v 1) then v 2 else v 1) base) in
  let collapse = get (F.morphism base (fun _ -> v 1) base) in
  check "equal cardinalities are not an iso proof" (get (C.inverse iso collapse)=None);
  let lying = {iso with C.iso_inverse=(fun h -> Ok (Some (F.identity (F.domain h))))} in
  reject "false inverse checked" noncomm (C.inverse lying collapse);
  let chain i = Ok (if i=0 then injection else swap) in
  let fixed = get (L.Chain.terminating ~isomorphisms:iso ~bound:4 chain) in
  check "chain cutoff and apex" (fixed.L.Chain.cutoff=1 && F.equal_carrier fixed.L.Chain.apex base);
  check "tail inverse direction" (F.equal_morphism (get (fixed.L.Chain.leg 2)) swap);
  List.iter (fun u ->
    let candidate i = F.compose u (get (fixed.L.Chain.leg i)) in
    check "chain mediator" (F.equal_morphism (get (fixed.L.Chain.factor base candidate)) u)) (all_maps base base);
  reject "constant objects do not certify stabilization" limited
    (L.Chain.terminating ~isomorphisms:iso ~bound:3 (fun _ -> Ok collapse));
  let false_tail = get (L.Chain.terminating ~isomorphisms:iso ~bound:4
    (fun n -> Ok (if n<2 then swap else collapse))) in
  reject "false invertible-tail premise exposed on request" (function C.Outside_domain _ -> true | _ -> false)
    (false_tail.L.Chain.leg 3);
  reject "chain leg request bound" limited (fixed.L.Chain.leg 5);
  reject "negative bound" (function C.Outside_domain _ -> true | _ -> false)
    (L.Chain.terminating ~isomorphisms:iso ~bound:(-1) chain);
  let preserving = P.by_comparison zero c iso in
  let empty = get (D.diagram F.cat (get (D.graph ~nodes:[] ~edges:[])) ~objects:[] ~arrows:[]) in
  let initial_colimit = get (U.colimit empty) in
  reject "comparison refuses nonpreserved initial object" noncomm
    ((P.by_comparison pointed c iso).P.cc_map initial_colimit);
  let choices = [get (A.Free.coproduct ~cocomplete:c ~isomorphisms:iso ~preserving ~bound:2 base);
    get (A.Free.chain ~cocomplete:c ~isomorphisms:iso ~bound:3 zero base);
    get (A.Free.pushout ~cocomplete:c ~isomorphisms:iso ~bound:3 zero base)] in
  List.iter (fun q -> List.iter (fun obj ->
    let structure = get (F.morphism F.empty (fun x -> x) obj) in
    let target = get (A.algebra zero obj structure) in
    List.iter (unique zero q target) (all_maps base obj)) objects) choices;
  let choices = [get (A.Free.chain ~cocomplete:c ~isomorphisms:iso ~bound:3 pointed point);
    get (A.Free.pushout ~cocomplete:c ~isomorphisms:iso ~bound:3 pointed point)] in
  List.iter (fun q ->
    check "free pointed carrier" (F.cardinality (A.carrier q.J.free_object)=2);
    List.iter (fun structure ->
      let target = get (A.algebra pointed base structure) in
      List.iter (unique pointed q target) (all_maps point base)) (all_maps (ints [9]) base)) choices;
  let initial = get (A.Free.initial_chain ~cocomplete:c ~isomorphisms:iso ~bound:3 pointed) in
  check "initial pointed algebra" (F.cardinality (A.carrier initial.L.init_obj)=1);
  List.iter (fun structure -> let t=get (A.algebra pointed base structure) in
    let actual = get (initial.L.init_univ t) in
    let candidates=hom pointed initial.L.init_obj t in incr unique_count;
    check "initial algebra unique" (List.length candidates=1 && (A.category pointed).C.equal_arr (List.hd candidates) actual))
    (all_maps (ints [9]) base);
  let id=K.id_functor F.cat in
  List.iter (fun construct -> reject "nonterminating free algebra is not success" limited (construct id point))
    [A.Free.chain ~cocomplete:c ~isomorphisms:iso ~bound:3;
     A.Free.pushout ~cocomplete:c ~isomorphisms:iso ~bound:3];
  reject "coproduct exhaustion" limited
    (A.Free.coproduct ~cocomplete:c ~isomorphisms:iso ~bound:2
      ~preserving:(P.id_cocontinuous_functor F.cat) point);
  let failure = C.Outside_domain "iteration object supplier" in
  let broken = {zero with K.f_omap=(fun _ -> Error failure)} in
  reject "iteration supplier error unchanged" ((==) failure)
    (A.Free.chain ~cocomplete:c ~isomorphisms:iso ~bound:3 broken point);
  let exception Probe of int ref in let token=ref 11 in
  let throwing = {zero with K.f_omap=(fun _ -> raise (Probe token))} in
  check "iteration callback exception unchanged"
    (try ignore (A.Free.pushout ~cocomplete:c ~isomorphisms:iso ~bound:3 throwing point);false
     with Probe p -> p==token)

let graph ns es = get (G.graph ~nodes:(ints ns) ~edges:(List.map (fun (e,s,t) -> v e,v s,v t) es))
let rec word = function [] -> F.terminal | x::xs -> F.pair (v x) (word xs)
let rec decode value = match F.view value with
  | F.Terminal -> [] | F.Pair (e,rest) ->
    (match F.view e with F.Atom n -> n::decode rest | _ -> failwith "word edge")
  | _ -> failwith "word code"
let rec enumerate es current =
  List.concat_map (fun (e,s,t) -> if s=current then
    [e] :: List.map (fun rest -> e::rest) (enumerate es t) else []) es
let test_paths () =
  let cases = [[],[];[1;2],[];[1;2],[3,1,2;4,1,2];
    [1;2;3],[4,1,2;5,1,2;6,2,3]] in
  List.iter (fun (ns,es) ->
    let g=graph ns es in let q=get (G.Fixed.free_paths ~bound:4 g) in
    let result=A.carrier q.J.free_object in
    let expected=List.concat_map (enumerate es) ns |> List.sort compare in
    let f=G.Fixed.prepend g in
    let ends w =
      let first=List.hd w and last=List.hd (List.rev w) in
      let _,s,_=List.find (fun (e,_,_) -> e=first) es in
      let _,_,t=List.find (fun (e,_,_) -> e=last) es in s,t in
    let oracle=get (G.graph ~nodes:(G.nodes g) ~edges:(List.map (fun w ->
      let s,t=ends w in word w,v s,v t) expected)) in
    let gt=get (F.morphism_result (G.edges g) (fun e ->
      match F.view e with F.Atom id -> let _,_,t=List.find (fun (e,_,_) -> e=id) es in Ok (v t)
      | _ -> Error (C.Outside_domain "oracle edge")) (G.nodes g)) in
    let os=get (F.morphism_result (G.edges oracle) (fun e -> let s,_=ends (decode e) in Ok (v s)) (G.nodes g)) in
    let p,_=get (U.pullback (gt,os)) in
    let image=get (f.K.f_omap oracle) in
    let evaluation=get (F.morphism_result (G.edges image) (fun e ->
      let x=get (F.eval p.L.pullback_proj1 e) and tail=get (F.eval p.L.pullback_proj2 e) in
      match F.view x with F.Atom id -> Ok (word (id::decode tail))
      | _ -> Error (C.Outside_domain "oracle prefix")) (G.edges oracle)) in
    let oracle_alg=get (A.algebra f oracle (get (G.Fixed.fixed_morphism (G.nodes g) image evaluation oracle))) in
    let seed=get (F.morphism (G.edges g) (fun e -> match F.view e with
      F.Atom id -> word [id] | _ -> failwith "oracle seed") (G.edges oracle)) in
    let seed=get (G.Fixed.fixed_morphism (G.nodes g) g seed oracle) in
    let fold=get (q.J.factor oracle_alg seed) |> A.underlying in
    check "independent word oracle bijection" (F.cardinality (G.edges result)=List.length expected &&
      Option.is_some (get (C.inverse (G.Fixed.isomorphisms (G.nodes g)) fold)));
    let target=q.J.free_object in
    let actual=get (q.J.factor target q.J.unit_arrow) in
    let possible=List.filter_map (fun h ->
      match G.Fixed.fixed_morphism (G.nodes g) result h result with Error _ -> None | Ok h ->
      match A.algebra_morphism f target h target with Error _ -> None | Ok h ->
      if (G.Fixed.category (G.nodes g)).C.equal_arr
        (get (C.compose (G.Fixed.category (G.nodes g)) (A.underlying h) q.J.unit_arrow)) q.J.unit_arrow
      then Some h else None) (all_maps (G.edges result) (G.edges result)) in
    incr unique_count;
    check "path algebra unique self fold" (List.length possible=1 &&
      (A.category f).C.equal_arr (List.hd possible) actual)) cases;
  reject "cycle retains infinite witness obligation" limited
    (G.Fixed.free_paths ~bound:3 (graph [1] [2,1,1]));
  reject "acyclic insufficient bound still incomplete" limited
    (G.Fixed.free_paths ~bound:0 (graph [1;2] [3,1,2]));
  let g=graph [1;2] [3,1,2] and wrong=graph [1] [] in
  reject "fixed graph node admission" (function C.Different_base _ -> true | _ -> false)
    ((G.Fixed.prepend g).K.f_omap wrong);
  let isolated=graph [1;2] [] in
  let swap=get (F.morphism base (fun x -> if F.equal x (v 1) then v 2 else v 1) base) in
  let moving=get (G.graph_morphism isolated ~edges:(F.identity F.empty) ~nodes:swap isolated) in
  reject "fixed graph excludes moving nodes" noncomm
    (C.compose (G.Fixed.category base) moving moving)

let () =
  List.iter (fun (name,test) -> test ();Printf.printf "PASS %s\n%!" name)
    ["algebra admission and laws",test_admission;"created algebra limits",test_limits;
     "terminating free algebra constructions",test_iterations;"witness-bearing path algebras",test_paths];
  Printf.printf "Algebra coverage: %d law triples, %d selected exhaustive unique factors.\n%!" !law_count !unique_count
