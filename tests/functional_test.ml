(* Test suite for the Computational Category Theory library *)

open Core
open Cat
open Finite_sets
open Universal
open Graphs
open Term_category
open Colimits
open Limits
open Relations
open Functors

(* ============================================================================
   Test: Core (Ch2 exercises)
   ============================================================================ *)
let test_core () =
  assert (numprint Zero = 0);
  assert (numprint (Succ Zero) = 1);
  assert (sum_list [1;2;3;4] = 10);
  assert (max_list [3;7;2;9] = 9);
  assert (fold (fun a b -> a + b) 0 [1;2;3] = 6);
  assert (poly [1;2;3] 2 = 17);
  let add_monoid = { op = (fun (a,b) -> a+b); identity = 0 } in
  assert (free_monoid_hom add_monoid (fun x -> x) [1;2;3;4] = 10);
  Printf.printf "✓ Core (Ch2) passed\n"

(* ============================================================================
   Test: Category type and duality (Ch3)
   ============================================================================ *)
let test_cat () =
  let (Cat (s, t, i, c)) = finset_cat in
  let a = [1;2] in
  let b = [3;4] in
  let f = SetArrow (a, (fun x -> x + 2), b) in
  assert (set_s f = a);
  assert (set_t f = b);
  assert (set_arrow_apply f 1 = 3);
  let (Cat (s', t', i', c')) = dual_cat finset_cat in
  assert (s' f = b);
  assert (t' f = a);
  let (Cat (fs, ft, fi, fc)) = FiniteCategory.cat in
  assert (fs FiniteCategory.F = FiniteCategory.B);
  assert (ft FiniteCategory.F = FiniteCategory.A);
  Printf.printf "✓ Categories & duality (Ch3) passed\n"

(* ============================================================================
   Test: Finite sets (Ch2 Ex9, Ch3.4.1)
   ============================================================================ *)
let test_finite_sets () =
  assert (seteq [1;2;3] [1;2;3]);
  assert (not (seteq [1;2] [1;2;3]));
  assert (seteq (union [1;2] [2;3]) [1;2;3]);
  assert (cartesian_prod [1;2] [3] = [(1,3);(2,3)]);
  assert (List.length (powerset [1;2]) = 4);
  let du = disjoint_union [1;2] [3] in
  assert (List.length du = 3);
  Printf.printf "✓ Finite sets passed\n"

(* ============================================================================
   Test: Functors (Ch3.5)
   ============================================================================ *)
let test_functors () =
  let (FFunctor (src, fo, fa, tgt)) = id_functor finset_cat in
  let a = [1;2;3] in
  assert (fo a = a);
  let (FFunctor (_, xo, xa, _)) = product_functor in
  let pa = xo [1;2] in
  assert (List.length pa = 4);
  Printf.printf "✓ Functors (Ch3.5) passed\n"

(* ============================================================================
   Test: Coequalizer with union-find (Ch4.6)
   ============================================================================ *)
let test_coequalizer_uf () =
  let a = ['a'; 'b'] in
  let f = SetArrow (a, (fun x -> x), a) in
  let g = SetArrow (a, (fun x -> if x = 'a' then 'b' else 'a'), a) in
  let classes = set_coequalizer_classes f g in
  assert (List.length classes = 1);
  let cls = List.hd classes in
  assert (List.length cls = 2);
  Printf.printf "✓ Union-find coequalizer (Ch4.6) passed\n"

(* ============================================================================
   Test: Pushout in FinSet (Ch4.7)
   ============================================================================ *)
let test_pushout () =
  (* Pushout of {x} <- {x} -> {x;y} with both maps x |-> x.
     B = {x}, C = {x;y}, identified along the common {x}.
     The pushout has classes {x} and {y}: 2 elements. *)
  let open Finite_sets in
  (* Source a = {x} (single element), b = {x}, c = {x; y} *)
  let a = ['x'] in
  let b = ['x'] in
  let c = ['x'; 'y'] in
  let f = SetArrow (a, (fun x -> x), b) in
  let g = SetArrow (a, (fun x -> x), c) in
  let (pushout_obj, to_b, to_c) = Colimits.set_pushout f g in
  (* The pushout should have 2 classes: {x} (merged) and {y} *)
  assert (List.length pushout_obj = 2);
  Printf.printf "✓ Pushout construction (Ch4.7) passed\n"

(* ============================================================================
   Test: Limits via duality (Ch4.9)
   ============================================================================ *)
let test_limits () =
  let (tobj, _) = set_terminal in
  assert (tobj = [()]);
  let ((prod, p1, p2), _) = set_product ([1;2], [3;4]) in
  assert (List.length prod = 4);
  let f = SetArrow ([1;2;3], (fun x -> x), [1;2;3]) in
  let g = SetArrow ([1;2;3], (fun x -> 1), [1;2;3]) in
  let ((eobj, _), _) = set_equalizer (f, g) in
  assert (eobj = [1]);
  Printf.printf "✓ Limits via duality (Ch4.9) passed\n"

(* ============================================================================
   Run all tests
   ============================================================================ *)
let () =
  Printf.printf "Running functional test suite...\n";
  test_core ();
  test_cat ();
  test_finite_sets ();
  test_functors ();
  test_coequalizer_uf ();
  test_pushout ();
  test_limits ();
  Printf.printf "\nAll functional tests passed successfully! ✓\n"
