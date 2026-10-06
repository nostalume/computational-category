;; Test suite for the Computational Category Theory library
;; Organized by functionality across chapters.

(* ============================================================================
   Test: Core (Ch2 exercises)
   ============================================================================ *)
let test_core () =
  (* Natural numbers *)
  assert (Core.numprint Core.Zero = 0);
  assert (Core.numprint (Core.Succ Core.Zero) = 1);
  (* List processing *)
  assert (Core.sum_list [1;2;3;4] = 10);
  assert (Core.max_list [3;7;2;9] = 9);
  assert (Core.fold (fun a b -> a + b) 0 [1;2;3] = 6);
  assert (Core.poly [1;2;3] 2 = 17); (* 1 + 2*2 + 3*4 = 1+4+12 = 17 *)
  (* Free monoid homomorphism *)
  let add_monoid = { Core.op = (fun (a,b) -> a+b); Core.identity = 0 } in
  assert (Core.free_monoid_hom add_monoid (fun x -> x) [1;2;3;4] = 10);
  Printf.printf "✓ Core (Ch2) passed\n"

(* ============================================================================
   Test: Category type and duality (Ch3)
   ============================================================================ *)
let test_cat () =
  (* FinSet category *)
  let (Cat.Cat (s, t, i, c)) = Finite_sets.finset_cat in
  let a = [1;2] in
  let b = [3;4] in
  let f = Finite_sets.SetArrow (a, (fun x -> x + 2), b) in
  assert (Finite_sets.set_s f = a);
  assert (Finite_sets.set_t f = b);
  assert (Finite_sets.set_arrow_apply f 1 = 3);
  (* Dual category *)
  let (Cat.Cat (s', t', i', c')) = Cat.dual_cat Finite_sets.finset_cat in
  assert (s' f = b); (* source swapped with target *)
  assert (t' f = a);
  (* Finite category example *)
  let (Cat.Cat (fs, ft, fi, fc)) = Term_category.FiniteCategory.cat in
  assert (fs Term_category.FiniteCategory.F = Term_category.FiniteCategory.B);
  assert (ft Term_category.FiniteCategory.F = Term_category.FiniteCategory.A);
  Printf.printf "✓ Categories & duality (Ch3) passed\n"

(* ============================================================================
   Test: Finite sets (Ch2 Ex9, Ch3.4.1)
   ============================================================================ *)
let test_finite_sets () =
  assert (Finite_sets.seteq [1;2;3] [1;2;3]);
  assert (not (Finite_sets.seteq [1;2] [1;2;3]));
  assert (Finite_sets.seteq (Finite_sets.union [1;2] [2;3]) [1;2;3]);
  (* Cartesian product *)
  assert (Finite_sets.cartesian_prod [1;2] [3] = [(1,3);(2,3)]);
  (* Powerset *)
  assert (List.length (Finite_sets.powerset [1;2]) = 4);
  (* Disjoint union *)
  let du = Finite_sets.disjoint_union [1;2] [3] in
  assert (List.length du = 3);
  Printf.printf "✓ Finite sets passed\n"

(* ============================================================================
   Test: Functors (Ch3.5)
   ============================================================================ *)
let test_functors () =
  let (Functors.FFunctor (src, fo, fa, tgt)) = Functors.id_functor Finite_sets.finset_cat in
  let a = [1;2;3] in
  assert (fo a = a);
  (* Product functor *)
  let (Functors.FFunctor (_, xo, xa, _)) = Functors.product_functor in
  let pa = xo [1;2] in
  assert (List.length pa = 4); (* a × a = 4 elements *)
  Printf.printf "✓ Functors (Ch3.5) passed\n"

(* ============================================================================
   Test: Universal constructions (Ch4)
   ============================================================================ *)
let test_universal () =
  (* Initial object in FinSet *)
  let (obj, univ) : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.initial_obj = Colimits.set_initial in
  assert (obj = []);
  (* Binary coproduct *)
  let ((sumab, inj_a, inj_b), univ_cp) = Colimits.set_coproduct [1;2] [3] in
  assert (List.length sumab = 3);
  (* Coequalizer *)
  let f = Finite_sets.SetArrow ([1;2], (fun x -> x), [1;2]) in
  let g = Finite_sets.SetArrow ([1;2], (fun x -> 1), [1;2]) in
  let ((cobj, q), _) = Colimits.set_coequalizer f g in
  assert (cobj = [1]); (* coequalizes to single point *)
  Printf.printf "✓ Universal constructions (Ch4) passed\n"

(* ============================================================================
   Test: Limits via duality (Ch4.9)
   ============================================================================ *)
let test_limits () =
  (* Terminal object *)
  let (tobj, _) = Limits.set_terminal in
  assert (tobj = [Finite_sets.TTrue]);
  (* Product *)
  let ((prod, p1, p2), _) = Limits.set_product [1;2] [3;4] in
  assert (List.length prod = 4);
  (* Equalizer *)
  let f = Finite_sets.SetArrow ([1;2;3], (fun x -> x), [1;2;3]) in
  let g = Finite_sets.SetArrow ([1;2;3], (fun x -> 1), [1;2;3]) in
  let ((eobj, _), _) = Limits.set_equalizer f g in
  assert (eobj = [1]); (* only x where x = 1 *)
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
  test_universal ();
  test_limits ();
  Printf.printf "\nAll functional tests passed successfully! ✓\n"