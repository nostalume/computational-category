(* A finite slice topos Set/B.  The anchor B is fixed for one instance; all
   constructions are computed fibrewise and return checked slice arrows. *)
module Make (F : Finite_sets.S) : sig
  type slice_object
  type slice_morphism
  val object_ : F.carrier -> F.carrier -> F.morphism ->
    (slice_object, Foundations.Category.error) result
  val total : slice_object -> F.carrier
  val projection : slice_object -> F.morphism
  val source : slice_morphism -> slice_object
  val target : slice_morphism -> slice_object
  val map : slice_morphism -> F.morphism
  val morphism : slice_object -> F.morphism -> slice_object ->
    (slice_morphism, Foundations.Category.error) result
  val category : F.carrier -> (slice_object, slice_morphism) Foundations.Category.cat
  type product_data = {
    product : slice_object;
    left : slice_morphism;
    right : slice_morphism;
  }
  val terminal : F.carrier -> (slice_object, Foundations.Category.error) result
  val product : F.carrier -> slice_object -> slice_object ->
    (product_data, Foundations.Category.error) result
  type exponential_data = {
    exponential : slice_object;
    evaluation : slice_morphism;
    curry : slice_object -> slice_morphism ->
      (slice_morphism, Foundations.Category.error) result;
  }
  val exponential : F.carrier -> slice_object -> slice_object ->
    (exponential_data, Foundations.Category.error) result
  type classifier = {
    omega : slice_object;
    truth : slice_morphism;
    character : slice_morphism ->
      (slice_morphism, Foundations.Category.error) result;
  }
  val classifier : F.carrier -> (classifier, Foundations.Category.error) result
end
