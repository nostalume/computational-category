open Computational_category
(* Shared textbook fixture, not part of the library. *)
type obj = A | B | C
  type arr = F | G | H | K | Id of obj
  let source = function F | K -> B | G | H -> A | Id x -> x
  let target = function F -> A | G | H | K -> C | Id x -> x
  let ident x = Id x
  let comp (g, f) = match g, f with
    | Id x, u when target u = x -> Ok u
    | u, Id x when source u = x -> Ok u
    | G, F | H, F -> Ok K
    | _ -> Error (Foundations.Category.Non_composable "finite category")
  let cat = { Foundations.Category.source; target; ident; comp;
              equal_obj = (fun a b -> a = b); equal_arr = (fun a b -> a = b) }
