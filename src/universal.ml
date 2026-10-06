(* ============================================================================
   Universal Constructions — initial/terminal objects, coproducts/products,
   coequalizers/equalizers, pushouts/pullbacks (Ch4.2, Ch4.8, Ch4.9).
   ============================================================================ *)

(* ============================================================================
   Types for universal constructions.
   Each pairs a structure with its universality (functional representation).
   ============================================================================ *)

(* Initial object: object + universal arrow to any object *)
type ('o, 'a) initial_obj = 'o * ('o -> 'a)

(* Terminal object (dual of initial) *)
type ('o, 'a) terminal_obj = 'o * ('o -> 'a)

(* Binary coproduct: objects a b -> (coproduct object, 2 injection arrows, universality) *)
type ('o, 'a) coproduct =
  'o * 'o ->
  (('o * 'a * 'a) * ('o * 'a * 'a -> 'a))

(* Binary product (dual of coproduct) *)
type ('o, 'a) product =
  'o * 'o ->
  (('o * 'a * 'a) * ('o * 'a * 'a -> 'a))

(* Coequalizer of parallel pair *)
type ('o, 'a) coequalizer =
  'a * 'a ->
  (('o * 'a) * ('o * 'a -> 'a))

(* Equalizer (dual of coequalizer) *)
type ('o, 'a) equalizer =
  'a * 'a ->
  (('o * 'a) * ('o * 'a -> 'a))

(* Pushout: two arrows with common source -> (pair of arrows, universality) *)
type ('o, 'a) pushout =
  'a * 'a ->
  (('a * 'a) * ('a * 'a -> 'a))

(* Pullback (dual of pushout) *)
type ('o, 'a) pullback =
  'a * 'a ->
  (('a * 'a) * ('a * 'a -> 'a))

(* A category with initial object, binary coproducts, coequalizers *)
type ('o, 'a) io_cp_ce_cat = Io_cp_ce_cat of
  ('o, 'a) Cat.cat *
  ('o, 'a) initial_obj *
  ('o, 'a) coproduct *
  ('o, 'a) coequalizer

(* ============================================================================
   Isomorphism between two initial objects (Ch4.2.1)
   ============================================================================ *)
let iso_initial ((a, univ_a) : ('o, 'a) initial_obj) ((a', univ_a') : ('o, 'a) initial_obj) =
  (univ_a a', univ_a' a)