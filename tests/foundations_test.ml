open Computational_category
open Category_test_support.Checks
open Category_test_support.Finite_set_fixture
module A = Instances.Finite_sets.Make (struct type t = int let equal a b = abs a = abs b end)
module AU = Instances.Finite_set_universals.Make (A)
let triple_count = ref 0
let category_laws cat arrows =
  List.iter (fun f ->
    check "left identity" (cat.Foundations.Category.equal_arr
      (get (Foundations.Category.compose cat (cat.Foundations.Category.ident (cat.Foundations.Category.target f)) f)) f);
    check "right identity" (cat.Foundations.Category.equal_arr
      (get (Foundations.Category.compose cat f (cat.Foundations.Category.ident (cat.Foundations.Category.source f)))) f)) arrows;
  List.iter (fun f -> List.iter (fun g ->
    if cat.Foundations.Category.equal_obj (cat.Foundations.Category.target f) (cat.Foundations.Category.source g) then begin
      let gf = get (Foundations.Category.compose cat g f) in
      check "composition endpoints" (Foundations.Category.has_endpoints cat gf (cat.Foundations.Category.source f) (cat.Foundations.Category.target g));
      List.iter (fun h ->
        if cat.Foundations.Category.equal_obj (cat.Foundations.Category.target g) (cat.Foundations.Category.source h) then begin
          incr triple_count;
          check "associativity" (cat.Foundations.Category.equal_arr
            (get (Foundations.Category.compose cat h gf))
            (get (Foundations.Category.compose cat (get (Foundations.Category.compose cat h g)) f)))
        end) arrows
    end else reject "noncomposable category pair" noncomp (Foundations.Category.compose cat g f)
  ) arrows) arrows

let test_core () =
  let open Exercises.Basic in
  check "naturals" (numprint Zero = 0 && numprint (Succ Zero) = 1 && numprint (add (Succ Zero) (Succ Zero)) = 2);
  check "lists" (sum_list [1;2;3;4] = 10 && max_list [3;7;2;9] = 9);
  check "fold/poly" (fold (fun a b -> a+b) 0 [1;2;3] = 6 && poly [1;2;3] 2 = 17);
  let m = { op = (fun (a,b) -> a ^ b); identity = "" } in
  let hom = free_monoid_hom m (fun x -> x) in
  check "noncommutative monoid order" (hom ["a";"b";"c"] = "abc");
  let words = [[];["a"];["b"];["a";"b"];["b";"a"]] in
  List.iter (fun x -> List.iter (fun y ->
    check "monoid homomorphism" (hom (x@y) = hom x ^ hom y)) words) words

