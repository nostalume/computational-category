(** Generalized theory presentations. Logic, sentence transport, and closure
    are supplied by a backend; this layer does not assume equations, models, or
    finite sentence sets. *)
module type LOGIC = sig
  (** The abstract logic capability used by presentations. *)
  type signature
  type signature_arrow
  type sentence
  type constraint_expr

  val signature_category :
    (signature, signature_arrow) Foundations.Category.cat
  val equal_constraints : constraint_expr -> constraint_expr -> bool
  val empty : signature -> constraint_expr
  val singleton : signature -> sentence ->
    (constraint_expr, Foundations.Category.error) result
  val union : constraint_expr -> constraint_expr -> constraint_expr
  val translate : signature_arrow -> constraint_expr ->
    (constraint_expr, Foundations.Category.error) result
  val inverse_translate : signature_arrow -> constraint_expr ->
    (constraint_expr, Foundations.Category.error) result
  val close : signature -> constraint_expr ->
    (constraint_expr, Foundations.Category.error) result
  val data : constraint_expr -> constraint_expr
  val preserves : signature_arrow ->
    source:constraint_expr -> target:constraint_expr ->
    (unit, Foundations.Category.error) result

  type coproduct = {
    sum : signature;
    left : signature_arrow;
    right : signature_arrow;
  }
  val coproduct : signature -> signature ->
    (coproduct, Foundations.Category.error) result

  type pushout = {
    pushout : signature;
    leg_left : signature_arrow;
    leg_right : signature_arrow;
  }
  val pushout : signature_arrow -> signature_arrow ->
    (pushout, Foundations.Category.error) result
end

module Make (L : LOGIC) : sig
  (** Presentations and arrows admitted under [L]'s transport and entailment. *)
  type presentation
  type theory_arrow

  (** Build a presentation without eagerly closing its constraints. *)
  val presentation : L.signature -> L.constraint_expr -> presentation
  val signature : presentation -> L.signature
  val constraints : presentation -> L.constraint_expr
  (* Apply the backend closure operation at an explicit boundary. *)
  val close : presentation ->
    (presentation, Foundations.Category.error) result

  val theory_arrow : presentation -> L.signature_arrow -> presentation ->
    (theory_arrow, Foundations.Category.error) result
  val arrow_source : theory_arrow -> presentation
  val arrow_target : theory_arrow -> presentation
  val arrow_map : theory_arrow -> L.signature_arrow

  (** Form a tagged signature coproduct and transport both constraint sets. *)
  val combine : presentation -> presentation ->
    (presentation, Foundations.Category.error) result
  val enrich : presentation ->
    extension:L.signature_arrow -> additions:L.constraint_expr ->
    (presentation, Foundations.Category.error) result
  (* Apply a parameter through a signature pushout. *)
  val parameter_apply :
    requirement:presentation -> parameter:presentation ->
    requirement_map:L.signature_arrow -> parameter_map:L.signature_arrow ->
    (presentation, Foundations.Category.error) result

  val category : (presentation, theory_arrow) Foundations.Category.cat
end
