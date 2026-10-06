(* ============================================================================
   Term Category (TΩ_Fin) and Finite Category examples (Ch3.4.2, Ch3.4.3).
   ============================================================================ *)

(* ============================================================================
   TΩ_Fin: terms and term substitutions (Ch3.4.2)
   ============================================================================ *)
module TermCategory = struct
  type opr = Opr of string * string list
  type term =
    | Var of string
    | Apply of opr * (string -> term)
  type substitution = Subst of string list * (string -> term) * string list

  let subst_s (Subst (a, _, _)) = a
  let subst_t (Subst (_, _, b)) = b
  let subst_ident a = Subst (a, (fun x -> Var x), a)

  let rec subst_apply t (Subst (_, f, _)) =
    match t with
    | Var x -> f x
    | Apply (psi, s) -> Apply (psi, (fun x -> subst_apply (s x) (Subst (opr_args psi, f, []))))

  and subst_compose (Subst (c, g, d)) (Subst (a, f, b)) =
    if b = c then Subst (a, (fun x -> subst_apply (f x) (Subst (c, g, d))), d)
    else raise (Failure "non_composable")

  and opr_args (Opr (_, args)) = args

  let cat : (string list, substitution) Cat.cat =
    Cat.Cat (subst_s, subst_t, subst_ident, fun (f, g) -> subst_compose f g)
end

(* ============================================================================
   A finite category with 3 objects (Ch3.4.3)
   ============================================================================ *)
module FiniteCategory = struct
  type obj = A | B | C
  type arr = F | G | H | K | Id of obj

  let source a =
    match a with
    | F -> B | G -> A | H -> A | K -> B | Id x -> x

  let target a =
    match a with
    | F -> A | G -> C | H -> C | K -> C | Id x -> x

  let ident x = Id x

  let comp (a, b) =
    match (a, b) with
    | (Id x, u) -> if target u = x then u else raise (Failure "non_composable")
    | (u, Id x) -> if source u = x then u else raise (Failure "non_composable")
    | (G, F) -> K
    | (H, F) -> K
    | _ -> raise (Failure "non_composable")

  let cat : (obj, arr) Cat.cat = Cat.Cat (source, target, ident, comp)
end