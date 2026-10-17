(** Pointwise finite-set exponentials and classifiers for a discrete finite
    source category. *)
module Make (F : Finite_sets.S) : sig
  type ('o,'a) object_ =
    ('o,'a,F.carrier,F.morphism) Constructions.Functor_category.finite_functor
  type ('o,'a) morphism =
    ('o,'a,F.carrier,F.morphism) Constructions.Functor_category.natural_transformation
  val ensure_discrete : ('o,'a) Constructions.Functor_category.domain ->
    (unit, Foundations.Category.error) result
  type ('o,'a) exponential = {
    object_ : ('o,'a) object_;
    evaluation : ('o,'a) morphism;
    curry : ('o,'a) object_ -> ('o,'a) morphism ->
      (('o,'a) morphism, Foundations.Category.error) result;
  }
  val exponential : ('o,'a) Constructions.Functor_category.domain ->
    ('o,'a) object_ -> ('o,'a) object_ ->
    (('o,'a) exponential, Foundations.Category.error) result
  type ('o,'a) classifier = {
    omega : ('o,'a) object_;
    truth : ('o,'a) morphism;
    character : ('o,'a) morphism ->
      (('o,'a) morphism, Foundations.Category.error) result;
  }
  val classifier : ('o,'a) Constructions.Functor_category.domain ->
    (('o,'a) classifier, Foundations.Category.error) result
end
