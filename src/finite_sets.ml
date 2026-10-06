(* ============================================================================
   Finite Sets — foundational set module (Ch2 Ex9, Ch3.4.1, Ch4.6, Ch4.9).
   Provides set operations and tagged values for disjoint unions/products.
   ============================================================================ *)

(* Tagged values: Just, Pink/Blue (disjoint unions), Pair/TTrue (products) *)
type 'a tag =
  | Just of 'a
  | Pink of 'a tag
  | Blue of 'a tag
  | Pair of 'a tag * 'a tag
  | TTrue

(* Finite set as a list *)
type 'a set = 'a list

let emptyset = []
let singleton x = [x]

let seteq a b =
  List.for_all (fun x -> List.mem x b) a
  && List.for_all (fun y -> List.mem y a) b

let is_empty s = s = []
let cardinality s = List.length s
let member x s = List.mem x s

let rec union a b =
  match a with
  | [] -> b
  | x :: xs -> if List.mem x b then union xs b else x :: union xs b

let rec diff a b =
  match a with
  | [] -> []
  | x :: xs -> if List.mem x b then diff xs b else x :: diff xs b

let rec inter a b =
  match a with
  | [] -> []
  | x :: xs -> if List.mem x b then x :: inter xs b else inter xs b

let image f s = List.map f s

let rec mapset f s =
  match s with
  | [] -> []
  | x :: xs ->
    let fx = f x in
    if List.mem fx (mapset f xs) then mapset f xs else fx :: mapset f xs

let rec singleton_split s =
  match s with
  | [] -> raise (Failure "singleton_split on empty set")
  | [x] -> (x, [])
  | x :: xs -> (x, xs)

(* Split a set into two non-trivial sub-sets: a singleton and the rest *)
let split s =
  match s with
  | [] | [_] -> raise (Failure "split on non-splittable set")
  | x :: xs -> ([x], xs)

let rec dedup s =
  match s with
  | [] -> []
  | x :: xs -> if List.mem x xs then dedup xs else x :: dedup xs

let rec cartesian_prod a b =
  match a with
  | [] -> []
  | x :: xs -> List.map (fun y -> (x, y)) b @ cartesian_prod xs b

let rec powerset s =
  match s with
  | [] -> [[]]
  | x :: xs ->
    let rest = powerset xs in
    List.map (fun s' -> x :: s') rest @ rest

let disjoint_union a b =
  mapset (fun x -> Pink (Just x)) a
  @ mapset (fun x -> Blue (Just x)) b

(* ============================================================================
   FinSet: category of finite sets and set arrows (Ch3.4.1)
   ============================================================================ *)
type 'a set_arrow = SetArrow of 'a set * ('a -> 'a) * 'a set

let set_s (SetArrow (a, _, _)) = a
let set_t (SetArrow (_, _, b)) = b
let set_ident a = SetArrow (a, (fun x -> x), a)

let set_comp (SetArrow (c, g, d)) (SetArrow (a, f, b)) =
  if seteq b c then SetArrow (a, (fun x -> g (f x)), d)
  else raise (Failure "non_composable_pair")

let finset_cat : ('a set, 'a set_arrow) Cat.cat =
  Cat.Cat (set_s, set_t, set_ident, fun (f, g) -> set_comp f g)

let set_arrow_apply (SetArrow (_, f, _)) x = f x