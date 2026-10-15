(* F:B->A is left adjoint to G:A->B. Constructors package lawful, stable
   capabilities, not global proofs. Universal uniqueness, functor/naturality
   laws and coherent dictionaries remain premises. Operations check selected
   endpoints and factor triangles; errors/exceptions propagate unchanged. *)
type ('oa,'aa,'ab) universal_arrow = {
  free_object : 'oa;
  unit_arrow : 'ab;
  factor : 'oa -> 'ab -> ('aa,Foundations.Category.error) result;
}
type ('ob,'ab,'oa,'aa) adjunction
val left : ('b,'bb,'a,'aa) adjunction -> ('b,'bb,'a,'aa) Foundations.Functor.cat_functor
val right : ('b,'bb,'a,'aa) adjunction -> ('a,'aa,'b,'bb) Foundations.Functor.cat_functor
val of_universal :
  right:('a,'aa,'b,'bb) Foundations.Functor.cat_functor ->
  ('b -> (('a,'aa,'bb) universal_arrow,Foundations.Category.error) result) ->
  ('b,'bb,'a,'aa) adjunction
val of_unit_counit :
  left:('b,'bb,'a,'aa) Foundations.Functor.cat_functor ->
  right:('a,'aa,'b,'bb) Foundations.Functor.cat_functor ->
  unit:('b -> ('bb,Foundations.Category.error) result) ->
  counit:('a -> ('aa,Foundations.Category.error) result) -> ('b,'bb,'a,'aa) adjunction
val universal : ('b,'bb,'a,'aa) adjunction -> 'b ->
  (('a,'aa,'bb) universal_arrow,Foundations.Category.error) result
val unit : ('b,'bb,'a,'aa) adjunction -> ('b,'bb,'b,'bb) Foundations.Functor.natural
val counit : ('b,'bb,'a,'aa) adjunction -> ('a,'aa,'a,'aa) Foundations.Functor.natural
(* b->G(a) to F(b)->a, and the reverse. *)
val transpose : ('b,'bb,'a,'aa) adjunction -> 'b -> 'a -> 'bb -> ('aa,Foundations.Category.error) result
val untranspose : ('b,'bb,'a,'aa) adjunction -> 'b -> 'a -> 'aa -> ('bb,Foundations.Category.error) result
val check_triangles : ('b,'bb,'a,'aa) adjunction -> 'b -> 'a -> (unit,Foundations.Category.error) result
val identity : ('o,'a) Foundations.Category.cat -> ('o,'a,'o,'a) adjunction
val dual : ('b,'bb,'a,'aa) adjunction -> ('a,'aa,'b,'bb) adjunction
(* Exercise 10: mates (conjugate natural transformations). For
   alpha:F=>F' the result is beta:G'=>G; the two operations are inverse under
   the supplied adjunction laws. *)
val mate_left : ('b,'bb,'a,'aa) adjunction -> ('b,'bb,'a,'aa) adjunction ->
  ('b,'bb,'a,'aa) Foundations.Functor.natural ->
  ('a,'aa,'b,'bb) Foundations.Functor.natural
val mate_right : ('b,'bb,'a,'aa) adjunction -> ('b,'bb,'a,'aa) adjunction ->
  ('a,'aa,'b,'bb) Foundations.Functor.natural ->
  ('b,'bb,'a,'aa) Foundations.Functor.natural
val check_conjugate : ('b,'bb,'a,'aa) adjunction -> ('b,'bb,'a,'aa) adjunction ->
  ('b,'bb,'a,'aa) Foundations.Functor.natural ->
  ('a,'aa,'b,'bb) Foundations.Functor.natural -> 'b ->
  (unit,Foundations.Category.error) result
val compose : ('b,'bb,'a,'aa) adjunction -> ('c,'cc,'b,'bb) adjunction ->
  ('c,'cc,'a,'aa) adjunction
