(* ============================================================================
   Universal Constructions — initial/terminal objects, coproducts/products,
   coequalizers/equalizers, pushouts/pullbacks (Ch4.2, Ch4.8, Ch4.9).
   Layer 2: each construction is a named record carrying its universality.
   ============================================================================ *)

(* Initial object: object + universal arrow to any object *)
type ('o, 'a) initial_obj = {
  init_obj : 'o;
  init_univ : 'o -> 'a;
}

(* Terminal object (dual of initial) *)
type ('o, 'a) terminal_obj = {
  term_obj : 'o;
  term_univ : 'o -> 'a;
}

(* Binary coproduct: objects a b -> (coproduct data, universality) *)
type ('o, 'a) coproduct_data = {
  coprod_obj : 'o;
  coprod_inj1 : 'a;
  coprod_inj2 : 'a;
}

(* coproduct operator: a b -> (data, univ)
   univ: c f g -> unique [f,g] : coprod -> c *)
type ('o, 'a) coproduct =
  'o * 'o ->
  (('o, 'a) coproduct_data * ('o -> 'a -> 'a -> 'a))

(* Binary product (dual of coproduct) *)
type ('o, 'a) product_data = {
  prod_obj : 'o;
  prod_proj1 : 'a;
  prod_proj2 : 'a;
}

type ('o, 'a) product =
  'o * 'o ->
  (('o, 'a) product_data * ('o -> 'a -> 'a -> 'a))

(* Coequalizer of parallel pair *)
type ('o, 'a) coequalizer_data = {
  coeq_obj : 'o;
  coeq_arrow : 'a;
}

type ('o, 'a) coequalizer =
  'a * 'a ->
  (('o, 'a) coequalizer_data * ('o -> 'a -> 'a))

(* Equalizer (dual of coequalizer) *)
type ('o, 'a) equalizer_data = {
  eq_obj : 'o;
  eq_arrow : 'a;
}

type ('o, 'a) equalizer =
  'a * 'a ->
  (('o, 'a) equalizer_data * ('o -> 'a -> 'a))

(* A category with initial object, binary coproducts, coequalizers *)
type ('o, 'a) io_cp_ce_cat = {
  iocc_cat : ('o, 'a) Cat.cat;
  iocc_initial : ('o, 'a) initial_obj;
  iocc_coproduct : ('o, 'a) coproduct;
  iocc_coequalizer : ('o, 'a) coequalizer;
}

(* ============================================================================
   Isomorphism between two initial objects (Ch4.2.1)
   ============================================================================ *)
let iso_initial (a : ('o, 'a) initial_obj) (a' : ('o, 'a) initial_obj) =
  (a.init_univ a'.init_obj, a'.init_univ a.init_obj)