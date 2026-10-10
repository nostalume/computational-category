(* Relations as witness-bearing spans; finite images are compared independently. *)
open Computational_category
module F = Instances.Finite_sets.Make (struct type t = int let equal (a : int) b = a = b end)
module U = Instances.Finite_set_universals.Make (F)
module R = Instances.Finite_relations.Make (F)
open Category_test_support.Checks
let malformed = function Foundations.Category.Malformed_relation _ -> true | _ -> false
let noncomp = function Foundations.Category.Non_composable _ -> true | _ -> false
let ints xs = F.of_list (List.map F.atom xs)
let base = ints [1;2]
let objects = F.powerset base
let left = Constructions.Spans.span_left
let right = Constructions.Spans.span_right
let source = Constructions.Spans.span_source
let comp next previous = get (Constructions.Spans.compose U.complete_finset next previous)
let amap f x = get (F.apply f x)
let arrow_comp g f = get (F.compose g f)
let admissions = ref 0
let compositions = ref 0
let associations = ref 0
let isomorphisms = ref 0

let relation a pairs b = get (R.relation_span ~left:a ~right:b pairs)
let pairs xs = F.of_list (List.map (fun (x,y) -> F.pair (F.atom x) (F.atom y)) xs)

let rec choices = function
  | [] -> [[]]
  | (x,values) :: rest ->
    List.concat_map (fun value -> List.map (fun entries -> (x,value)::entries)
      (choices rest)) values
let all_maps domain codomain =
  List.map (fun entries -> get (F.arrow domain (fun x ->
    snd (List.find (fun (y,_) -> F.equal x y) entries)) codomain))
    (choices (List.map (fun x -> x,F.to_list codomain) (F.to_list domain)))

let span_endpoints label s a b =
  check (label ^ " left target") (F.seteq (F.target (left s)) a);
  check (label ^ " right target") (F.seteq (F.target (right s)) b);
  check (label ^ " common source")
    (F.seteq (F.source (left s)) (source s) && F.seteq (F.source (right s)) (source s))

(* Match finite endpoint fibres one-to-one, then check the constructed arrows
   and inverses. Equal images alone do not prove span isomorphism. *)
let span_iso label a b =
  check (label ^ " endpoints")
    (F.seteq (F.target (left a)) (F.target (left b)) &&
     F.seteq (F.target (right a)) (F.target (right b)));
  let rec match_fibres domain unused =
    match domain with
    | [] -> check (label ^ " onto") (unused = []); []
    | x :: rest ->
      let compatible y = F.equal (amap (left a) x) (amap (left b) y) &&
                         F.equal (amap (right a) x) (amap (right b) y) in
      match List.find_opt compatible unused with
      | None -> failwith (label ^ ": unequal witness fibres")
      | Some y -> (x,y) :: match_fibres rest (List.filter (fun z -> not (F.equal z y)) unused)
  in
  let entries = match_fibres (F.to_list (source a)) (F.to_list (source b)) in
  let f = get (F.arrow (source a) (fun x ->
    snd (List.find (fun (v,_) -> F.equal x v) entries)) (source b)) in
  let g = get (F.arrow (source b) (fun y ->
    fst (List.find (fun (_,v) -> F.equal y v) entries)) (source a)) in
  check (label ^ " forward legs")
    (F.equal_arrow (arrow_comp (left b) f) (left a) &&
     F.equal_arrow (arrow_comp (right b) f) (right a));
  check (label ^ " inverse legs")
    (F.equal_arrow (arrow_comp (left a) g) (left b) &&
     F.equal_arrow (arrow_comp (right a) g) (right b));
  check (label ^ " inverse equations")
    (F.equal_arrow (arrow_comp g f) (F.ident (source a)) &&
     F.equal_arrow (arrow_comp f g) (F.ident (source b)));
  incr isomorphisms

let matching_witnesses previous next =
  List.concat_map (fun x -> List.filter_map (fun y ->
    if F.equal (amap (right previous) x) (amap (left next) y)
    then Some (x,y) else None) (F.to_list (source next))) (F.to_list (source previous))
let image_oracle previous next =
  F.of_list (List.map (fun (x,y) ->
    F.pair (amap (left previous) x) (amap (right next) y))
    (matching_witnesses previous next))
