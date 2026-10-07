(* Test suite for the Computational Category Theory library.
   Updated for the record-based layered refactor. *)

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
  let c = finset_cat in
  let a = [1;2] in
  let b = [3;4] in
  let f = { sa_src = a; sa_fn = (fun x -> x + 2); sa_tgt = b } in
  assert (set_s f = a);
  assert (set_t f = b);
  assert (set_arrow_apply f 1 = 3);
  let c' = dual_cat c in
  assert (c'.source f = b);
  assert (c'.target f = a);
  let fc = FiniteCategory.cat in
  assert (fc.source FiniteCategory.F = FiniteCategory.B);
  assert (fc.target FiniteCategory.F = FiniteCategory.A);
  (* result-based composition *)
  let g = { sa_src = b; sa_fn = (fun x -> x * 10); sa_tgt = [10;20;30;40] } in
  (match compose_result c g f with
   | Ok h ->
     assert (set_s h = a);
     assert (set_t h = [10;20;30;40]);
     assert (set_arrow_apply h 1 = 30)  (* (1+2)*10 = 30 *)
   | Error _ -> assert false);
  (* non-composable pair must return Error, not raise *)
  let bad_g = { sa_src = [9]; sa_fn = (fun x -> x); sa_tgt = [9] } in
  assert (match compose_result c bad_g f with Ok _ -> false | Error _ -> true);
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
  let ff = id_functor finset_cat in
  let a = [1;2;3] in
  assert (ff.f_omap a = a);
  let pf = product_functor in
  let pa = pf.f_omap [1;2] in
  assert (List.length pa = 4);
  Printf.printf "✓ Functors (Ch3.5) passed\n"

(* ============================================================================
   Test: Coequalizer with union-find (Ch4.6)
   ============================================================================ *)
let test_coequalizer_uf () =
  let a = ['a'; 'b'] in
  let f = { sa_src = a; sa_fn = (fun x -> x); sa_tgt = a } in
  let g = { sa_src = a; sa_fn = (fun x -> if x = 'a' then 'b' else 'a'); sa_tgt = a } in
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
  let a = ['x'] in
  let b = ['x'] in
  let c = ['x'; 'y'] in
  let f = { sa_src = a; sa_fn = (fun x -> x); sa_tgt = b } in
  let g = { sa_src = a; sa_fn = (fun x -> x); sa_tgt = c } in
  let (pushout_obj, to_b, to_c) = Colimits.set_pushout f g in
  assert (List.length pushout_obj = 2);
  Printf.printf "✓ Pushout construction (Ch4.7) passed\n"

(* ============================================================================
   Test: Limits via duality (Ch4.9)
   ============================================================================ *)
let test_limits () =
  let tobj = set_terminal in
  assert (tobj.term_obj = [()]);
  let ((data, _)) = set_product ([1;2], [3;4]) in
  assert (List.length data.prod_obj = 4);
  let f = { sa_src = [1;2;3]; sa_fn = (fun x -> x); sa_tgt = [1;2;3] } in
  let g = { sa_src = [1;2;3]; sa_fn = (fun x -> 1); sa_tgt = [1;2;3] } in
  let (edata, _) = set_equalizer f g in
  assert (edata.eq_obj = [1]);
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