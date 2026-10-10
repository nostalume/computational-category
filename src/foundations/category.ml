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
