open Computational_category
module F = Instances.Finite_sets.Make (struct
  type t = string
  let equal = String.equal
end)
module U = Instances.Finite_set_universals.Make (F)
module T = Instances.Finite_set_topos.Make (F)
open Category_test_support.Checks

let value x = F.atom x
let set xs = F.carrier_of_list (List.map value xs)
let apply a x = get (F.eval a x)

let test_exponential () =
  let a = set ["a";"b"] and b = set ["0";"1"] and c = set ["x";"y"] in
  let product, _ = get (U.product (a,c)) in
  let f = get (F.morphism product.Universal.Limits.prod_obj (fun z ->
    match F.view z with
    | F.Pair (x,y) when F.equal x (value "a") && F.equal y (value "x") -> value "0"
    | F.Pair (x,y) when F.equal x (value "b") && F.equal y (value "x") -> value "1"
    | F.Pair (x,y) when F.equal x (value "a") && F.equal y (value "y") -> value "1"
    | F.Pair _ -> value "0"
    | _ -> value "0") b) in
  let fs = get (T.function_space a b) in
  check "finite exponential cardinality" (F.cardinality fs = 4);
  let curried = get (T.exponential.curry a b c f) in
  let evaluation = get (T.exponential.eval a b fs) in
  List.iter (fun x -> List.iter (fun y ->
    let fn = apply curried y in
    let got = apply evaluation (F.pair x fn) in
    let expected = apply f (F.pair x y) in
    check "curry/evaluation" (F.equal got expected)) (F.carrier_to_list c)) (F.carrier_to_list a)

let test_classifier_and_logic () =
  let a = set ["a";"b"] in
  let mono = get (F.morphism (set ["a"]) (fun x -> x) a) in
  let chi = get (T.topos.topos_classifier.character mono) in
  check "classifier true" (T.is_true (apply chi (value "a")));
  check "classifier false" (not (T.is_true (apply chi (value "b"))));
  let omega = T.topos.topos_classifier.omega in
  let not_arrow = get (Universal.Topos.not_ T.topos) in
  check "not true" (not (T.is_true (apply not_arrow (T.truth_value true))));
  check "not false" (T.is_true (apply not_arrow (T.truth_value false)));
  let and_arrow = get (Universal.Topos.and_ T.topos) in
  let and_arg = F.pair (T.truth_value true) (T.truth_value true) in
  check "and source" (F.mem and_arg (F.domain and_arrow));
  check "and true" (T.is_true (apply and_arrow and_arg));
  check "and false" (not (T.is_true (apply and_arrow (F.pair (T.truth_value true) (T.truth_value false)))));
  let or_arrow = get (Universal.Topos.or_ T.topos) in
  check "or true" (T.is_true (apply or_arrow (F.pair (T.truth_value false) (T.truth_value true))));
  check "or false" (not (T.is_true (apply or_arrow (F.pair (T.truth_value false) (T.truth_value false)))));
  let imply_arrow = get (Universal.Topos.imply_ T.topos) in
  check "imply false" (not (T.is_true (apply imply_arrow (F.pair (T.truth_value true) (T.truth_value false)))));
  check "imply true" (T.is_true (apply imply_arrow (F.pair (T.truth_value false) (T.truth_value false))));
  check "omega has two values" (F.cardinality omega = 2)

let test_power_and_quantifiers () =
  let a = set ["a";"b"] in
  let p = get (T.power_object a) in
  check "power object has all predicates" (F.cardinality p.power_obj = 4);
  check "power membership has two true pairs" (F.cardinality (F.domain p.membership) = 4);
  let all_arrow = get (Universal.Topos.for_all T.topos a) in
  let exists_arrow = get (T.exists a) in
  let true_pred = get (F.morphism a (fun _ -> T.truth_value true) T.topos.topos_classifier.omega) in
  let false_pred = get (F.morphism a (fun _ -> T.truth_value false) T.topos.topos_classifier.omega) in
  let true_name = get (Universal.Topos.name T.topos true_pred) in
  let false_name = get (Universal.Topos.name T.topos false_pred) in
  let true_fn = apply true_name F.terminal and false_fn = apply false_name F.terminal in
  check "forall true" (T.is_true (apply all_arrow true_fn));
  check "forall false" (not (T.is_true (apply all_arrow false_fn)));
  check "exists true" (T.is_true (apply exists_arrow true_fn));
  check "exists false" (not (T.is_true (apply exists_arrow false_fn)))

let () =
  List.iter (fun (label,test) -> test (); Printf.printf "PASS %s\n%!" label)
    ["finite exponentials",test_exponential;
     "subobject classifier and logic",test_classifier_and_logic;
     "power objects and quantifiers",test_power_and_quantifiers]
