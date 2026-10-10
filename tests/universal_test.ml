(* Primitive universals and diagram admission share the bounded FinSet fixtures. *)
module Primitives = struct
  open Computational_category
  open Category_test_support.Checks
  open Category_test_support.Finite_set_fixture
  module S = Instances.Finite_sets.Make (struct type t = string let equal = String.equal end)
  module SU = Instances.Finite_set_universals.Make (S)
  module Ch = Instances.Finite_sets.Make (struct type t = char let equal (a : char) b = a = b end)
  module ChU = Instances.Finite_set_universals.Make (Ch)
  let universal_count = ref 0
  let unique label candidates expected predicate =
    incr universal_count;
    match List.filter predicate candidates with
    | [a] -> check label (arrow_eq a expected)
    | _ -> failwith (label ^ ": mediator is not unique")

  let test_universals () =
    List.iter (fun x ->
      let i = get (U.set_initial.Universal.Limits.init_univ x) in
      endpoints "initial endpoints" i I.emptyset x;
      unique "initial" (all_maps I.emptyset x) i (fun _ -> true);
      let t = get (U.set_terminal.Universal.Limits.term_univ x) in
      endpoints "terminal endpoints" t x U.set_terminal.Universal.Limits.term_obj;
      unique "terminal" (all_maps x U.set_terminal.Universal.Limits.term_obj) t (fun _ -> true)
    ) objects;
    List.iter (fun a -> List.iter (fun b ->
      let cp, fold = get (U.set_coproduct (a,b)) in
      let pr, pair = get (U.set_product (a,b)) in
      endpoints "coproduct leg 1" cp.Universal.Limits.coprod_inj1 a cp.Universal.Limits.coprod_obj;
      endpoints "coproduct leg 2" cp.Universal.Limits.coprod_inj2 b cp.Universal.Limits.coprod_obj;
      endpoints "product leg 1" pr.Universal.Limits.prod_proj1 pr.Universal.Limits.prod_obj a;
      endpoints "product leg 2" pr.Universal.Limits.prod_proj2 pr.Universal.Limits.prod_obj b;
      List.iter (fun x ->
        List.iter (fun f -> List.iter (fun g ->
          let h = get (fold x f g) in
          endpoints "coproduct mediator" h cp.Universal.Limits.coprod_obj x;
          unique "coproduct" (all_maps cp.Universal.Limits.coprod_obj x) h (fun k ->
            arrow_eq (composite k cp.Universal.Limits.coprod_inj1) f &&
            arrow_eq (composite k cp.Universal.Limits.coprod_inj2) g)
        ) (all_maps b x)) (all_maps a x);
        List.iter (fun f -> List.iter (fun g ->
          let h = get (pair x f g) in
          endpoints "product mediator" h x pr.Universal.Limits.prod_obj;
          unique "product" (all_maps x pr.Universal.Limits.prod_obj) h (fun k ->
            arrow_eq (composite pr.Universal.Limits.prod_proj1 k) f &&
            arrow_eq (composite pr.Universal.Limits.prod_proj2 k) g)
        ) (all_maps x b)) (all_maps x a)
      ) objects;
      let arrows = all_maps a b in
      List.iter (fun f -> List.iter (fun g ->
        let ce, factor = get (U.set_coequalizer (f,g)) in
        let eq, lift = get (U.set_equalizer (f,g)) in
        let q = ce.Universal.Limits.coeq_arrow and e = eq.Universal.Limits.eq_arrow in
        endpoints "quotient endpoints" q b ce.Universal.Limits.coeq_obj;
        endpoints "equalizer endpoints" e eq.Universal.Limits.eq_obj a;
        check "quotient equation" (arrow_eq (composite q f) (composite q g));
        check "equalizer equation" (arrow_eq (composite f e) (composite g e));
        let classes = get (U.set_coequalizer_classes (f,g)) in
        check "classes cover target" (I.seteq (List.fold_left I.union I.emptyset classes) b);
        List.iter (fun cls ->
          check "nonempty class" (not (I.is_empty cls));
          List.iter (fun other -> if not (I.seteq cls other) then
            check "disjoint classes" (I.is_empty (I.inter cls other))) classes) classes;
        check "representatives stay in target" (I.is_empty (I.diff ce.Universal.Limits.coeq_obj b));
        check "quotient surjectivity" (I.seteq
          (I.mapset (fun x -> get (I.apply q x)) b) ce.Universal.Limits.coeq_obj);
        List.iter (fun x ->
          List.iter (fun h ->
            if arrow_eq (composite h f) (composite h g) then begin
              let u = get (factor x h) in
              endpoints "coequalizer mediator" u ce.Universal.Limits.coeq_obj x;
              unique "coequalizer" (all_maps ce.Universal.Limits.coeq_obj x) u
                (fun k -> arrow_eq (composite k q) h)
            end else reject "incompatible quotient factor" noncommuting (factor x h)
          ) (all_maps b x);
          List.iter (fun h ->
            if arrow_eq (composite f h) (composite g h) then begin
              let u = get (lift x h) in
              endpoints "equalizer mediator" u x eq.Universal.Limits.eq_obj;
              unique "equalizer" (all_maps x eq.Universal.Limits.eq_obj) u
                (fun k -> arrow_eq (composite e k) h)
            end else reject "incompatible equalizer factor" noncommuting (lift x h)
          ) (all_maps x a)
        ) objects
      ) arrows) arrows
    ) objects) objects;
    let singleton = ints [1] in
    let wrong = I.ident (ints [3]) in
    let cp,fold = get (U.set_coproduct (singleton,base)) in
    reject "coproduct mediator endpoints" noncomp (fold base wrong (I.ident base));
    reject "coproduct mediator target" noncomp
      (fold base (I.ident singleton) (I.ident base));
    let _,pair = get (U.set_product (singleton,base)) in
    reject "product mediator endpoints" noncomp (pair base wrong (I.ident base));
    reject "nonparallel coequalizer" nonparallel (U.set_coequalizer (wrong,I.ident base));
    reject "nonparallel equalizer" nonparallel (U.set_equalizer (wrong,I.ident base));
    let different_source = get (I.arrow singleton (fun _ -> v 1) base) in
    let different_target = get (I.arrow base (fun _ -> v 1) singleton) in
    List.iter (fun other ->
      reject "coequalizer parallel endpoint" nonparallel
        (U.set_coequalizer (I.ident base,other));
      reject "equalizer parallel endpoint" nonparallel
        (U.set_equalizer (I.ident base,other))) [different_source;different_target];
    let f = get (I.arrow (ints [1;2]) (fun x -> x) (ints [1;2;3;4])) in
    let g = get (I.arrow (ints [1;2]) (fun x ->
      match I.view x with I.Atom n -> v (n+1) | _ -> assert false) (ints [1;2;3;4])) in
    let ce,_ = get (U.set_coequalizer (f,g)) in
    check "transitive quotient closure" (I.cardinality ce.Universal.Limits.coeq_obj = 2 &&
      I.equal (get (I.apply ce.Universal.Limits.coeq_arrow (v 1))) (get (I.apply ce.Universal.Limits.coeq_arrow (v 3))) &&
      not (I.equal (get (I.apply ce.Universal.Limits.coeq_arrow (v 1))) (get (I.apply ce.Universal.Limits.coeq_arrow (v 4)))));
    let other_target = ints [4;3;2;1] in
    let f' = get (I.arrow_result (I.source f) (I.apply f) other_target) in
    let g' = get (I.arrow_result (I.source g) (I.apply g) other_target) in
    let ce',factor' = get (U.set_coequalizer (f',g')) in
    let _,factor = get (U.set_coequalizer (f,g)) in
    let forward = get (factor ce'.Universal.Limits.coeq_obj ce'.Universal.Limits.coeq_arrow) in
    let backward = get (factor' ce.Universal.Limits.coeq_obj ce.Universal.Limits.coeq_arrow) in
    check "representative presentations are isomorphic"
      (arrow_eq (composite backward forward) (I.ident ce.Universal.Limits.coeq_obj) &&
       arrow_eq (composite forward backward) (I.ident ce'.Universal.Limits.coeq_obj));
    let nested = I.cartesian_prod cp.Universal.Limits.coprod_obj base in
    let nested_product,nested_pair = get (U.set_product (cp.Universal.Limits.coprod_obj,base)) in
    let diagonal = get (nested_pair nested_product.Universal.Limits.prod_obj
      nested_product.Universal.Limits.prod_proj1 nested_product.Universal.Limits.prod_proj2) in
    check "nested product mediator" (arrow_eq diagonal (I.ident nested_product.Universal.Limits.prod_obj));
    let nested_sum,nested_fold = get (U.set_coproduct (cp.Universal.Limits.coprod_obj,base)) in
    let fold = get (nested_fold cp.Universal.Limits.coprod_obj (I.ident cp.Universal.Limits.coprod_obj)
      cp.Universal.Limits.coprod_inj2) in
    check "nested coproduct mediator" (arrow_eq
      (composite fold nested_sum.Universal.Limits.coprod_inj1) (I.ident cp.Universal.Limits.coprod_obj) &&
      arrow_eq (composite fold nested_sum.Universal.Limits.coprod_inj2) cp.Universal.Limits.coprod_inj2);
    let e = get (I.arrow I.emptyset (fun _ -> assert false) nested) in
    let ce,_ = get (U.set_coequalizer (e,e)) in
    check "nested representative closure" (I.seteq ce.Universal.Limits.coeq_obj nested);
    let _,factor = get (U.set_coequalizer (I.ident base,I.ident base)) in
    reject "quotient factor endpoints" noncomp (factor base wrong);
    let narrow_image = get (I.arrow base (fun _ -> v 1) singleton) in
    reject "quotient factor target" noncomp (factor base narrow_image);
    let _,lift = get (U.set_equalizer (I.ident base,I.ident base)) in
    reject "equalizer factor endpoints" noncomp (lift base wrong);
    let strings = S.of_list [S.atom "x";S.atom "y"] in
    let terminal = get (SU.set_terminal.Universal.Limits.term_univ strings) in
    check "non-unit terminal" (S.seteq (S.source terminal) strings);
    let dual = SU.io_cp_ce_dual_finset in
    let t = get (dual.Universal.Limits.iocc_initial.Universal.Limits.init_univ strings) in
    check "non-unit dual initial endpoints" (Foundations.Category.has_endpoints dual.Universal.Limits.iocc_cat t
      dual.Universal.Limits.iocc_initial.Universal.Limits.init_obj strings);
    let prod,_ = get (dual.Universal.Limits.iocc_coproduct (strings,strings)) in
    check "dual coproduct directions" (Foundations.Category.has_endpoints dual.Universal.Limits.iocc_cat
      prod.Universal.Limits.coprod_inj1 strings prod.Universal.Limits.coprod_obj);
    ignore (get (dual.Universal.Limits.iocc_coequalizer (S.ident strings,S.ident strings)));
    ignore (get (SU.set_coproduct (strings,strings)));
    let chars = Ch.of_list [Ch.atom 'a';Ch.atom 'b'] in
    let flip = get (Ch.arrow chars (fun x -> match Ch.view x with
      | Ch.Atom 'a' -> Ch.atom 'b' | _ -> Ch.atom 'a') chars) in
    let ce,_ = get (ChU.set_coequalizer (Ch.ident chars,flip)) in
    check "character quotient" (Ch.cardinality ce.Universal.Limits.coeq_obj = 1);
    let iso1,iso2 = get (Universal.Limits.iso_initial U.set_initial U.set_initial) in
    check "initial isomorphism" (arrow_eq (composite iso1 iso2) (I.ident I.emptyset))

  let test_pushouts () =
    List.iter (fun a -> List.iter (fun b -> List.iter (fun c ->
      List.iter (fun f -> List.iter (fun g ->
        let po,med = get (U.set_pushout (f,g)) in
        let p = po.Universal.Limits.pushout_leg1 and q = po.Universal.Limits.pushout_leg2 in
        endpoints "pushout left source" p b po.Universal.Limits.pushout_obj;
        endpoints "pushout right source" q c po.Universal.Limits.pushout_obj;
        check "pushout square" (arrow_eq (composite p f) (composite q g));
        List.iter (fun x ->
          List.iter (fun h -> List.iter (fun k ->
            if arrow_eq (composite h f) (composite k g) then begin
              let u = get (med x h k) in
              endpoints "pushout mediator" u po.Universal.Limits.pushout_obj x;
              unique "pushout" (all_maps po.Universal.Limits.pushout_obj x) u (fun r ->
                arrow_eq (composite r p) h && arrow_eq (composite r q) k)
            end else reject "incompatible pushout factor" noncommuting (med x h k)
          ) (all_maps c x)) (all_maps b x)
        ) objects
      ) (all_maps a c)) (all_maps a b)
    ) objects) objects) objects;
    let a = ints [1] in
    let f = I.ident a and g = get (I.arrow a (fun x -> x) base) in
    let po,_ = get (U.set_pushout (f,g)) in
    check "pushout regression cardinality" (I.cardinality po.Universal.Limits.pushout_obj = 2);
    reject "pushout common source" noncomp (U.set_pushout (I.ident base, f));
    let _,med = get (U.set_pushout (f,g)) in
    reject "pushout mediator endpoints" noncomp (med base (I.ident base) (I.ident base))

  let test_graphs () =
    let a = ints [1] in
    let f = get (I.arrow a (fun x -> x) base) in
    let shape = get (Universal.Diagrams.graph ~nodes:["a";"b"] ~edges:["e","a","b"]) in
    let d = get (Universal.Diagrams.diagram I.cat shape ~objects:["a",a;"b",base] ~arrows:["e",f]) in
    let reordered = get (Universal.Diagrams.graph ~nodes:["b";"a"] ~edges:["e","a","b"]) in
    let f' = get (I.arrow a (fun _ -> v 1) (ints [2;1])) in
    let d' = get (Universal.Diagrams.diagram I.cat reordered ~objects:["b",ints [2;1];"a",a] ~arrows:["e",f']) in
    check "extensional base equality" (Universal.Diagrams.same_base d d');
    let cc = get (Universal.Diagrams.cocone d base ~sides:["a",f;"b",I.ident base]) in
    let cc' = get (Universal.Diagrams.cocone d' base ~sides:["b",I.ident base;"a",f']) in
    let ca = get (Universal.Diagrams.cocone_arrow cc (I.ident base) cc') in
    check "cocone accessor has correct type" (arrow_eq (Universal.Diagrams.cocone_apex_arrow ca) (I.ident base));
    let cone = get (Universal.Diagrams.cone d a ~sides:["a",I.ident a;"b",f]) in
    let coar = get (Universal.Diagrams.cone_arrow cone (I.ident a) cone) in
    check "cone accessor" (arrow_eq (Universal.Diagrams.cone_apex_arrow coar) (I.ident a));
    reject "graph bad endpoint" (function Foundations.Category.Malformed_graph _ -> true | _ -> false)
      (Universal.Diagrams.graph ~nodes:["a"] ~edges:["e","a","missing"]);
    reject "graph error locates endpoint"
      (function Foundations.Category.Malformed_graph s -> String.contains s '?' | _ -> false)
      (Universal.Diagrams.graph ~nodes:["a"] ~edges:["edge","a","?"]);
    reject "graph duplicate edge" (function Foundations.Category.Malformed_graph _ -> true | _ -> false)
      (Universal.Diagrams.graph ~nodes:["a"] ~edges:["e","a","a";"e","a","a"]);
    reject "diagram missing" (function Foundations.Category.Malformed_diagram _ -> true | _ -> false)
      (Universal.Diagrams.diagram I.cat shape ~objects:["a",a] ~arrows:["e",f]);
    reject "diagram error locates binding"
      (function Foundations.Category.Malformed_diagram s -> String.contains s '?' | _ -> false)
      (Universal.Diagrams.diagram I.cat shape ~objects:["a",a;"b",base;"?",base] ~arrows:["e",f]);
    reject "diagram duplicate" (function Foundations.Category.Malformed_diagram _ -> true | _ -> false)
      (Universal.Diagrams.diagram I.cat shape ~objects:["a",a;"a",a;"b",base] ~arrows:["e",f]);
    reject "diagram extra" (function Foundations.Category.Malformed_diagram _ -> true | _ -> false)
      (Universal.Diagrams.diagram I.cat shape ~objects:["a",a;"b",base;"z",base] ~arrows:["e",f]);
    reject "diagram edge endpoints" (function Foundations.Category.Malformed_diagram _ -> true | _ -> false)
      (Universal.Diagrams.diagram I.cat shape ~objects:["a",a;"b",base] ~arrows:["e",I.ident base]);
    reject "node outside base" outside (Universal.Diagrams.node_object d "missing");
    reject "edge outside graph" outside (Universal.Diagrams.graph_source shape "missing");
    let bad = get (I.arrow a (fun _ -> v 2) base) in
    let changed = get (Universal.Diagrams.diagram I.cat shape ~objects:["a",a;"b",base] ~arrows:["e",bad]) in
    check "changed arrow changes base" (not (Universal.Diagrams.same_base d changed));
    let cc_bad = get (Universal.Diagrams.cocone changed base ~sides:["a",bad;"b",I.ident base]) in
    reject "different cocone base" (function Foundations.Category.Different_base _ -> true | _ -> false)
      (Universal.Diagrams.cocone_arrow cc (I.ident base) cc_bad);
    reject "noncommuting cocone" noncommuting
      (Universal.Diagrams.cocone d base ~sides:["a",bad;"b",I.ident base]);
    reject "noncommuting cone" noncommuting
      (Universal.Diagrams.cone d a ~sides:["a",I.ident a;"b",bad]);
    reject "side endpoints" (function Foundations.Category.Malformed_diagram _ -> true | _ -> false)
      (Universal.Diagrams.cocone d base ~sides:["a",I.ident base;"b",I.ident base]);
    reject "cocone arrow endpoints" noncomp (Universal.Diagrams.cocone_arrow cc (I.ident a) cc);
    let constant = get (I.arrow base (fun _ -> v 2) base) in
    reject "cocone arrow equation" noncommuting (Universal.Diagrams.cocone_arrow cc constant cc);
    let span = get (Constructions.Spans.span I.cat f f) in
    check "span plumbing endpoints" (I.seteq (Constructions.Spans.span_source span) a &&
      arrow_eq (Constructions.Spans.span_left span) f && arrow_eq (Constructions.Spans.span_right span) f);
    reject "span common source" (function Foundations.Category.Malformed_relation _ -> true | _ -> false)
      (Constructions.Spans.span I.cat f (I.ident base));
    let empty = get (Universal.Diagrams.graph ~nodes:[] ~edges:[]) in
    let d0 = get (Universal.Diagrams.diagram I.cat empty ~objects:[] ~arrows:[]) in
    ignore (get (Universal.Diagrams.cone d0 base ~sides:[]));
    ignore (get (Universal.Diagrams.cocone d0 base ~sides:[]))

  let run () =
    List.iter (fun (name,test) -> test (); Printf.printf "PASS %s\n%!" name)
      ["primitive universal laws",test_universals; "pushout laws",test_pushouts;
       "diagram admission and span plumbing",test_graphs];
    Printf.printf "Primitive coverage: %d map fixtures, %d unique-mediator cases.\n%!"
      !maps_count !universal_count
end

(* Bounded universality checks, independent of representative/tag enumeration. *)
open Computational_category
module F = Instances.Finite_sets.Make (struct type t = int let equal (x : int) y = x = y end)
module U = Instances.Finite_set_universals.Make (F)
open Category_test_support.Checks
let different = function Foundations.Category.Different_base _ -> true | _ -> false
let noncomp = function Foundations.Category.Non_composable _ -> true | _ -> false
let noncommuting = function Foundations.Category.Non_commuting _ -> true | _ -> false
let ints xs = F.of_list (List.map F.atom xs)
let objects = F.powerset (ints [1;2])
let compose g f = get (F.compose g f)
let eq = F.equal_arrow
let diagrams = ref 0
let factors = ref 0
let uniqueness = ref 0
let larger_equations = ref 0
let bool_diagrams = ref 0
let bool_factors = ref 0
let pullbacks = ref 0

let rec choices = function
  | [] -> [[]]
  | (label, xs) :: rest ->
    List.concat_map (fun x ->
      List.map (fun tail -> (label,x) :: tail) (choices rest)) xs
let all_maps source target =
  List.map (fun entries -> get (F.arrow_result source (fun x ->
    match List.find_opt (fun (y,_) -> F.equal x y) entries with
    | Some (_,v) -> Ok v | None -> Error (Foundations.Category.Outside_domain "test mapping")) target))
    (choices (List.map (fun x -> x,F.to_list target) (F.to_list source)))
let shapes = [
  [], [];
  ["a"], [];
  ["a";"b"], [];
  ["a";"b";"c"], [];
  ["a"], ["loop","a","a"];
  ["a";"b"], ["f","a","b"];
  ["a";"b"], ["f","a","b";"g","a","b"];
  ["a";"b"], ["f","a","b";"g","b","a"];
  ["a";"b";"c"], ["f","a","b";"g","b","c"];
  ["a";"b";"c"], ["f","a","b";"g","a","c"];
  ["a";"b";"c"], ["f","a","c";"g","b","c"] ]

let each_diagram cat objs maps visit =
  List.iter (fun (nodes,edges) ->
    let shape = get (Universal.Diagrams.graph ~nodes ~edges) in
    List.iter (fun bindings ->
      List.iter (fun arrows ->
        visit (get (Universal.Diagrams.diagram cat shape ~objects:bindings ~arrows)))
        (choices (List.map (fun (id,s,t) ->
          id,maps (List.assoc s bindings) (List.assoc t bindings)) edges)))
      (choices (List.map (fun n -> n,objs) nodes))) shapes

let compatible cat d outgoing sides =
  List.for_all (fun edge ->
    let shape = Universal.Diagrams.diagram_graph d in
    let s = get (Universal.Diagrams.graph_source shape edge) and t = get (Universal.Diagrams.graph_target shape edge) in
    let f = get (Universal.Diagrams.edge_arrow d edge) in
    let a = List.assoc s sides and b = List.assoc t sides in
    let composite,expected =
      if outgoing then get (Foundations.Category.compose cat b f),a
      else get (Foundations.Category.compose cat f a),b in
    cat.Foundations.Category.equal_arr composite expected) (Universal.Diagrams.diagram_edges d)

let same_cocone a b =
  Universal.Diagrams.same_base (Universal.Diagrams.cocone_base a) (Universal.Diagrams.cocone_base b) &&
  F.seteq (Universal.Diagrams.cocone_apex a) (Universal.Diagrams.cocone_apex b) &&
  List.for_all (fun n -> eq (get (Universal.Diagrams.cocone_side a n)) (get (Universal.Diagrams.cocone_side b n)))
    (Universal.Diagrams.diagram_nodes (Universal.Diagrams.cocone_base a))
let same_cone a b =
  Universal.Diagrams.same_base (Universal.Diagrams.cone_base a) (Universal.Diagrams.cone_base b) &&
  F.seteq (Universal.Diagrams.cone_apex a) (Universal.Diagrams.cone_apex b) &&
  List.for_all (fun n -> eq (get (Universal.Diagrams.cone_side a n)) (get (Universal.Diagrams.cone_side b n)))
    (Universal.Diagrams.diagram_nodes (Universal.Diagrams.cone_base a))

let check_colimit d result =
  let cc = result.Universal.Limits.colim_cocone in
  let apex = Universal.Diagrams.cocone_apex cc in
  check "colimit full original base" (Universal.Diagrams.same_base d (Universal.Diagrams.cocone_base cc));
  let sides = List.map (fun n -> n,get (Universal.Diagrams.cocone_side cc n)) (Universal.Diagrams.diagram_nodes d) in
  List.iter (fun (n,f) -> check "colimit side endpoints"
    (Foundations.Category.has_endpoints F.cat f (get (Universal.Diagrams.node_object d n)) apex)) sides;
  check "colimit edge equations" (compatible F.cat d true sides);
  check "colimit universal identity"
    (eq (Universal.Diagrams.cocone_apex_arrow (get (result.Universal.Limits.colim_univ cc))) (F.ident apex));
  List.iter (fun x ->
    List.iter (fun sides ->
      if compatible F.cat d true sides then begin
        let other = get (Universal.Diagrams.cocone d x ~sides) in
        let ar = get (result.Universal.Limits.colim_univ other) in
        let u = Universal.Diagrams.cocone_apex_arrow ar in
        incr factors;
        check "colimit arrow domain" (same_cocone (Universal.Diagrams.cocone_arrow_domain ar) cc);
        check "colimit arrow codomain" (same_cocone (Universal.Diagrams.cocone_arrow_codomain ar) other);
        check "colimit mediator direction" (Foundations.Category.has_endpoints F.cat u apex x);
        let triangles k = List.for_all (fun (n,h) ->
          eq (compose k (get (Universal.Diagrams.cocone_side cc n))) h) sides in
        check "colimit mediator triangles" (triangles u);
        if F.cardinality apex <= 4 then begin
          incr uniqueness;
          match List.filter triangles (all_maps apex x) with
          | [candidate] -> check "unique colimit mediator" (eq candidate u)
          | _ -> failwith "colimit uniqueness"
        end else incr larger_equations
      end)
      (choices (List.map (fun n -> n,all_maps (get (Universal.Diagrams.node_object d n)) x)
        (Universal.Diagrams.diagram_nodes d)))) objects

let check_limit d result =
  let co = result.Universal.Limits.lim_cone in
  let apex = Universal.Diagrams.cone_apex co in
  check "limit full original base" (Universal.Diagrams.same_base d (Universal.Diagrams.cone_base co));
  let sides = List.map (fun n -> n,get (Universal.Diagrams.cone_side co n)) (Universal.Diagrams.diagram_nodes d) in
  List.iter (fun (n,f) -> check "limit side endpoints"
    (Foundations.Category.has_endpoints F.cat f apex (get (Universal.Diagrams.node_object d n)))) sides;
  check "limit edge equations" (compatible F.cat d false sides);
  check "limit universal identity"
    (eq (Universal.Diagrams.cone_apex_arrow (get (result.Universal.Limits.lim_univ co))) (F.ident apex));
  List.iter (fun x ->
    List.iter (fun sides ->
      if compatible F.cat d false sides then begin
        let other = get (Universal.Diagrams.cone d x ~sides) in
        let ar = get (result.Universal.Limits.lim_univ other) in
        let u = Universal.Diagrams.cone_apex_arrow ar in
        incr factors;
        check "limit arrow domain" (same_cone (Universal.Diagrams.cone_arrow_domain ar) other);
        check "limit arrow codomain" (same_cone (Universal.Diagrams.cone_arrow_codomain ar) co);
        check "limit mediator direction" (Foundations.Category.has_endpoints F.cat u x apex);
        let triangles k = List.for_all (fun (n,h) ->
          eq (compose (get (Universal.Diagrams.cone_side co n)) k) h) sides in
        check "limit mediator triangles" (triangles u);
        if F.cardinality apex <= 4 then begin
          incr uniqueness;
          match List.filter triangles (all_maps x apex) with
          | [candidate] -> check "unique limit mediator" (eq candidate u)
          | _ -> failwith "limit uniqueness"
        end else incr larger_equations
      end)
      (choices (List.map (fun n -> n,all_maps x (get (Universal.Diagrams.node_object d n)))
        (Universal.Diagrams.diagram_nodes d)))) objects

let test_finite_diagrams () =
  each_diagram F.cat objects all_maps (fun d ->
    incr diagrams;
    let cc = get (U.set_colimit d) in
    check_colimit d cc;
    check_limit d (get (U.set_limit d));
    let round = get (Universal.Limits.dual_limit (Universal.Limits.dual_colimit U.set_colimit) d) in
    let u = Universal.Diagrams.cocone_apex_arrow (get (cc.Universal.Limits.colim_univ round.Universal.Limits.colim_cocone)) in
    let v = Universal.Diagrams.cocone_apex_arrow (get (round.Universal.Limits.colim_univ cc.Universal.Limits.colim_cocone)) in
    check "double dual universality isomorphism"
      (eq (compose v u) (F.ident (Universal.Diagrams.cocone_apex cc.Universal.Limits.colim_cocone)) &&
       eq (compose u v) (F.ident (Universal.Diagrams.cocone_apex round.Universal.Limits.colim_cocone)));
    check "diagram double dual" (Universal.Diagrams.same_base d (Universal.Diagrams.dual_diagram (Universal.Diagrams.dual_diagram d))))

(* The two-object poset false <= true: arrows are endpoint pairs, not FinSet
   maps. Joins/false and meets/true independently supply the primitive bundles. *)
module Bool_order = struct
  let valid (s,t) = not s || t
  let arrow s t =
    if valid (s,t) then Ok (s,t) else Error (Foundations.Category.Non_composable "boolean order")
  let cat = {
    Foundations.Category.source = fst; target = snd; ident = (fun x -> x,x);
    equal_obj = Bool.equal; equal_arr = (fun a b -> a = b);
    comp = (fun ((m,t),(s,n)) ->
      if Bool.equal m n && valid (s,n) && valid (m,t) then arrow s t
      else Error (Foundations.Category.Non_composable "boolean composition")) }
  let bundle category init join make =
    let initial = { Universal.Limits.init_obj = init; init_univ = (fun x -> Ok (make init x)) } in
    let coproduct (a,b) =
      let obj = join a b in
      let univ x f g =
        if Foundations.Category.has_endpoints category f a x && Foundations.Category.has_endpoints category g b x
        then Ok (make obj x) else Error (Foundations.Category.Non_composable "boolean coproduct") in
      Ok ({ Universal.Limits.coprod_obj = obj; coprod_inj1 = make a obj;
            coprod_inj2 = make b obj },univ) in
    let coequalizer (f,g) =
      if not (Foundations.Category.parallel category f g) then Error (Foundations.Category.Non_parallel "boolean coequalizer")
      else let obj = category.Foundations.Category.target f in
        let univ x h =
          if Foundations.Category.has_endpoints category h obj x then Ok h
          else Error (Foundations.Category.Non_composable "boolean coequalizer mediator") in
        Ok ({ Universal.Limits.coeq_obj = obj; coeq_arrow = category.Foundations.Category.ident obj },univ) in
    { Universal.Limits.iocc_cat = category; iocc_initial = initial;
      iocc_coproduct = coproduct; iocc_coequalizer = coequalizer }
  let caps = bundle cat false ( || ) (fun s t -> s,t)
  let dual_caps = bundle (Foundations.Category.dual_cat cat) true ( && ) (fun s t -> t,s)
  let colimit = Universal.Limits.finite_colimit caps
  let limit = Universal.Limits.dual_colimit (Universal.Limits.finite_colimit dual_caps)
end

let test_boolean_category () =
  let module B = Bool_order in
  let arrows = [false,false; false,true; true,true] in
  List.iter (fun f ->
    check "boolean category left identity"
      (get (Foundations.Category.compose B.cat (B.cat.Foundations.Category.ident (snd f)) f) = f);
    check "boolean category right identity"
      (get (Foundations.Category.compose B.cat f (B.cat.Foundations.Category.ident (fst f))) = f);
    List.iter (fun g ->
      if Bool.equal (snd f) (fst g) then begin
        let gf = get (Foundations.Category.compose B.cat g f) in
        check "boolean composition endpoints" (gf = (fst f,snd g));
        List.iter (fun h -> if Bool.equal (snd g) (fst h) then
          check "boolean category associativity"
            (get (Foundations.Category.compose B.cat h gf) = get (Foundations.Category.compose B.cat
              (get (Foundations.Category.compose B.cat h g)) f))) arrows
      end else reject "boolean noncomposable" noncomp (Foundations.Category.compose B.cat g f)
    ) arrows) arrows;
  let maps a b = if B.valid (a,b) then [a,b] else [] in
  each_diagram B.cat [false;true] maps (fun d ->
    incr bool_diagrams;
    let cc = get (B.colimit d) and co = get (B.limit d) in
    let join = List.exists (fun n -> get (Universal.Diagrams.node_object d n)) (Universal.Diagrams.diagram_nodes d) in
    let meet = List.for_all (fun n -> get (Universal.Diagrams.node_object d n)) (Universal.Diagrams.diagram_nodes d) in
    check "generic boolean colimit join" (Bool.equal join (Universal.Diagrams.cocone_apex cc.Universal.Limits.colim_cocone));
    check "generic boolean limit meet" (Bool.equal meet (Universal.Diagrams.cone_apex co.Universal.Limits.lim_cone));
    List.iter (fun x ->
      List.iter (fun sides ->
        if compatible B.cat d true sides then begin
          let other = get (Universal.Diagrams.cocone d x ~sides) in
          let u = Universal.Diagrams.cocone_apex_arrow (get (cc.Universal.Limits.colim_univ other)) in
          check "boolean colimit universal" (u = (join,x));
          check "boolean colimit unique" (maps join x = [u]);
          incr bool_factors
        end)
        (choices (List.map (fun n -> n,maps (get (Universal.Diagrams.node_object d n)) x) (Universal.Diagrams.diagram_nodes d)));
      List.iter (fun sides ->
        if compatible B.cat d false sides then begin
          let other = get (Universal.Diagrams.cone d x ~sides) in
          let u = Universal.Diagrams.cone_apex_arrow (get (co.Universal.Limits.lim_univ other)) in
          check "boolean limit universal" (u = (x,meet));
          check "boolean limit unique" (maps x meet = [u]);
          incr bool_factors
        end)
        (choices (List.map (fun n -> n,maps x (get (Universal.Diagrams.node_object d n))) (Universal.Diagrams.diagram_nodes d)))
    ) [false;true])

let test_pullbacks () =
  List.iter (fun a -> List.iter (fun b -> List.iter (fun c ->
    List.iter (fun f -> List.iter (fun g ->
      incr pullbacks;
      let pb,med = get (U.set_pullback (f,g)) in
      let p = pb.Universal.Limits.pullback_proj1 and q = pb.Universal.Limits.pullback_proj2 in
      check "pullback projection sources"
        (Foundations.Category.has_endpoints F.cat p pb.Universal.Limits.pullback_obj a &&
         Foundations.Category.has_endpoints F.cat q pb.Universal.Limits.pullback_obj b);
      check "pullback square" (eq (compose f p) (compose g q));
      List.iter (fun x ->
        List.iter (fun h -> List.iter (fun k ->
          if eq (compose f h) (compose g k) then begin
            let u = get (med x h k) in
            check "pullback mediator direction" (Foundations.Category.has_endpoints F.cat u x pb.Universal.Limits.pullback_obj);
            let triangles v = eq (compose p v) h && eq (compose q v) k in
            check "pullback mediator equations" (triangles u);
            incr uniqueness;
            match List.filter triangles (all_maps x pb.Universal.Limits.pullback_obj) with
            | [v] -> check "unique pullback mediator" (eq v u)
            | _ -> failwith "pullback uniqueness"
          end else reject "incompatible pullback" noncommuting (med x h k))
          (all_maps x b)) (all_maps x a)) objects
    ) (all_maps b c)) (all_maps a c)) objects) objects) objects;
  let s = ints [1] and b = ints [1;2] in
  let f = get (F.arrow b (fun _ -> F.atom 1) s) in
  reject "pullback common target" noncomp (U.set_pullback (F.ident b,f));
  let _,med = get (U.set_pullback (f,f)) in
  reject "pullback mediator endpoints" noncomp (med b (F.ident s) (F.ident b))

let test_transformations_and_failures () =
  let b = ints [1;2] and s = ints [1] in
  let identity = F.ident b in
  let shape = get (Universal.Diagrams.graph ~nodes:["a";"b"] ~edges:["f","a","b"]) in
  let d = get (Universal.Diagrams.diagram F.cat shape ~objects:["a",b;"b",b] ~arrows:["f",identity]) in
  let tail = Universal.Diagrams.discrete_tail d in
  check "discrete restriction preserves the remaining node"
    (Universal.Diagrams.diagram_nodes tail = ["b"] &&
     Universal.Diagrams.diagram_edges tail = [] &&
     F.seteq (get (Universal.Diagrams.node_object tail "b")) b);
  let discrete = Universal.Diagrams.without_first_edge d in
  check "edge restriction preserves all nodes"
    (Universal.Diagrams.diagram_nodes discrete = ["a";"b"] &&
     Universal.Diagrams.diagram_edges discrete = []);
  check "edgeless restriction is unchanged"
    (Universal.Diagrams.same_base discrete (Universal.Diagrams.without_first_edge discrete));
  let empty = get (Universal.Diagrams.diagram F.cat
    (get (Universal.Diagrams.graph ~nodes:[] ~edges:[])) ~objects:[] ~arrows:[]) in
  check "empty restriction is admitted"
    (Universal.Diagrams.same_base empty (Universal.Diagrams.discrete_tail empty));
  let armed = ref false in
  let guarded = { F.cat with Foundations.Category.source = (fun a ->
    if !armed then failwith "restriction rechecked a callback" else F.source a) } in
  let guarded_diagram = get (Universal.Diagrams.diagram guarded shape
    ~objects:["a",b;"b",b] ~arrows:["f",identity]) in
  armed := true;
  ignore (Universal.Diagrams.discrete_tail guarded_diagram);
  ignore (Universal.Diagrams.without_first_edge guarded_diagram);
  check "graph incidence enumeration is retained"
    (Universal.Diagrams.graph_bindings shape = ["f","a","b"]);
  let cc = get (U.set_colimit d) and co = get (U.set_limit d) in
  check "cocone side enumeration preserves its bindings"
    (List.map fst (Universal.Diagrams.cocone_sides cc.Universal.Limits.colim_cocone)
     = ["a";"b"]);
  let shape' = get (Universal.Diagrams.graph ~nodes:["b";"a"] ~edges:["f","a","b"]) in
  let reversed = ints [2;1] in
  let d' = get (Universal.Diagrams.diagram F.cat shape' ~objects:["b",reversed;"a",reversed]
    ~arrows:["f",F.ident reversed]) in
  let cc' = get (U.set_colimit d') and co' = get (U.set_limit d') in
  let u = Universal.Diagrams.cocone_apex_arrow (get (cc.Universal.Limits.colim_univ cc'.Universal.Limits.colim_cocone)) in
  let v = Universal.Diagrams.cocone_apex_arrow (get (cc'.Universal.Limits.colim_univ cc.Universal.Limits.colim_cocone)) in
  check "colimit presentation isomorphism"
    (eq (compose v u) (F.ident (Universal.Diagrams.cocone_apex cc.Universal.Limits.colim_cocone)) &&
     eq (compose u v) (F.ident (Universal.Diagrams.cocone_apex cc'.Universal.Limits.colim_cocone)));
  let u = Universal.Diagrams.cone_apex_arrow (get (co.Universal.Limits.lim_univ co'.Universal.Limits.lim_cone)) in
  let v = Universal.Diagrams.cone_apex_arrow (get (co'.Universal.Limits.lim_univ co.Universal.Limits.lim_cone)) in
  check "limit presentation isomorphism"
    (eq (compose u v) (F.ident (Universal.Diagrams.cone_apex co.Universal.Limits.lim_cone)) &&
     eq (compose v u) (F.ident (Universal.Diagrams.cone_apex co'.Universal.Limits.lim_cone)));
  let flip = get (F.arrow b (fun x -> match F.view x with
    | F.Atom 1 -> F.atom 2 | _ -> F.atom 1) b) in
  let changed = get (Universal.Diagrams.diagram F.cat shape ~objects:["a",b;"b",b] ~arrows:["f",flip]) in
  let constant = get (F.arrow b (fun _ -> F.atom 1) s) in
  let other = get (Universal.Diagrams.cocone changed s ~sides:["a",constant;"b",constant]) in
  reject "colimit different edge base" different (cc.Universal.Limits.colim_univ other);
  let cone = get (Universal.Diagrams.cone changed s ~sides:["a",get (F.arrow s (fun _ -> F.atom 1) b);
    "b",get (F.arrow s (fun _ -> F.atom 2) b)]) in
  reject "limit different edge base" different (co.Universal.Limits.lim_univ cone);
  let empty = get (Universal.Diagrams.diagram F.cat (get (Universal.Diagrams.graph ~nodes:[] ~edges:[])) ~objects:[] ~arrows:[]) in
  let e = get (U.set_colimit empty) in
  reject "empty colimit wrong base" different (e.Universal.Limits.colim_univ other);
  let e = get (U.set_limit empty) in
  reject "empty limit wrong base" different (e.Universal.Limits.lim_univ cone);
  let low = get (Universal.Diagrams.cocone d s ~sides:["a",constant;"b",constant]) in
  let high = get (Universal.Diagrams.cocone d b ~sides:["a",compose (get (F.arrow s (fun x -> x) b)) constant;
    "b",compose (get (F.arrow s (fun x -> x) b)) constant]) in
  let arrow = get (Universal.Diagrams.cocone_arrow low (get (F.arrow s (fun x -> x) b)) high) in
  let dual = Universal.Diagrams.dual_cocone_arrow arrow in
  check "dual cocone arrow reverses domain"
    (same_cone (Universal.Diagrams.cone_arrow_domain dual) (Universal.Diagrams.dual_cocone high));
  check "dual cocone arrow reverses codomain"
    (same_cone (Universal.Diagrams.cone_arrow_codomain dual) (Universal.Diagrams.dual_cocone low));
  let restored = Universal.Diagrams.dual_cone_arrow dual in
  check "double dual cocone arrow"
    (eq (Universal.Diagrams.cocone_apex_arrow restored) (Universal.Diagrams.cocone_apex_arrow arrow) &&
     same_cocone (Universal.Diagrams.cocone_arrow_domain restored) low);
  let dual_limit = Universal.Limits.dual_limit (Universal.Limits.dual_colimit U.set_colimit) in
  check_colimit d (get (dual_limit d));
  let sentinel = Foundations.Category.Non_commuting "primitive sentinel" in
  let bad = { U.io_cp_ce_finset with Universal.Limits.iocc_coequalizer = (fun _ -> Error sentinel) } in
  reject "primitive error unchanged" (fun e -> e == sentinel) (Universal.Limits.finite_colimit bad d);
  let exn = Failure "primitive callback" in
  let bad = { U.io_cp_ce_finset with Universal.Limits.iocc_coproduct = (fun _ -> raise exn) } in
  check "primitive exception unchanged"
    (try ignore (Universal.Limits.finite_colimit bad d); false with e -> e == exn)

module S = Instances.Finite_sets.Make (struct type t = string let equal = String.equal end)
module SU = Instances.Finite_set_universals.Make (S)
let test_book_pushout () =
  let set names = S.of_list (List.map S.atom names) in
  let a = set ["A";"B";"C";"D"] and b = set ["C";"D";"E";"F";"G"] in
  let c = set ["B";"E";"F";"G"] in
  let map source entries target = get (S.arrow source (fun x -> match S.view x with
    | S.Atom name -> S.atom (List.assoc name entries) | _ -> assert false) target) in
  let f = map a ["A","C";"B","C";"C","D";"D","E"] b in
  let g = map a ["A","B";"B","E";"C","B";"D","F"] c in
  let shape = get (Universal.Diagrams.graph ~nodes:["a";"b";"c"] ~edges:["f","a","b";"g","a","c"]) in
  let d = get (Universal.Diagrams.diagram S.cat shape ~objects:["a",a;"b",b;"c",c] ~arrows:["f",f;"g",g]) in
  let cc = get (SU.set_colimit d) in
  let apex = Universal.Diagrams.cocone_apex cc.Universal.Limits.colim_cocone in
  check "book pushout five classes" (S.cardinality apex = 5);
  let image (node,name) = get (S.apply (get (Universal.Diagrams.cocone_side cc.Universal.Limits.colim_cocone node)) (S.atom name)) in
  let classes = [
    ["a","A";"a","B";"a","C";"b","C";"b","D";"c","B";"c","E"];
    ["a","D";"b","E";"c","F"];
    ["b","F"]; ["b","G"]; ["c","G"] ] in
  let reps = List.map (fun cls ->
    let rep = image (List.hd cls) in
    check "book labelled identifications" (List.for_all (fun x -> S.equal rep (image x)) cls);
    rep) classes in
  check "book classes remain distinct" (S.cardinality (S.of_list reps) = 5);
  let expected = set ["one";"two";"three";"four";"five"] in
  let labels = ["one";"two";"three";"four";"five"] in
  let side node domain = get (S.arrow domain (fun x -> match S.view x with
    | S.Atom name ->
      let rec locate classes labels = match classes,labels with
        | cls::rest,label::tail -> if List.mem (node,name) cls then S.atom label
          else locate rest tail
        | _ -> assert false in locate classes labels
    | _ -> assert false) expected) in
  let other = get (Universal.Diagrams.cocone d expected ~sides:["a",side "a" a;"b",side "b" b;"c",side "c" c]) in
  let forward = Universal.Diagrams.cocone_apex_arrow (get (cc.Universal.Limits.colim_univ other)) in
  let backward = get (S.arrow expected (fun x -> match S.view x with
    | S.Atom label -> List.assoc label (List.combine labels reps) | _ -> assert false) apex) in
  check "book explicit comparison isomorphism"
    (S.equal_arrow (get (S.compose backward forward)) (S.ident apex) &&
     S.equal_arrow (get (S.compose forward backward)) (S.ident expected));
  let reordered = get (Universal.Diagrams.diagram S.cat
    (get (Universal.Diagrams.graph ~nodes:["c";"a";"b"] ~edges:["g","a","c";"f","a","b"]))
    ~objects:["c",c;"b",b;"a",a] ~arrows:["g",g;"f",f]) in
  let cc' = get (SU.set_colimit reordered) in
  let u = Universal.Diagrams.cocone_apex_arrow (get (cc.Universal.Limits.colim_univ cc'.Universal.Limits.colim_cocone)) in
  let v = Universal.Diagrams.cocone_apex_arrow (get (cc'.Universal.Limits.colim_univ cc.Universal.Limits.colim_cocone)) in
  check "book reordered node and edge presentation isomorphism"
    (S.equal_arrow (get (S.compose v u)) (S.ident apex) &&
     S.equal_arrow (get (S.compose u v)) (S.ident (Universal.Diagrams.cocone_apex cc'.Universal.Limits.colim_cocone)));
  let po,med = get (SU.set_pushout (f,g)) in
  check "book specialization cardinality" (S.cardinality po.Universal.Limits.pushout_obj = 5);
  let u = get (med expected (side "b" b) (side "c" c)) in
  check "book specialized mediator"
    (S.equal_arrow (get (S.compose u po.Universal.Limits.pushout_leg1)) (side "b" b) &&
     S.equal_arrow (get (S.compose u po.Universal.Limits.pushout_leg2)) (side "c" c));
  let pb,med = get (SU.set_pullback (f,f)) in
  check "non-unit pullback witnesses" (S.cardinality pb.Universal.Limits.pullback_obj = 6);
  let u = get (med a (S.ident a) (S.ident a)) in
  check "non-unit pullback mediator"
    (S.equal_arrow (get (S.compose pb.Universal.Limits.pullback_proj1 u)) (S.ident a) &&
     S.equal_arrow (get (S.compose pb.Universal.Limits.pullback_proj2 u)) (S.ident a))

let () =
  Primitives.run ();
  List.iter (fun (name,test) -> test (); Printf.printf "PASS %s\n%!" name)
    ["generic finite diagrams",test_finite_diagrams; "independent boolean category",test_boolean_category;
     "pullback universality",test_pullbacks; "duality, bases and failures",test_transformations_and_failures;
     "book pushout",test_book_pushout];
  Printf.printf "Diagram coverage: %d FinSet diagrams, %d mediator cases, %d uniqueness cases, %d larger equation-only cases; %d boolean diagrams, %d boolean mediators; %d pullbacks.\n%!"
    !diagrams !factors !uniqueness !larger_equations !bool_diagrams !bool_factors !pullbacks
