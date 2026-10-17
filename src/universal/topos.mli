(** A subobject classifier and its truth arrow. *)
type ('o,'a) classifier = {
  omega : 'o;
  truth : 'a;
  character : 'a -> ('a, Foundations.Category.error) result;
}

(** The finite categorical capabilities required by a topos instance. *)
type ('o,'a) topos = {
  topos_cat : ('o,'a) Foundations.Category.cat;
  topos_initial : ('o,'a) Limits.initial_obj;
  topos_terminal : ('o,'a) Limits.terminal_obj;
  topos_complete : ('o,'a) Limits.complete_cat;
  topos_cocomplete : ('o,'a) Limits.cocomplete_cat;
  topos_product : ('o,'a) Limits.product;
  topos_coproduct : ('o,'a) Limits.coproduct;
  topos_equalizer : ('o,'a) Limits.equalizer;
  topos_pushout : ('o,'a) Limits.pushout;
  topos_closed : ('o,'a) Closed.cartesian_closed;
  topos_classifier : ('o,'a) classifier;
}

val true_ : ('o,'a) topos -> 'o -> ('a, Foundations.Category.error) result
val character : ('o,'a) topos -> 'a -> ('a, Foundations.Category.error) result
val name : ('o,'a) topos -> 'a -> ('a, Foundations.Category.error) result
val factorize : ('o,'a) topos -> 'a -> (('a * 'a), Foundations.Category.error) result
val false_ : ('o,'a) topos -> ('a, Foundations.Category.error) result
val not_ : ('o,'a) topos -> ('a, Foundations.Category.error) result
val and_ : ('o,'a) topos -> ('a, Foundations.Category.error) result
val or_ : ('o,'a) topos -> ('a, Foundations.Category.error) result
val imply_ : ('o,'a) topos -> ('a, Foundations.Category.error) result
val for_all : ('o,'a) topos -> 'o -> ('a, Foundations.Category.error) result
