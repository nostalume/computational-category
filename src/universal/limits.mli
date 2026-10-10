open Foundations.Category
open Diagrams
(* Primitive universal capability contracts. Semantic failures use Foundations.Category.error;
   supplied categories and capabilities remain lawful caller premises. *)
type ('o, 'a) initial_obj = {
  init_obj : 'o;
  init_univ : 'o -> ('a, Foundations.Category.error) result;
}
type ('o, 'a) terminal_obj = {
  term_obj : 'o;
  term_univ : 'o -> ('a, Foundations.Category.error) result;
}
type ('o, 'a) coproduct_data = {
  coprod_obj : 'o; coprod_inj1 : 'a; coprod_inj2 : 'a;
}
type ('o, 'a) coproduct =
  'o * 'o ->
  (('o, 'a) coproduct_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) product_data = {
  prod_obj : 'o; prod_proj1 : 'a; prod_proj2 : 'a;
}
type ('o, 'a) product =
  'o * 'o ->
  (('o, 'a) product_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) coequalizer_data = { coeq_obj : 'o; coeq_arrow : 'a }
type ('o, 'a) coequalizer =
  'a * 'a ->
  (('o, 'a) coequalizer_data *
   ('o -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) equalizer_data = { eq_obj : 'o; eq_arrow : 'a }
type ('o, 'a) equalizer =
  'a * 'a ->
  (('o, 'a) equalizer_data *
   ('o -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) pushout_data = {
  pushout_obj : 'o; pushout_leg1 : 'a; pushout_leg2 : 'a;
}
type ('o, 'a) pushout =
  'a * 'a ->
  (('o, 'a) pushout_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) pullback_data = {
  pullback_obj : 'o; pullback_proj1 : 'a; pullback_proj2 : 'a;
}
type ('o, 'a) pullback =
  'a * 'a ->
  (('o, 'a) pullback_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) io_cp_ce_cat = {
  iocc_cat : ('o, 'a) Foundations.Category.cat;
  iocc_initial : ('o, 'a) initial_obj;
  iocc_coproduct : ('o, 'a) coproduct;
  iocc_coequalizer : ('o, 'a) coequalizer;
}

val iso_initial : ('o,'a) initial_obj -> ('o,'b) initial_obj ->
  (('a * 'b),Foundations.Category.error) result
type ('o, 'a) colimiting_cocone = {
  colim_cocone : ('o, 'a) cocone;
  colim_univ : ('o, 'a) cocone ->
    (('o, 'a) cocone_arrow, Foundations.Category.error) result;
}
type ('o, 'a) colimit =
  ('o, 'a) diagram -> (('o, 'a) colimiting_cocone, Foundations.Category.error) result
type ('o, 'a) cocomplete_cat = {
  cc_cat : ('o, 'a) Foundations.Category.cat; cc_colimit : ('o, 'a) colimit;
}
type ('o, 'a) limiting_cone = {
  lim_cone : ('o, 'a) cone;
  lim_univ : ('o, 'a) cone -> (('o, 'a) cone_arrow, Foundations.Category.error) result;
}
type ('o, 'a) limit =
  ('o, 'a) diagram -> (('o, 'a) limiting_cone, Foundations.Category.error) result
type ('o, 'a) complete_cat = {
  co_cat : ('o, 'a) Foundations.Category.cat; co_limit : ('o, 'a) limit;
}

(* Primitive bundles and diagram dictionaries must describe the same lawful
   category. Recursion removes one node or edge; no concrete universe is used. *)
val finite_colimit : ('o, 'a) io_cp_ce_cat -> ('o, 'a) colimit
(* Conjugation: the supplied capability belongs to the opposite category of
   the input diagram. Graph endpoints and universal-arrow direction reverse. *)
val dual_colimit : ('o, 'a) colimit -> ('o, 'a) limit
val dual_limit : ('o, 'a) limit -> ('o, 'a) colimit
val pushout : ('o, 'a) cocomplete_cat -> ('o, 'a) pushout
val pullback : ('o, 'a) complete_cat -> ('o, 'a) pullback

(* Fixed labelled shape and coherent dictionary are caller premises for the
   category dictionaries. Builders still check endpoints and every square. *)
val map_colimit : ('o,'a) diagram_arrow -> ('o,'a) colimiting_cocone ->
  ('o,'a) colimiting_cocone -> (('o,'a) cocone_map,Foundations.Category.error) result
val map_limit : ('o,'a) diagram_arrow -> ('o,'a) limiting_cone ->
  ('o,'a) limiting_cone -> (('o,'a) cone_map,Foundations.Category.error) result
val coproduct : ('o,'a) cocomplete_cat -> ('o,'a) coproduct
val product : ('o,'a) complete_cat -> ('o,'a) product

val dual_colimiting : ('o,'a) colimiting_cocone -> ('o,'a) limiting_cone
val dual_limiting : ('o,'a) limiting_cone -> ('o,'a) colimiting_cocone
module Free : sig
type ('d,'da,'c,'ca) colimit_structure = {
  diagrams:('d,'da) cat;cocones:('c,'ca) cat;
  base_object:'c -> 'd;base_arrow:'ca -> 'da;
  free:'d -> ('c * 'da * ('c -> 'da -> ('ca,error) result),error) result;
}

val fixed_colimit : ('o,'a) Foundations.Category.cat -> Diagrams.graph -> ('o,'a) colimit ->
  (('o,'a) Diagrams.diagram,('o,'a) Diagrams.diagram_arrow,
   ('o,'a) Diagrams.cocone,('o,'a) Diagrams.cocone_map) colimit_structure
end
module Cofree : sig
type ('d,'da,'c,'ca) limit_structure = {
  limit_diagrams:('d,'da) cat;cones:('c,'ca) cat;
  cone_base:'c -> 'd;cone_base_arrow:'ca -> 'da;
  cofree:'d -> ('c * 'da * ('c -> 'da -> ('ca,error) result),error) result;
}

val fixed_limit : ('o,'a) Foundations.Category.cat -> Diagrams.graph -> ('o,'a) limit ->
  (('o,'a) Diagrams.diagram,('o,'a) Diagrams.diagram_arrow,
   ('o,'a) Diagrams.cone,('o,'a) Diagrams.cone_map) limit_structure
end