let direct_relational_image a r b s c =
  F.of_list (List.concat_map (fun x -> List.filter_map (fun z ->
    if List.exists (fun y -> F.member (F.pair x y) r && F.member (F.pair y z) s)
      (F.to_list b) then Some (F.pair x z) else None) (F.to_list c)) (F.to_list a))

let test_relation_admission () =
  List.iter (fun a -> List.iter (fun b ->
    List.iter (fun carrier ->
      incr admissions;
      let r = relation a carrier b in
      span_endpoints "relation projection" r a b;
      check "relation carrier retained" (F.seteq (source r) carrier);
      check "relation image roundtrip" (F.seteq (get (R.image r)) carrier);
      span_iso "relation left identity" (comp (Constructions.Spans.identity F.cat b) r) r;
      span_iso "relation right identity" (comp r (Constructions.Spans.identity F.cat a)) r;
      List.iter (fun value -> match F.view value with
        | F.Pair (x,y) ->
          check "left pair projection" (F.equal (amap (left r) value) x);
          check "right pair projection" (F.equal (amap (right r) value) y)
        | _ -> assert false) (F.to_list carrier)
    ) (F.powerset (F.cartesian_prod a b))) objects) objects;
  let s = ints [1] in
  reject "nonpair relation" malformed (R.relation_span ~left:s ~right:s (ints [1]));
  reject "left membership" malformed
    (R.relation_span ~left:s ~right:s (pairs [2,1]));
  reject "right membership" malformed
    (R.relation_span ~left:s ~right:s (pairs [1,2]));
  reject "malformed pair diagnostic locates input"
    (function Foundations.Category.Malformed_relation s -> String.contains s '0' | _ -> false)
    (R.relation_span ~left:s ~right:s (ints [1]));
  let nested_left = F.tag 0 (F.atom 1) and nested_right = F.pair (F.atom 1) F.terminal in
  let carrier = F.singleton (F.pair nested_left nested_right) in
  let r = relation (F.singleton nested_left) carrier (F.singleton nested_right) in
  check "nested closed-universe relation" (F.seteq (get (R.image r)) carrier)

let test_relational_composition () =
  List.iter (fun a -> List.iter (fun b -> List.iter (fun c ->
    List.iter (fun r -> List.iter (fun s ->
      incr compositions;
      let previous = relation a r b and next = relation b s c in
      let result = comp next previous in
      span_endpoints "composition endpoints" result a c;
      check "composition direct existential image"
        (F.seteq (get (R.image result)) (direct_relational_image a r b s c));
      check "composition witness cardinality"
        (F.cardinality (source result) = List.length (matching_witnesses previous next));
      check "composition projected witness image"
        (F.seteq (get (R.image result)) (image_oracle previous next))
    ) (F.powerset (F.cartesian_prod b c))) (F.powerset (F.cartesian_prod a b))
  ) objects) objects) objects

let endospans () =
  List.concat_map (fun witnesses ->
    List.concat_map (fun f -> List.map (fun g -> get (Constructions.Spans.span F.cat f g))
      (all_maps witnesses base)) (all_maps witnesses base))
    (F.powerset (ints [10;20]))

let test_span_laws () =
  let spans = endospans () in
  check "endo span enumeration" (List.length spans = 25);
  let id = Constructions.Spans.identity F.cat base in
  span_endpoints "identity span" id base base;
  check "identity image diagonal" (F.seteq (get (R.image id)) (pairs [1,1;2,2]));
  List.iter (fun r ->
    span_iso "left identity span" (comp id r) r;
    span_iso "right identity span" (comp r id) r
  ) spans;
  let empty_id = Constructions.Spans.identity F.cat F.emptyset in
  check "empty identity witnesses" (F.is_empty (source empty_id));
  List.iter (fun r -> List.iter (fun s -> List.iter (fun t ->
    incr associations;
    let rs = comp s r and st = comp t s in
    let lhs = comp t rs and rhs = comp st r in
    span_iso "associative witness span" lhs rhs;
    check "associative extensional images"
      (F.seteq (get (R.image lhs)) (get (R.image rhs)));
    let paths = List.fold_left (fun count (_,y) ->
      count + List.length (List.filter (fun z ->
        F.equal (amap (right s) y) (amap (left t) z)) (F.to_list (source t))))
      0 (matching_witnesses r s) in
    check "associative path witnesses"
      (F.cardinality (source lhs) = paths && F.cardinality (source rhs) = paths)
  ) spans) spans) spans

