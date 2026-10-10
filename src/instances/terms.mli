type names
type opr
type term
type view = Variable of string | Application of opr * (string * term) list
type substitution
val names : string list -> names
val names_list : names -> string list
val equal_names : names -> names -> bool
val operator : string -> string list -> (opr, Foundations.Category.error) result
val operator_name : opr -> string
val operator_args : opr -> string list
val var : string -> term
val application : opr -> (string -> term) -> (term, Foundations.Category.error) result
val view : term -> view
val equal_term : term -> term -> bool
val substitution :
  names -> (string -> term) -> names -> (substitution, Foundations.Category.error) result
val apply_term : substitution -> term -> (term, Foundations.Category.error) result
val source : substitution -> names
val target : substitution -> names
val ident : names -> substitution
val compose : substitution -> substitution -> (substitution, Foundations.Category.error) result
val equal_arrow : substitution -> substitution -> bool
val cat : (names, substitution) Foundations.Category.cat
