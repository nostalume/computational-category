(* Uniform fiber representations only. Strict lawful indexing, stability,
   membership and natural inverse adjunction bijections are caller capabilities.
   Operations admit selected fiber endpoints and propagate capability errors. *)
module type INDEXED =
  sig
    type base_obj
    type base_arr
    type fiber_obj
    type fiber_arr
    val base : (base_obj, base_arr) Foundations.Category.cat
    val fiber :
      base_obj -> (fiber_obj, fiber_arr) Foundations.Category.cat
    val valid_object : base_obj -> fiber_obj -> bool
    val transport :
      base_arr ->
      ((fiber_obj, fiber_arr, fiber_obj, fiber_arr)
       Foundations.Functor.cat_functor,
       Foundations.Category.error)
      result
  end
module Make :
  functor (I : INDEXED) ->
    sig
      type obj
      type indexed_morphism
      val index : obj -> I.base_obj
      val value : obj -> I.fiber_obj
      val source : indexed_morphism -> obj
      val target : indexed_morphism -> obj
      val base_map : indexed_morphism -> I.base_arr
      val fiber_map : indexed_morphism -> I.fiber_arr
      val object_ :
        I.base_obj ->
        I.fiber_obj -> (obj, Foundations.Category.error) result
      val equal_object : obj -> obj -> bool
      val indexed_morphism :
        obj ->
        I.base_arr ->
        I.fiber_arr ->
        obj -> (indexed_morphism, Foundations.Category.error) result
      val category : (obj, indexed_morphism) Foundations.Category.cat
      val projection :
        (obj, indexed_morphism, I.base_obj, I.base_arr)
        Foundations.Functor.cat_functor
      val cocomplete :
        (I.base_obj, I.base_arr) Universal.Limits.cocomplete_cat ->
        (I.base_obj ->
         (I.fiber_obj, I.fiber_arr)
         Universal.Limits.cocomplete_cat) ->
        (I.base_arr ->
         (I.fiber_obj, I.fiber_arr)
         Universal.Limits.colimiting_cocone ->
         ((I.fiber_obj, I.fiber_arr)
          Universal.Limits.colimiting_cocone,
          Foundations.Category.error)
         result) ->
        (obj, indexed_morphism) Universal.Limits.cocomplete_cat
      type right_adjoint = {
        right :
          (I.fiber_obj, I.fiber_arr, I.fiber_obj, I.fiber_arr)
          Foundations.Functor.cat_functor;
        to_right :
          I.fiber_obj ->
          I.fiber_obj ->
          I.fiber_arr ->
          (I.fiber_arr, Foundations.Category.error) result;
        from_right :
          I.fiber_obj ->
          I.fiber_obj ->
          I.fiber_arr ->
          (I.fiber_arr, Foundations.Category.error) result;
      }
      val transpose :
        I.base_arr ->
        right_adjoint ->
        I.fiber_obj ->
        I.fiber_obj ->
        I.fiber_arr -> (I.fiber_arr, Foundations.Category.error) result
      val untranspose :
        I.base_arr ->
        right_adjoint ->
        I.fiber_obj ->
        I.fiber_obj ->
        I.fiber_arr -> (I.fiber_arr, Foundations.Category.error) result
      val complete :
        (I.base_obj, I.base_arr) Universal.Limits.complete_cat ->
        (I.base_obj ->
         (I.fiber_obj, I.fiber_arr)
         Universal.Limits.complete_cat) ->
        (I.base_arr ->
         (right_adjoint, Foundations.Category.error) result) ->
        (obj, indexed_morphism) Universal.Limits.complete_cat
    end