exception Probe of int ref
let test_sets () =
  check "deduplicate" (I.cardinality (ints [1;2;1]) = 2);
  check "extensional objects" (I.seteq base (ints [2;1]));
  check "set operations" (I.seteq (I.union (ints [1]) (ints [2;1])) base &&
    I.seteq (I.inter base (ints [2])) (ints [2]) &&
    I.seteq (I.diff base (ints [2])) (ints [1]));
  check "image deduplication" (I.cardinality (I.mapset (fun _ -> v 1) base) = 1);
  check "powerset" (List.length objects = 4);
  let sum = I.disjoint_union base base in
  let nested = I.disjoint_union sum base in
  check "recursive closure" (I.cardinality sum = 4 && I.cardinality nested = 6 &&
    I.cardinality (I.cartesian_prod sum base) = 8);
  check "distinct labels/levels" (not (I.equal (I.tag 0 (v 1)) (I.tag 1 (v 1))) &&
    not (I.equal (I.tag 0 (I.tag 0 (v 1))) (I.tag 0 (v 1))) &&
    not (I.equal I.terminal (v 1)));
  List.iter (fun s ->
    let a,b = I.split s in
    check "split preserves set" (I.seteq (I.union a b) s && I.is_empty (I.inter a b));
    if I.cardinality s > 1 then
      check "split reduces" (I.cardinality a < I.cardinality s && I.cardinality b < I.cardinality s)
  ) (nested :: objects);
  check "empty singleton split" (match I.singleton_split I.emptyset with None -> true | Some _ -> false);
  let calls = ref 0 in
  let f = get (I.arrow (ints [1;2;1]) (fun x -> incr calls; x) base) in
  check "sample each unique source once" (!calls = 2);
  ignore (get (I.apply f (v 1))); ignore (get (I.compose (I.ident base) f));
  check "arrow extensional equality" (I.equal_arrow f (I.ident (ints [2;1])));
  check "callbacks not replayed" (!calls = 2);
  endpoints "permuted composition" (composite (I.ident (ints [2;1])) f) base base;
  check "generic permuted composition" (arrow_eq
    (get (Foundations.Category.compose I.cat (I.ident (ints [2;1])) f)) f);
  reject "application outside source" outside (I.apply f (v 3));
  reject "bad image" (function Foundations.Category.Outside_codomain _ -> true | _ -> false)
    (I.arrow base (fun _ -> v 3) base);
  reject "composition mismatch" noncomp (I.compose (I.ident (ints [3])) f);
  let sentinel = ref 9 in
  let threw = try ignore (I.arrow base (fun _ -> raise (Probe sentinel)) base); false
    with Probe p -> p == sentinel in
  check "callback exception unchanged" threw;
  let module E = Instances.Finite_sets.Make (struct type t = int let equal _ _ = raise (Probe sentinel) end) in
  let threw = try ignore (E.arrow (E.singleton (E.atom 1)) (fun x -> x)
    (E.singleton (E.atom 1))); false with Probe p -> p == sentinel in
  check "equality exception unchanged" threw;
  let absset = A.of_list [A.atom 1; A.atom (-1)] in
  check "instance equality" (A.cardinality absset = 1);
  let af = get (A.arrow absset (fun _ -> A.atom 2) (A.singleton (A.atom (-2)))) in
  check "equivalent query uses snapshot" (A.equal (get (A.apply af (A.atom (-1)))) (A.atom 2));
  let ag = get (A.arrow absset (fun _ -> A.atom (-2)) (A.singleton (A.atom 2))) in
  check "custom arrow equality" (A.equal_arrow af ag);
  let e,_ = get (AU.set_equalizer (af,ag)) in
  check "custom equalizer equality" (A.seteq e.Universal.Limits.eq_obj absset);
  let ce,_ = get (AU.set_coequalizer (af,ag)) in
  check "custom quotient equality" (A.cardinality ce.Universal.Limits.coeq_obj = 1);
  let throwing = { I.cat with Foundations.Category.comp = (fun _ -> raise (Probe sentinel)) } in
  let threw = try ignore (Foundations.Category.compose throwing f f); false with Probe p -> p == sentinel in
  check "generic compose does not catch supplier exceptions" threw

let all_arrows () =
  List.concat_map (fun a -> List.concat_map (all_maps a) objects) objects

let test_categories () =
  let arrows = all_arrows () in
  check "finite map fixture count" (List.length arrows = 18);
  category_laws I.cat arrows;
  category_laws (Foundations.Category.dual_cat I.cat) arrows;
  let plus_two = get (I.arrow base (fun x -> match I.view x with
    | I.Atom n -> v (n+2) | _ -> assert false) (ints [3;4])) in
  let times_ten = get (I.arrow (ints [3;4]) (fun x -> match I.view x with
    | I.Atom n -> v (n*10) | _ -> assert false) (ints [10;20;30;40])) in
  check "composition arithmetic orientation"
    (I.equal (get (I.apply (composite times_ten plus_two) (v 1))) (v 30));
  let open Category_test_support.Toy_category in
  category_laws cat [F;G;H;K;Id A;Id B;Id C];
  check "double dual" (Foundations.Category.has_endpoints (Foundations.Category.dual_cat (Foundations.Category.dual_cat I.cat))
    (I.ident base) base base)