let test_multiplicity_and_snapshots () =
  let a = ints [1] and b = ints [3;4] and c = ints [6] in
  let r = relation a (pairs [1,3;1,4]) b in
  let s = relation b (pairs [3,6;4,6]) c in
  let result = comp s r in
  check "two paths retain two witnesses" (F.cardinality (source result) = 2);
  check "two paths have one image pair" (F.seteq (get (R.image result)) (pairs [1,6]));
  check "image does not normalize span" (F.cardinality (source result) = 2);
  span_iso "multiplicity under identity"
    (comp (Constructions.Spans.identity F.cat c) result) result;
  let witnesses = ints [10;20] in
  let count = ref 0 in
  let f = get (F.arrow witnesses (fun _ -> incr count; F.atom 1) a) in
  let g = get (F.arrow witnesses (fun _ -> incr count; F.atom 3) (ints [3])) in
  let raw = get (Constructions.Spans.span F.cat f g) in
  let next = relation (ints [3]) (pairs [3,6]) c in
  let result = comp next raw in
  ignore (get (R.image result));
  ignore (get (R.image raw));
  check "relation operations do not replay source callbacks" (!count = 4);
  check "distinct input witnesses retained" (F.cardinality (source result) = 2);
  let reordered = get (Constructions.Spans.span F.cat
    (get (F.arrow (ints [20;10]) (fun _ -> F.atom 3) (ints [4;3])))
    (get (F.arrow (ints [10;20]) (fun _ -> F.atom 6) c))) in
  let prior = relation a (pairs [1,3]) (ints [3;4]) in
  let result = comp reordered prior in
  span_endpoints "extensional intermediate" result a c;
  check "reordered middle composes" (F.cardinality (source result) = 2)

module Abs = Instances.Finite_sets.Make (struct type t = int let equal a b = abs a = abs b end)
module AbsL = Instances.Finite_set_universals.Make (Abs)
module AbsR = Instances.Finite_relations.Make (Abs)
let test_custom_equality_and_failures () =
  let one = Abs.singleton (Abs.atom 1) and two = Abs.singleton (Abs.atom 2) in
  let minus_two = Abs.singleton (Abs.atom (-2)) and three = Abs.singleton (Abs.atom 3) in
  let r = get (AbsR.relation_span ~left:one ~right:minus_two
    (Abs.singleton (Abs.pair (Abs.atom (-1)) (Abs.atom 2)))) in
  let s = get (AbsR.relation_span ~left:two ~right:three
    (Abs.singleton (Abs.pair (Abs.atom (-2)) (Abs.atom (-3))))) in
  let result = get (Constructions.Spans.compose AbsL.complete_finset s r) in
  check "custom equality membership and intermediate objects"
    (Abs.seteq (get (AbsR.image result)) (Abs.singleton (Abs.pair (Abs.atom 1) (Abs.atom 3))));
  let a = ints [1] and b = ints [3] and c = ints [6] in
  let r = relation a (pairs [1,3]) b in
  let s = relation (ints [4]) (pairs [4,6]) c in
  let exn = Failure "pullback callback" in
  let bad = { U.complete_finset with Universal.Limits.co_limit = (fun _ -> raise exn) } in
  reject "intermediate endpoint mismatch" noncomp (Constructions.Spans.compose bad s r);
  reject "composition direction is next after previous" noncomp (Constructions.Spans.compose U.complete_finset r
    (relation b (pairs [3,6]) c));
  let s = relation b (pairs [3,6]) c in
  check "pullback exception unchanged"
    (try ignore (Constructions.Spans.compose bad s r); false with e -> e == exn);
  let sentinel = Foundations.Category.Non_commuting "pullback sentinel" in
  let bad = { U.complete_finset with Universal.Limits.co_limit = (fun _ -> Error sentinel) } in
  reject "pullback result error unchanged" (fun e -> e == sentinel) (Constructions.Spans.compose bad s r);
  let exn = Failure "category object equality" in
  let bad_cat = { F.cat with Foundations.Category.equal_obj = (fun _ _ -> raise exn) } in
  let bad = { U.complete_finset with Universal.Limits.co_cat = bad_cat } in
  check "span object equality exception unchanged"
    (try ignore (Constructions.Spans.compose bad s r); false with e -> e == exn);
  let exn = Failure "category identity" in
  let bad_cat = { F.cat with Foundations.Category.ident = (fun _ -> raise exn) } in
  check "span identity exception unchanged"
    (try ignore (Constructions.Spans.identity bad_cat a); false with e -> e == exn);
  let exn = Failure "relation equality" in
  let module E = Instances.Finite_sets.Make (struct
    type t = int
    let equal a b = if a = 99 || b = 99 then raise exn else a = b
  end) in
  let module ER = Instances.Finite_relations.Make (E) in
  check "relation equality exception unchanged"
    (try ignore (ER.relation_span ~left:(E.singleton (E.atom 1))
      ~right:(E.singleton (E.atom 1)) (E.singleton (E.pair (E.atom 99) (E.atom 1))));
      false with e -> e == exn)

