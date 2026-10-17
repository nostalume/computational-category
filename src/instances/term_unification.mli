(** An efficient finite term-unification interface. Terms use arrays for
    operator arguments; solving compiles variables to dense integers and uses a
    union-find with path compression. The list-labelled [Terms] API remains an
    adapter, not the solver's working representation. *)
type symbol
val symbol : string -> string list -> (symbol, Foundations.Category.error) result
val symbol_name : symbol -> string
val symbol_arguments : symbol -> string list

(** Solver terms with array-backed operator arguments. *)
type term =
  | Variable of string
  | Application of symbol * term array

val variable : string -> term
val application : symbol -> (string * term) list ->
  (term, Foundations.Category.error) result
val equal_term : term -> term -> bool
val from_terms : Terms.term -> (term, Foundations.Category.error) result
val to_terms : term -> (Terms.term, Foundations.Category.error) result

type equation = term * term
(* A frozen most-general substitution returned by [unify]. *)
type substitution
val unify : equation list -> (substitution, Foundations.Category.error) result
val image : substitution -> string -> (term, Foundations.Category.error) result
val apply : substitution -> term -> (term, Foundations.Category.error) result
val substitution_domain : substitution -> string list

(** A common pattern together with its two instance substitutions. *)
type generalization = {
  pattern : term;
  left : substitution;
  right : substitution;
}
val generalize : term -> term -> (generalization, Foundations.Category.error) result
