open Computational_category
open Category_test_support.Checks
module F = Instances.Finite_sets.Make (struct
  type t = int
  let equal (a:int) b = a = b
end)
module U = Instances.Finite_set_universals.Make (F)
module T = Instances.Term_unification

let get = Category_test_support.Checks.get
let sym name args = get (T.symbol name args)
let app s xs = get (T.application s xs)
let v = T.variable

let test_unification () =
  let f = sym "f" ["x"] and g = sym "g" ["x"] and c = sym "c" [] in
  let x = v "x" and y = v "y" and a = app c [] in
  let fx = app f ["x",x] and fa = app f ["x",a] in
  let result = get (T.unify [fx,fa; y,fx]) in
  let image_x = get (T.image result "x") and image_y = get (T.image result "y") in
  check "unification binds variable" (T.equal_term image_x a);
  check "unification propagates binding" (T.equal_term image_y fa);
  reject_any "unification clash" (T.unify [app f ["x",x], app g ["x",x]]);
  reject_any "unification occurs check" (T.unify [x, fx]);
  let generalized = get (T.generalize (app f ["x",a]) (app f ["x",y])) in
  let left = get (T.apply generalized.left generalized.pattern)
  and right = get (T.apply generalized.right generalized.pattern) in
  check "generalization left instance" (T.equal_term left (app f ["x",a]));
  check "generalization right instance" (T.equal_term right (app f ["x",y]));
  Printf.printf "PASS term unification\n%!"

let test_factorized_coequalizer () =
  let value = F.atom in
  let a = F.singleton (value 0) and a' = F.singleton (value 1) in
  let b = F.carrier_of_list [value 2; value 3] in
  let g = get (F.morphism a (fun _ -> value 1) a') in
  let factor = get (F.morphism a' (fun _ -> value 2) b) in
  let other = get (F.morphism a (fun _ -> value 3) b) in
  let result = get (Constructions.Coequalizer_reduction.factorized_coequalizer
    F.cat U.pushout U.coequalizer ~g ~factor ~other) in
  check "factorized coequalizer quotient" (F.cardinality (F.codomain result) = 1);
  Printf.printf "PASS factorized coequalizer\n%!"

let () = test_unification (); test_factorized_coequalizer ()
