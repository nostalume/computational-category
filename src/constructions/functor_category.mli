(* A complete enumeration of the intended finite source category/subcategory
   is a caller premise. Admission checks closure and laws over that enumeration.
   Codomain dictionaries must be lawful/coherent. Values/callbacks are stable;
   each successful map/component admission samples exactly once per key. *)
type ('o, 'a) domain
val finite_domain :
  ('a, 'b) Foundations.Category.cat ->
  objects:'a list ->
  arrows:'b list ->
  (('a, 'b) domain, Foundations.Category.error) result
val objects : ('a, 'b) domain -> 'a list
val arrows : ('a, 'b) domain -> 'b list
val domain_category :
  ('a, 'b) domain -> ('a, 'b) Foundations.Category.cat
type ('oa, 'aa, 'ob, 'ab) functor_
val object_map :
  ('a, 'b, 'c, 'd) functor_ ->
  'a -> ('c, Foundations.Category.error) result
val arrow_map :
  ('a, 'b, 'c, 'd) functor_ ->
  'b -> ('d, Foundations.Category.error) result
val equal_functor :
  ('a, 'b, 'c, 'd) functor_ -> ('a, 'b, 'c, 'd) functor_ -> bool
val functor_ :
  ('a, 'b) domain ->
  ('c, 'd) Foundations.Category.cat ->
  objects:('a -> ('c, Foundations.Category.error) result) ->
  arrows:('b -> ('d, Foundations.Category.error) result) ->
  (('a, 'b, 'c, 'd) functor_, Foundations.Category.error) result
val identity_functor : ('a, 'b) domain -> ('a, 'b, 'a, 'b) functor_
val constant_functor :
  ('a, 'b) domain ->
  ('c, 'd) Foundations.Category.cat ->
  'c -> (('a, 'b, 'c, 'd) functor_, Foundations.Category.error) result
type ('oa, 'aa, 'ob, 'ab) natural
val source : ('a, 'b, 'c, 'd) natural -> ('a, 'b, 'c, 'd) functor_
val target : ('a, 'b, 'c, 'd) natural -> ('a, 'b, 'c, 'd) functor_
val component :
  ('a, 'b, 'c, 'd) natural ->
  'a -> ('d, Foundations.Category.error) result
val natural :
  ('a, 'b, 'c, 'd) functor_ ->
  ('a, 'b, 'c, 'd) functor_ ->
  ('a -> ('d, Foundations.Category.error) result) ->
  (('a, 'b, 'c, 'd) natural, Foundations.Category.error) result
val equal_natural :
  ('a, 'b, 'c, 'd) natural -> ('a, 'b, 'c, 'd) natural -> bool
val category :
  ('a, 'b) domain ->
  ('c, 'd) Foundations.Category.cat ->
  (('a, 'b, 'c, 'd) functor_, ('a, 'b, 'c, 'd) natural)
  Foundations.Category.cat
val compose_functors :
  ('a, 'b, 'c, 'd) functor_ ->
  ('e, 'f, 'a, 'b) functor_ ->
  (('e, 'f, 'c, 'd) functor_, Foundations.Category.error) result
val diagonal : ('a,'b) domain -> ('c,'d) Foundations.Category.cat ->
  ('c,'d,('a,'b,'c,'d) functor_,('a,'b,'c,'d) natural) Foundations.Functor.cat_functor
val horizontal :
  ('a, 'b, 'c, 'd) natural ->
  ('e, 'f, 'a, 'b) natural ->
  (('e, 'f, 'c, 'd) natural, Foundations.Category.error) result
val dual_domain : ('a, 'b) domain -> ('a, 'b) domain
val dual_functor : ('a, 'b, 'c, 'd) functor_ -> ('a, 'b, 'c, 'd) functor_
val dual_natural : ('a, 'b, 'c, 'd) natural -> ('a, 'b, 'c, 'd) natural
val cocomplete :
  ('a, 'b) domain ->
  ('c, 'd) Universal.Limits.cocomplete_cat ->
  (('a, 'b, 'c, 'd) functor_, ('a, 'b, 'c, 'd) natural)
  Universal.Limits.cocomplete_cat
val complete :
  ('a, 'b) domain ->
  ('c, 'd) Universal.Limits.complete_cat ->
  (('a, 'b, 'c, 'd) functor_, ('a, 'b, 'c, 'd) natural)
  Universal.Limits.complete_cat
