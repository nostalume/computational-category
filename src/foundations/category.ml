(* Executable categories: supplied lawful equality and checked composition.
   All composition arguments are ordered g, f for g after f. *)
type error =
  | Non_composable of string
  | Non_parallel of string
  | Outside_domain of string
  | Outside_codomain of string
  | Malformed_graph of string
  | Malformed_diagram of string
  | Malformed_term of string
  | Malformed_relation of string
  | Different_base of string
  | Non_commuting of string
  | Iteration_limit of int

let ( let* ) r f = match r with Ok x -> f x | Error e -> Error e

let rec traverse f = function
  | [] -> Ok []
  | x :: xs ->
    let* y = f x in
    let* ys = traverse f xs in
    Ok (y :: ys)

type ('o, 'a) cat = {
  source : 'a -> 'o;
  target : 'a -> 'o;
  ident : 'o -> 'a;
  equal_obj : 'o -> 'o -> bool;
  equal_arr : 'a -> 'a -> bool;
  comp : 'a * 'a -> ('a, error) result;
}

let compose c g f = c.comp (g, f)

let parallel c f g =
  c.equal_obj (c.source f) (c.source g) &&
  c.equal_obj (c.target f) (c.target g)

let has_endpoints c a source target =
  c.equal_obj (c.source a) source && c.equal_obj (c.target a) target

let dual_cat c =
  { c with source = c.target; target = c.source;
           comp = (fun (g, f) -> c.comp (f, g)) }

(* A recognizer supplies None for a non-isomorphism. Proposed inverses are
   checked in both directions; recognition must itself be lawful and stable. *)
type ('o,'a) iso_cat = {
  iso_cat : ('o,'a) cat;
  iso_inverse : 'a -> ('a option,error) result;
}
let inverse iso h =
  let* candidate = iso.iso_inverse h in
  match candidate with
  | None -> Ok None
  | Some k ->
    let c = iso.iso_cat in
    if not (has_endpoints c k (c.target h) (c.source h)) then
      Error (Non_composable "inverse endpoints")
    else
      let* kh = compose c k h in let* hk = compose c h k in
      if c.equal_arr kh (c.ident (c.source h)) && c.equal_arr hk (c.ident (c.target h))
      then Ok (Some k) else Error (Non_commuting "inverse equations")