(* The terminal category is independently specified and finitely complete.
   Its unique limiting cone/mediator uses no concrete finite-set representation. *)
let test_generic_composition () =
  let cat = { Foundations.Category.source = (fun () -> ()); target = (fun () -> ());
    ident = (fun () -> ()); equal_obj = (fun () () -> true);
    equal_arr = (fun () () -> true); comp = (fun ((),()) -> Ok ()) } in
  let limit d =
    let open Foundations.Category in
    let* co = Universal.Diagrams.cone d () ~sides:(List.map (fun n -> n,()) (Universal.Diagrams.diagram_nodes d)) in
    Ok { Universal.Limits.lim_cone = co; lim_univ = (fun other -> Universal.Diagrams.cone_arrow other () co) } in
  let complete = { Universal.Limits.co_cat = cat; co_limit = limit } in
  let r = get (Constructions.Spans.span cat () ()) in
  let result = get (Constructions.Spans.compose complete r (Constructions.Spans.identity cat ())) in
  check "generic terminal-category span source" (source result = ());
  check "generic terminal-category legs" (left result = () && right result = ())

let test_book_example () =
  let a = ints [1;2] and b = ints [3;4;5] and c = ints [6;7] in
  let r = relation a (pairs [1,3;2,3;2,4]) b in
  let s = relation b (pairs [3,6;4,6;4,7;5,6]) c in
  let result = comp s r in
  span_endpoints "book composition projections" result a c;
  check "book four witnesses" (F.cardinality (source result) = 4);
  check "book three-pair image" (F.seteq (get (R.image result)) (pairs [1,6;2,6;2,7]));
  let fibre x y = List.filter (fun w ->
    F.equal (amap (left result) w) (F.atom x) &&
    F.equal (amap (right result) w) (F.atom y)) (F.to_list (source result)) in
  check "book duplicate 2-to-6 witnesses" (List.length (fibre 2 6) = 2);
  let witnesses = ints [10;11;12;13] in
  let f = get (F.arrow witnesses (fun x -> match F.view x with
    | F.Atom 10 -> F.atom 1 | _ -> F.atom 2) a) in
  let g = get (F.arrow witnesses (fun x -> match F.view x with
    | F.Atom 13 -> F.atom 7 | _ -> F.atom 6) c) in
  span_iso "book explicit witness comparison" result (get (Constructions.Spans.span F.cat f g))

let () =
  List.iter (fun (name,test) -> test (); Printf.printf "PASS %s\n%!" name)
    ["relation admission and projections",test_relation_admission;
     "relational composition oracle",test_relational_composition;
     "span identity and associativity",test_span_laws;
     "witness multiplicity and snapshots",test_multiplicity_and_snapshots;
     "custom equality and failures",test_custom_equality_and_failures;
     "independent generic span category",test_generic_composition;
     "book relations",test_book_example];
  Printf.printf "Relation coverage: %d admissions, %d composable relation pairs, %d associativity triples, %d checked span isomorphisms.\n%!"
    !admissions !compositions !associations !isomorphisms
