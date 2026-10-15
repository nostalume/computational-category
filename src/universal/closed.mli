(* Exponentials are universal choices for the adjunction (-) x a |- (-)^a.
   The product and category laws are supplied by the caller; this record only
   owns the exponential object, evaluation arrow and currying operation. *)
type ('o,'a) exponential = {
  exponential_object : 'o -> 'o -> ('o, Foundations.Category.error) result;
  eval : 'o -> 'o -> 'o -> ('a, Foundations.Category.error) result;
  curry : 'o -> 'o -> 'o -> 'a -> ('a, Foundations.Category.error) result;
}

type ('o,'a) cartesian_closed = {
  cc_cat : ('o,'a) Foundations.Category.cat;
  cc_complete : ('o,'a) Limits.complete_cat;
  cc_exponential : ('o,'a) exponential;
}
