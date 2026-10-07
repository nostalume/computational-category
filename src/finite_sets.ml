(* ============================================================================
   Finite Sets — foundational module (Ch2 Ex9, Ch3.4.1, Ch4.6/4.9).
   Layer 0: sets, tagged values, union-find coequalizers.

   Key design decisions:
   - 'a set = 'a list (sets as deduplicated lists)
   - set_arrow uses a NAMED RECORD, not a tuple constructor.
     This eliminates all the precedence bugs seen in the original code
     where SetArrow (a, f, b) was misparsed as curried application.
   - Union-find coequalizer with path compression and rank-based union
   - Flat Tag(int, 'a) labeling for disjoint unions (internal, hidden)
   ============================================================================ *)

(* ============================================================================
   Sets as lists. A set is a list with no duplicates.
   ============================================================================ *)
type 'a set = 'a list

let emptyset : 'a set = []
let singleton x : 'a set = [x]

let seteq a b =
  List.for_all (fun x -> List.mem x b) a && List.for_all (fun y -> List.mem y a) b

let rec union a b =
  match a with
  | [] -> b
  | x :: xs -> if List.mem x b then union xs b else x :: union xs b

let rec inter a b =
  match a with
  | [] -> []
  | x :: xs -> if List.mem x b then x :: inter xs b else inter xs b

let rec diff a b =
  match a with
  | [] -> []
  | x :: xs -> if List.mem x b then diff xs b else x :: diff xs b

let mapset f s = List.map f s
let is_empty s = s = []
let cardinality s = List.length s
let member x s = List.mem x s
let to_list s = s

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

(* ============================================================================
   Tagged values for labelled disjoint unions (internal).
   Flat integer tagging: Tag(n, x) marks x as coming from the n-th summand.
   Backward-compatible constructors kept for existing tests.
   ============================================================================ *)
type 'a tag = Tag of int * 'a

(* Backward-compatible constructors for Pink/Blue (coproducts) and
   Just/Pair (functors/products). Kept for test compatibility only. *)
type 'a pinkblue = Pink of 'a | Blue of 'a
type 'a pair = Pair of 'a * 'a
type t_true = TTrue
type 'a just = Just of 'a

let tag_unwrap (Tag (_, x)) = x

(* ============================================================================
   Tagged disjoint union: elements of `a` get tag 0, of `b` get tag 1.
   Internal representation; users see only the plain set via normalize.
   ============================================================================ *)
let tagged_union a b =
  union (mapset (fun x -> Tag (0, x)) a) (mapset (fun x -> Tag (1, x)) b)

let disjoint_union a b = tagged_union a b

(* Utility for tests that expect pink/blue-tagged unions *)
let pink_tagged_union a b =
  union (mapset (fun x -> Pink x) a) (mapset (fun x -> Blue x) b)

(* ============================================================================
   Set arrow — CHANGED: named record instead of tuple constructor.

   This is the critical design decision. The old form:
     type 'a set_arrow = SetArrow of 'a set * ('a -> 'a) * 'a set
   caused massive parsing ambiguity:
     SetArrow (a, f, b) parsed as SetArrow (a) applied to (f, b)
   because OCaml parses function application left-associatively.

   The new form avoids this entirely — all access is via field names.
   ============================================================================ *)
type 'a set_arrow = {
  sa_src : 'a set;
  sa_fn  : 'a -> 'a;
  sa_tgt : 'a set;
}

let set_s a = a.sa_src
let set_t a = a.sa_tgt
let set_ident a = { sa_src = a; sa_fn = (fun x -> x); sa_tgt = a }

