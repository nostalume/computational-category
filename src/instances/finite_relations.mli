module Make (F : Finite_sets.S) : sig
  (* Each carrier member is an outer Pair whose components belong to the
     supplied endpoint sets. Empty carriers still retain those endpoints. *)
  val relation_span :
    left:F.set -> right:F.set -> F.set -> ((F.set, F.arrow) Constructions.Spans.span, Foundations.Category.error) result
  (* Deduplicate endpoint pairs without changing the original witness carrier. *)
  val image : (F.set, F.arrow) Constructions.Spans.span -> (F.set, Foundations.Category.error) result
end
