(* ============================================================================
   Limits — terminal object, product, equalizer in FinSet (Ch4.8, Ch4.9).
   Layer 5: built on the layered core with named records.
   ============================================================================ *)

(* ============================================================================
   Terminal object in FinSet: singleton set {()}.
   ============================================================================ *)
let set_terminal : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.terminal_obj =
  let unit_set = Finite_sets.singleton () in
  let open Obj in
  { Universal.term_obj = unit_set;
    Universal.term_univ =
      (fun _ -> { Finite_sets.sa_src = Finite_sets.emptyset;
                  sa_fn = (fun _ -> Obj.magic ());
                  sa_tgt = unit_set }) }

(* ============================================================================
   Binary product in FinSet: cartesian product.
   Returns a Universal.product_data record with the two projections.
   ============================================================================ *)
let set_product_data (a : 'a Finite_sets.set) (b : 'a Finite_sets.set) :
    ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.product_data =
  let raw_cross = Finite_sets.cartesian_prod a b in
  let open Obj in
  let a_cross_b : 'a Finite_sets.set = Obj.magic raw_cross in
  { Universal.prod_obj = a_cross_b;
    prod_proj1 = { Finite_sets.sa_src = a_cross_b;
                   sa_fn = (fun p -> Obj.magic (match Obj.magic p with (x, _) -> x | _ -> raise (Failure "proj1")));
                   sa_tgt = a };
    prod_proj2 = { Finite_sets.sa_src = a_cross_b;
                   sa_fn = (fun p -> Obj.magic (match Obj.magic p with (_, y) -> y | _ -> raise (Failure "proj2")));
                   sa_tgt = b } }

(* Product as a Universal.product operator (data + universality) *)
let set_product (a, b) : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.product_data
    * ('a Finite_sets.set -> 'a Finite_sets.set_arrow -> 'a Finite_sets.set_arrow -> 'a Finite_sets.set_arrow) =
  let data = set_product_data a b in
  let univ c f1 f2 =
    let fa = Finite_sets.set_arrow_apply f1 in
    let fb = Finite_sets.set_arrow_apply f2 in
    { Finite_sets.sa_src = c;
      sa_fn = (fun y -> Obj.magic (fa y, fb y));
      sa_tgt = data.Universal.prod_obj }
  in
  (data, univ)

(* ============================================================================
   Equalizer in FinSet: subset of source where f = g.
   ============================================================================ *)
let set_equalizer (f : 'a Finite_sets.set_arrow) (g : 'a Finite_sets.set_arrow) :
    ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.equalizer_data
    * ('a Finite_sets.set -> 'a Finite_sets.set_arrow -> 'a Finite_sets.set_arrow) =
  let a = Finite_sets.set_s f in
  let e = List.filter (fun y -> Finite_sets.set_arrow_apply f y = Finite_sets.set_arrow_apply g y) a in
  let open Obj in
  let data = { Universal.eq_obj = e;
               eq_arrow = { Finite_sets.sa_src = e;
                            sa_fn = (fun x -> Obj.magic x);
                            sa_tgt = a } } in
  let univ c h =
    { Finite_sets.sa_src = c;
      sa_fn = (fun y -> Obj.magic (Finite_sets.set_arrow_apply h y));
      sa_tgt = e }
  in
  (data, univ)

(* ============================================================================
   Dual category of FinSet as an io/coproduct/coequalizer category.
   In the dual of FinSet:
     - initial      = terminal of FinSet
     - coproduct    = product of FinSet
     - coequalizer  = equalizer of FinSet
   ============================================================================ *)
let io_cp_ce_dual_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.io_cp_ce_cat =
  let terminal = set_terminal in
  let product (a, b) =
    let (data, univ) = set_product (a, b) in
    let cp = { Universal.coprod_obj = data.Universal.prod_obj;
               coprod_inj1 = data.Universal.prod_proj1;
               coprod_inj2 = data.Universal.prod_proj2 } in
    (cp, univ)
  in
  let equalizer (f, g) =
    let (data, univ) = set_equalizer f g in
    let coeq = { Universal.coeq_obj = data.Universal.eq_obj;
                 coeq_arrow = data.Universal.eq_arrow } in
    (coeq, univ)
  in
  { Universal.iocc_cat = Cat.dual_cat Finite_sets.finset_cat;
    iocc_initial = { Universal.init_obj = terminal.Universal.term_obj;
                     init_univ = terminal.Universal.term_univ };
    iocc_coproduct = product;
    iocc_coequalizer = equalizer }