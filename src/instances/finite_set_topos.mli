(** The finite-set topos is a concrete, terminating model of Chapter 7. Its
    function values are library-owned tagged graphs; tags are chosen fresh from
    admitted domain/codomain values for each exponential. *)
module Make (F : Finite_sets.S) : sig
  type power_object = { power_obj : F.carrier; membership : F.morphism }

  val truth_value : bool -> F.value
  val is_true : F.value -> bool
  val function_space : F.carrier -> F.carrier -> (F.carrier, Foundations.Category.error) result
  val evaluate_function : F.carrier -> F.carrier -> F.value -> F.value ->
    (F.value, Foundations.Category.error) result
  val exponential : (F.carrier,F.morphism) Universal.Closed.exponential
  val closed : (F.carrier,F.morphism) Universal.Closed.cartesian_closed
  val topos : (F.carrier,F.morphism) Universal.Topos.topos
  val power_object : F.carrier -> (power_object, Foundations.Category.error) result
  val exists : F.carrier -> (F.morphism, Foundations.Category.error) result
end
