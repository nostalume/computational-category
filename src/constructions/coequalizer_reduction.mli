(* The pushout/coequalizer reduction used by the categorical unification
   derivation.  Arguments are ordered g after f, as in Foundations.Category. *)
val factorized_coequalizer :
  ('o,'a) Foundations.Category.cat ->
  ('o,'a) Universal.Limits.pushout ->
  ('o,'a) Universal.Limits.coequalizer ->
  g:'a -> factor:'a -> other:'a ->
  ('a, Foundations.Category.error) result
