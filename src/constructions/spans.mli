(** A witness object with two legs sharing one source. *)
type ('o, 'a) span
(* Admit a span after checking both legs in one category. *)
val span :
  ('o, 'a) Foundations.Category.cat -> 'a -> 'a -> (('o, 'a) span, Foundations.Category.error) result
val span_source : ('o, 'a) span -> 'o
val span_left : ('o, 'a) span -> 'a
val span_right : ('o, 'a) span -> 'a

(* All spans and the complete-category capability must use a coherent lawful
   dictionary. Composition is next after previous, not tuple enumeration order;
   its pullback carrier preserves distinct compatible witness pairs. *)
val identity : ('o, 'a) Foundations.Category.cat -> 'o -> ('o, 'a) span
val compose :
  ('o, 'a) Universal.Limits.complete_cat -> ('o, 'a) span -> ('o, 'a) span ->
  (('o, 'a) span, Foundations.Category.error) result

