(* Closed finite universes. Atomic values must be immutable and equality a
   stable terminating equivalence. Callback exceptions propagate unchanged. *)
module type ATOM = sig
  type t
  val equal : t -> t -> bool
end

module type S = sig
  type atom
  type value
  type view = Atom of atom | Tag of int * value | Pair of value * value | Terminal
  type set
  type arrow
  val atom : atom -> value
  val tag : int -> value -> value
  val pair : value -> value -> value
  val terminal : value
  val view : value -> view
  val equal : value -> value -> bool
  val emptyset : set
  val singleton : value -> set
  val of_list : value list -> set
  val to_list : set -> value list
  val seteq : set -> set -> bool
  val member : value -> set -> bool
  val cardinality : set -> int
  val is_empty : set -> bool
  val union : set -> set -> set
  val inter : set -> set -> set
  val diff : set -> set -> set
  val mapset : (value -> value) -> set -> set
  val cartesian_prod : set -> set -> set
  val disjoint_union : set -> set -> set
  val powerset : set -> set list
  val split : set -> set * set
  val singleton_split : set -> (value * set) option
  val arrow : set -> (value -> value) -> set -> (arrow, Foundations.Category.error) result
  val arrow_result :
    set -> (value -> (value, Foundations.Category.error) result) -> set -> (arrow, Foundations.Category.error) result
  val source : arrow -> set
  val target : arrow -> set
  val apply : arrow -> value -> (value, Foundations.Category.error) result
  val ident : set -> arrow
  val compose : arrow -> arrow -> (arrow, Foundations.Category.error) result
  val equal_arrow : arrow -> arrow -> bool
  val cat : (set, arrow) Foundations.Category.cat
end

module Make (E : ATOM) : S with type atom = E.t = struct
  type atom = E.t
  type value = Atom of atom | Tag of int * value | Pair of value * value | Terminal
  type view = value = Atom of atom | Tag of int * value | Pair of value * value | Terminal
  type set = value list
  type arrow = { src : set; tgt : set; entries : (value * value) list }

  let atom x = Atom x
  let tag i x = Tag (i, x)
  let pair x y = Pair (x, y)
  let terminal = Terminal
  let view x = x

  let rec equal x y = match x, y with
    | Atom a, Atom b -> E.equal a b
    | Tag (i, a), Tag (j, b) -> i = j && equal a b
    | Pair (a, b), Pair (c, d) -> equal a c && equal b d
    | Terminal, Terminal -> true
    | _ -> false

  let member x s = List.exists (equal x) s
  let of_list xs =
    List.rev (List.fold_left (fun s x -> if member x s then s else x :: s) [] xs)
  let to_list s = s
  let emptyset = []
  let singleton x = [x]
  let seteq a b =
    List.for_all (fun x -> member x b) a && List.for_all (fun x -> member x a) b
  let cardinality = List.length
  let is_empty s = match s with [] -> true | _ -> false
  let union a b = of_list (a @ b)
  let inter a b = List.filter (fun x -> member x b) a
  let diff a b = List.filter (fun x -> not (member x b)) a
  let mapset f s = of_list (List.map f s)
  let cartesian_prod a b =
    of_list (List.concat_map (fun x -> List.map (pair x) b) a)
  let disjoint_union a b = union (mapset (tag 0) a) (mapset (tag 1) b)
  let rec powerset = function
    | [] -> [[]]
    | x :: xs -> let rest = powerset xs in rest @ List.map (fun s -> x :: s) rest
  let rec split = function
    | [] -> [], []
    | x :: xs -> let a, b = split xs in x :: b, a
  let singleton_split = function [] -> None | x :: xs -> Some (x, xs)

  let source a = a.src
  let target a = a.tgt

  let arrow_result src fn tgt =
    let open Foundations.Category in
    let* entries = traverse (fun x ->
      let* y = fn x in
      if member y tgt then Ok (x, y)
      else Error (Outside_codomain "FinSet.arrow: image not in target")) src in
    Ok { src; tgt; entries }

  let arrow src fn tgt = arrow_result src (fun x -> Ok (fn x)) tgt

  let apply a x =
    match List.find_opt (fun (y, _) -> equal x y) a.entries with
    | Some (_, y) -> Ok y
    | None -> Error (Foundations.Category.Outside_domain "FinSet.apply: value not in source")

  let ident s = { src = s; tgt = s; entries = List.map (fun x -> x, x) s }

  let compose g f =
    let open Foundations.Category in
    if not (seteq f.tgt g.src) then Error (Non_composable "FinSet.compose: middle objects")
    else arrow_result f.src (fun x -> let* y = apply f x in apply g y) g.tgt

  let equal_arrow f g =
    seteq f.src g.src && seteq f.tgt g.tgt &&
    List.for_all (fun x ->
      match apply f x, apply g x with
      | Ok a, Ok b -> equal a b
      | _ -> false) f.src

  let cat = { Foundations.Category.source; target; ident; equal_obj = seteq;
              equal_arr = equal_arrow; comp = (fun (g, f) -> compose g f) }
end
