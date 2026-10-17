(** Relations represented by endpoint-preserving witness spans. *)
module Make (F : Finite_sets.S) : sig
  (* Each carrier member is an outer Pair whose components belong to the
     supplied endpoint sets. Empty carriers still retain those endpoints. *)
  val relation_span :
    left:F.carrier -> right:F.carrier -> F.carrier -> ((F.carrier, F.morphism) Constructions.Spans.span, Foundations.Category.error) result
  (* Deduplicate endpoint pairs without changing the original witness carrier. *)
  val image : (F.carrier, F.morphism) Constructions.Spans.span -> (F.carrier, Foundations.Category.error) result
end
