(* All values belong to the same stable lawful pair L,R with coherent common
   codomain. Constructors admit endpoints and commuting squares; no closure
   equality or automatic proof of functor/preservation laws is performed. *)
type ('oa, 'ac, 'ob) obj
type ('oa, 'aa, 'ac, 'ob, 'ab) arrow
val left_object : ('a, 'b, 'c) obj -> 'a
val right_object : ('a, 'b, 'c) obj -> 'c
val connecting_arrow : ('a, 'b, 'c) obj -> 'b
val source : ('a, 'b, 'c, 'd, 'e) arrow -> ('a, 'c, 'd) obj
val target : ('a, 'b, 'c, 'd, 'e) arrow -> ('a, 'c, 'd) obj
val left_arrow : ('a, 'b, 'c, 'd, 'e) arrow -> 'b
val right_arrow : ('a, 'b, 'c, 'd, 'e) arrow -> 'e
val object_ :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  'a ->
  'd -> 'e -> (('a, 'd, 'e) obj, Foundations.Category.error) result
val equal_object :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  ('a, 'd, 'e) obj -> ('a, 'd, 'e) obj -> bool
val arrow :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  ('a, 'd, 'e) obj ->
  'b * 'f ->
  ('a, 'd, 'e) obj ->
  (('a, 'b, 'd, 'e, 'f) arrow, Foundations.Category.error) result
val category :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  (('a, 'd, 'e) obj, ('a, 'b, 'd, 'e, 'f) arrow)
  Foundations.Category.cat
val left_projection :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  (('a, 'd, 'e) obj, ('a, 'b, 'd, 'e, 'f) arrow, 'a, 'b)
  Foundations.Functor.cat_functor
val right_projection :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  (('a, 'd, 'e) obj, ('a, 'b, 'd, 'e, 'f) arrow, 'e, 'f)
  Foundations.Functor.cat_functor
val colimit_with_projections :
  ('a, 'b) Universal.Limits.cocomplete_cat ->
  ('c, 'd) Universal.Limits.cocomplete_cat ->
  ('a, 'b, 'e, 'f) Universal.Preservation.cocontinuous_functor ->
  ('c, 'd, 'e, 'f) Foundations.Functor.cat_functor ->
  (('a, 'f, 'c) obj, ('a, 'b, 'f, 'c, 'd) arrow)
  Universal.Diagrams.diagram ->
  ((('a, 'f, 'c) obj, ('a, 'b, 'f, 'c, 'd) arrow)
   Universal.Limits.colimiting_cocone *
   ('a, 'b) Universal.Limits.colimiting_cocone *
   ('c, 'd) Universal.Limits.colimiting_cocone,
   Foundations.Category.error)
  result
val cocomplete :
  ('a, 'b) Universal.Limits.cocomplete_cat ->
  ('c, 'd) Universal.Limits.cocomplete_cat ->
  ('a, 'b, 'e, 'f) Universal.Preservation.cocontinuous_functor ->
  ('c, 'd, 'e, 'f) Foundations.Functor.cat_functor ->
  (('a, 'f, 'c) obj, ('a, 'b, 'f, 'c, 'd) arrow)
  Universal.Limits.cocomplete_cat
val swap_object : ('a, 'b, 'c) obj -> ('c, 'b, 'a) obj
val swap_arrow : ('a, 'b, 'c, 'd, 'e) arrow -> ('d, 'e, 'c, 'a, 'b) arrow
val dual_to_swapped :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  (('a, 'd, 'e) obj, ('a, 'b, 'd, 'e, 'f) arrow, ('e, 'd, 'a) obj,
   ('e, 'f, 'd, 'a, 'b) arrow)
  Foundations.Functor.cat_functor
val swapped_to_dual :
  ('a, 'b, 'c, 'd) Foundations.Functor.cat_functor ->
  ('e, 'f, 'c, 'd) Foundations.Functor.cat_functor ->
  (('e, 'd, 'a) obj, ('e, 'f, 'd, 'a, 'b) arrow, ('a, 'd, 'e) obj,
   ('a, 'b, 'd, 'e, 'f) arrow)
  Foundations.Functor.cat_functor
val complete :
  ('a, 'b) Universal.Limits.complete_cat ->
  ('c, 'd) Universal.Limits.complete_cat ->
  ('a, 'b, 'e, 'f) Foundations.Functor.cat_functor ->
  ('c, 'd, 'e, 'f) Universal.Preservation.continuous_functor ->
  (('a, 'f, 'c) obj, ('a, 'b, 'f, 'c, 'd) arrow)
  Universal.Limits.complete_cat
val coslice_coproduct :
  ('a, 'b) Foundations.Category.cat ->
  ('c, 'd) Universal.Limits.cocomplete_cat ->
  'c ->
  ('a, 'd, 'c) obj * ('a, 'd, 'c) obj ->
  ((('a, 'd, 'c) obj, ('a, 'b, 'd, 'c, 'd) arrow)
   Universal.Limits.coproduct_data *
   (('a, 'd, 'c) obj ->
    ('a, 'b, 'd, 'c, 'd) arrow ->
    ('a, 'b, 'd, 'c, 'd) arrow ->
    (('a, 'b, 'd, 'c, 'd) arrow, Foundations.Category.error) result),
   Foundations.Category.error)
  result