let test_terms () =
  let module T = Instances.Terms in
  let x = T.names ["x";"y";"x"] and u = T.names ["u";"v"] in
  let z = T.names ["z"] and w = T.names ["w"] in
  check "term object equality" (T.equal_names x (T.names ["y";"x"]));
  let op = get (T.operator "join" ["left";"right"]) in
  let op_reordered = get (T.operator "join" ["right";"left"]) in
  let calls = ref 0 in
  let t = get (T.application op (fun label -> incr calls;
    T.var (if label = "left" then "x" else "y"))) in
  let t' = get (T.application op_reordered (fun label ->
    T.var (if label = "left" then "x" else "y"))) in
  check "term named argument equality" (T.equal_term t t' && !calls = 2);
  reject "duplicate operator argument" (function Foundations.Category.Malformed_term _ -> true | _ -> false)
    (T.operator "bad" ["a";"a"]);
  let count = ref 0 in
  let f = get (T.substitution x (fun name -> incr count;
    T.var (if name = "x" then "u" else "v")) u) in
  let g = get (T.substitution (T.names ["v";"u"]) (fun _ -> T.var "z") z) in
  let h = get (T.substitution z (fun _ -> T.var "w") w) in
  let image = get (T.apply_term f t) in
  let wanted = get (T.application op (fun label ->
    T.var (if label = "left" then "u" else "v"))) in
  check "substitution through application" (T.equal_term image wanted && !count = 2 && !calls = 2);
  category_laws T.cat [f;g;h;T.ident x;T.ident u;T.ident z;T.ident w];
  reject "undeclared image variable" (function Foundations.Category.Malformed_term _ -> true | _ -> false)
    (T.substitution x (fun _ -> T.var "missing") u);
  reject "undeclared input variable" outside (T.apply_term f (T.var "missing"));
  reject "term middle mismatch" noncomp (T.compose h f);
  check "term callback not replayed" (!count = 2);
  let zero = get (T.application (get (T.operator "zero" [])) (fun _ -> assert false)) in
  ignore (get (T.substitution x (fun _ -> zero) (T.names [])))

let functor_laws f arrows =
  List.iter (fun a ->
    let image = get (f.Foundations.Functor.f_amap a) in
    check "functor endpoints" (Foundations.Category.has_endpoints f.Foundations.Functor.f_cod image
      (f.Foundations.Functor.f_omap (f.Foundations.Functor.f_dom.Foundations.Category.source a))
      (f.Foundations.Functor.f_omap (f.Foundations.Functor.f_dom.Foundations.Category.target a)));
    check "functor identity" (f.Foundations.Functor.f_cod.Foundations.Category.equal_arr
      (get (f.Foundations.Functor.f_amap (f.Foundations.Functor.f_dom.Foundations.Category.ident (f.Foundations.Functor.f_dom.Foundations.Category.source a))))
      (f.Foundations.Functor.f_cod.Foundations.Category.ident (f.Foundations.Functor.f_omap (f.Foundations.Functor.f_dom.Foundations.Category.source a)))))
    arrows;
  List.iter (fun a -> List.iter (fun b ->
    if f.Foundations.Functor.f_dom.Foundations.Category.equal_obj (f.Foundations.Functor.f_dom.Foundations.Category.target a)
        (f.Foundations.Functor.f_dom.Foundations.Category.source b) then
      check "functor composition" (f.Foundations.Functor.f_cod.Foundations.Category.equal_arr
        (get (f.Foundations.Functor.f_amap (get (Foundations.Category.compose f.Foundations.Functor.f_dom b a))))
        (get (Foundations.Category.compose f.Foundations.Functor.f_cod
          (get (f.Foundations.Functor.f_amap b)) (get (f.Foundations.Functor.f_amap a)))))
  ) arrows) arrows

let test_functors () =
  let arrows = all_arrows () in
  functor_laws (Foundations.Functor.id_functor I.cat) arrows;
  functor_laws U.product_functor arrows;
  functor_laws (Foundations.Functor.dual_functor U.product_functor) arrows;
  check "nested product functor" (I.cardinality
    (U.product_functor.Foundations.Functor.f_omap (I.disjoint_union base base)) = 16);
  let sum = I.disjoint_union base base in
  check "nested product functor identity" (arrow_eq
    (get (U.product_functor.Foundations.Functor.f_amap (I.ident sum)))
    (I.ident (U.product_functor.Foundations.Functor.f_omap sum)))

let () =
  List.iter (fun (name,test) -> test (); Printf.printf "PASS %s\n%!" name)
    ["core",test_core; "finite sets and admission",test_sets;
     "category laws",test_categories; "term substitutions",test_terms; "functor laws",test_functors];
  Printf.printf "Foundation coverage: %d map fixtures, %d associativity triples.\n%!"
    !maps_count !triple_count
