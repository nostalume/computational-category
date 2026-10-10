(* Finite term trees and admitted frozen substitutions. *)
open Foundations.Category
type names = string list
type opr = { name : string; args : names }
type term = Var of string | Apply of opr * (string * term) list
type view = Variable of string | Application of opr * (string * term) list
type substitution = { src : names; tgt : names; entries : (string * term) list }

let names xs =
  List.rev (List.fold_left (fun a x -> if List.mem x a then a else x :: a) [] xs)
let names_list a = a
let equal_names a b =
  List.for_all (fun x -> List.mem x b) a && List.for_all (fun x -> List.mem x a) b
let operator name args =
  if List.length (names args) <> List.length args then
    Error (Malformed_term ("operator " ^ name ^ ": duplicate argument label"))
  else Ok { name; args }
let operator_name o = o.name
let operator_args o = o.args
let var x = Var x
let application o f = Ok (Apply (o, List.map (fun x -> x, f x) o.args))
let view = function Var x -> Variable x | Apply (o, terms) -> Application (o, terms)

let rec equal_term a b = match a, b with
  | Var x, Var y -> String.equal x y
  | Apply (o, xs), Apply (p, ys) ->
    String.equal o.name p.name && equal_names o.args p.args &&
    List.for_all (fun (label, x) -> match List.assoc_opt label ys with
      | Some y -> equal_term x y | None -> false) xs
  | _ -> false

let rec variables = function
  | Var x -> [x]
  | Apply (_, terms) ->
    names (List.concat_map (fun (_, t) -> variables t) terms)

let substitution src f tgt =
  let* entries = traverse (fun x ->
    let t = f x in
    if List.for_all (fun v -> List.mem v tgt) (variables t) then Ok (x, t)
    else Error (Malformed_term ("substitution image of " ^ x ^ ": undeclared variable"))) src in
  Ok { src; tgt; entries }

let rec apply_term subst = function
  | Var x -> (match List.assoc_opt x subst.entries with
    | Some t -> Ok t | None -> Error (Outside_domain ("substitution variable: " ^ x)))
  | Apply (o, terms) ->
    let* terms = traverse (fun (x, t) ->
      let* image = apply_term subst t in Ok (x, image)) terms in
    Ok (Apply (o, terms))

let source s = s.src
let target s = s.tgt
let ident src = { src; tgt = src; entries = List.map (fun x -> x, Var x) src }

let compose g f =
  if not (equal_names f.tgt g.src) then Error (Non_composable "term substitution")
  else
    let* entries = traverse (fun (x, t) ->
      let* image = apply_term g t in Ok (x, image)) f.entries in
    Ok { src = f.src; tgt = g.tgt; entries }

let equal_arrow f g =
  equal_names f.src g.src && equal_names f.tgt g.tgt &&
  List.for_all (fun (label, x) -> match List.assoc_opt label g.entries with
    | Some y -> equal_term x y | None -> false) f.entries

let cat = { Foundations.Category.source; target; ident; equal_obj = equal_names;
            equal_arr = equal_arrow; comp = (fun (g, f) -> compose g f) }