(* Result-based composition — matches Cat.compose_result style *)
let set_comp (f : 'a set_arrow) (g : 'a set_arrow) : ('a set_arrow, string) result =
  if seteq f.sa_tgt g.sa_src then
    Ok { sa_src = f.sa_src; sa_fn = (fun x -> g.sa_fn (f.sa_fn x)); sa_tgt = g.sa_tgt }
  else
    Error "non_composable_pair"

let set_arrow_apply a x = a.sa_fn x

(* Legacy alias for code that still calls set_comp expecting a direct value *)
let set_comp_direct f g = match set_comp f g with Ok x -> x | Error _ -> raise (Failure "non_composable_pair")

(* ============================================================================
   The FinSet category as a Cat.cat value.
   ============================================================================ *)
let finset_cat : ('a set, 'a set_arrow) Cat.cat =
  { Cat.source = set_s;
    Cat.target = set_t;
    Cat.ident  = set_ident;
    Cat.comp   = (fun (g, f) -> set_comp_direct f g) }

(* ============================================================================
   Utility functions
   ============================================================================ *)
let rec split s =
  match s with
  | [] -> ([], [])
  | [x] -> ([x], [])
  | x :: xs ->
    let (a, b) = split xs in
    (x :: a, b)

let rec singleton_split s =
  match s with
  | [] -> raise (Failure "empty set")
  | [x] -> (x, [])
  | x :: xs -> (x, xs)

(* ============================================================================
   Union-Find for coequalizer computation (Ch4.6).
   A disjoint-set forest over an array of elements.
   ============================================================================ *)
type 'a uf = { parent : int array; rank : int array; elems : 'a array }

let init_uf (elems : 'a list) : 'a uf =
  let n = List.length elems in
  { parent = Array.init n (fun i -> i);
    rank = Array.make n 0;
    elems = Array.of_list elems }

(* find with path compression *)
let rec find (uf : 'a uf) (i : int) : int =
  let p = uf.parent.(i) in
  if p = i then i
  else begin
    let root = find uf p in
    uf.parent.(i) <- root;
    root
  end

(* union by rank *)
let union_uf (uf : 'a uf) (i : int) (j : int) : unit =
  let ri = find uf i in
  let rj = find uf j in
  if ri <> rj then
    if uf.rank.(ri) < uf.rank.(rj) then uf.parent.(ri) <- rj
    else begin
      uf.parent.(rj) <- ri;
      if uf.rank.(ri) = uf.rank.(rj) then uf.rank.(ri) <- uf.rank.(ri) + 1
    end

(* group elements by root; returns (root, element list) list *)
let group_by_root (uf : 'a uf) : (int * 'a list) list =
  let n = Array.length uf.elems in
  let tbl = Hashtbl.create n in
  Array.iteri (fun i e ->
    let root = find uf i in
    let cur = try Hashtbl.find tbl root with Not_found -> [] in
    Hashtbl.replace tbl root (e :: cur)
  ) uf.elems;
  Hashtbl.fold (fun root es acc -> (root, es) :: acc) tbl []

(* find index of element in a list; returns option to avoid exceptions *)
let find_ix elems x =
  let rec go i = function
    | [] -> None
    | y :: _ when y = x -> Some i
    | _ :: rest -> go (i + 1) rest
  in
  go 0 elems

(* ============================================================================
   Coequalizer in FinSet (Ch4.6) — improved union-find implementation.
   Returns the equivalence classes (list of sets) of the target set.
   ============================================================================ *)
let set_coequalizer_classes
    (f_arrow : 'a set_arrow)
    (g_arrow : 'a set_arrow)
    : 'a set list =
  let src_b = set_t f_arrow in
  let f_fn = set_arrow_apply f_arrow in
  let g_fn = set_arrow_apply g_arrow in
  let b_elems = to_list src_b in
  let uf = init_uf b_elems in
  (* For each z in source a, merge f(z) and g(z) *)
  List.iter (fun z ->
    let x = f_fn z in
    let y = g_fn z in
    let ix = find_ix b_elems x in
    let iy = find_ix b_elems y in
    match ix, iy with
    | Some ix, Some iy -> union_uf uf ix iy
    | _, _ -> ()
  ) (to_list (set_s f_arrow));
  List.map (fun (_, es) -> dedup es) (group_by_root uf)

(* ============================================================================
   Normalization for output (Ch4.9/4.10).
   Flattens tags and deduplicates so the user sees clean mathematical objects.
   ============================================================================ *)
let tag_val (Tag (_, v)) = v

let normalize_tagged_set s =
  dedup (List.map tag_val s)

let normalize_set s =
  dedup s

(* ============================================================================
   Convenience constructor: build a set from a list
   ============================================================================ *)
let of_list lst = dedup lst