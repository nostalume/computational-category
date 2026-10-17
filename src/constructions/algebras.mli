(* Algebras and algebra morphisms for one lawful, stable endofunctor
   [F : C -> C]. Constructors check endpoints and squares; global functor and
   universal laws remain caller premises. *)
(* An object equipped with a structure arrow [F(a) -> a]. *)
type ('o,'a) algebra
(* A commuting square between two algebra structures. *)
type ('o,'a) algebra_morphism
val carrier : ('o,'a) algebra -> 'o
val structure : ('o,'a) algebra -> 'a
val source : ('o,'a) algebra_morphism -> ('o,'a) algebra
val target : ('o,'a) algebra_morphism -> ('o,'a) algebra
val underlying : ('o,'a) algebra_morphism -> 'a
val algebra : ('o,'a,'o,'a) Foundations.Functor.cat_functor -> 'o -> 'a ->
  (('o,'a) algebra,Foundations.Category.error) result
val algebra_morphism : ('o,'a,'o,'a) Foundations.Functor.cat_functor -> ('o,'a) algebra ->
  'a -> ('o,'a) algebra -> (('o,'a) algebra_morphism,Foundations.Category.error) result
val category : ('o,'a,'o,'a) Foundations.Functor.cat_functor ->
  (('o,'a) algebra,('o,'a) algebra_morphism) Foundations.Category.cat
val forgetful : ('o,'a,'o,'a) Foundations.Functor.cat_functor ->
  (('o,'a) algebra,('o,'a) algebra_morphism,'o,'a) Foundations.Functor.cat_functor
(* Exercise 12: creates supplied finite limits; F need not preserve them. *)
val complete : ('o,'a,'o,'a) Foundations.Functor.cat_functor ->
  ('o,'a) Universal.Limits.complete_cat ->
  (('o,'a) algebra,('o,'a) algebra_morphism) Universal.Limits.complete_cat

module Free : sig
  (* Finite terminating cases only. Bound exhaustion is Iteration_limit; it
     never certifies a free algebra. Bounds do not limit supplier time/memory.
     All dictionaries/universals are coherent; coproduct requires lawful
     preservation (including initial objects). *)
  val coproduct : cocomplete:('o,'a) Universal.Limits.cocomplete_cat ->
    isomorphisms:('o,'a) Foundations.Category.iso_cat ->
    preserving:('o,'a,'o,'a) Universal.Preservation.cocontinuous_functor -> bound:int -> 'o ->
    ((('o,'a) algebra,('o,'a) algebra_morphism,'a) Universal.Adjunction.universal_arrow,Foundations.Category.error) result
  val initial_chain : cocomplete:('o,'a) Universal.Limits.cocomplete_cat ->
    isomorphisms:('o,'a) Foundations.Category.iso_cat -> bound:int ->
    ('o,'a,'o,'a) Foundations.Functor.cat_functor ->
    ((('o,'a) algebra,('o,'a) algebra_morphism) Universal.Limits.initial_obj,Foundations.Category.error) result
  val chain : cocomplete:('o,'a) Universal.Limits.cocomplete_cat ->
    isomorphisms:('o,'a) Foundations.Category.iso_cat -> bound:int ->
    ('o,'a,'o,'a) Foundations.Functor.cat_functor -> 'o ->
    ((('o,'a) algebra,('o,'a) algebra_morphism,'a) Universal.Adjunction.universal_arrow,Foundations.Category.error) result
  val pushout : cocomplete:('o,'a) Universal.Limits.cocomplete_cat ->
    isomorphisms:('o,'a) Foundations.Category.iso_cat -> bound:int ->
    ('o,'a,'o,'a) Foundations.Functor.cat_functor -> 'o ->
    ((('o,'a) algebra,('o,'a) algebra_morphism,'a) Universal.Adjunction.universal_arrow,Foundations.Category.error) result
end
