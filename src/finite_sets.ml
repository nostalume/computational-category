(* ============================================================================
   Finite Sets — foundational module (Ch2 Ex9, Ch3.4.1, Ch4.6/4.9).
   Provides set operations, tagged values for disjoint unions, the FinSet
   category, and union-find based coequalizer computation.
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
   Flat integer tagging: tag(n, x) marks x as coming from the n-th set.
   Backward-compatible constructors for tests.
   ============================================================================ *)
type 'a tag = Tag of int * 'a

(* Backward-compatible constructors for Pink/Blue (coproducts) and
   Just/Pair (functors/products). These are kept for test compatibility. *)
type 'a pinkblue = Pink of 'a | Blue of 'a
type 'a pair = Pair of 'a * 'a
type t_true = TTrue
type 'a just = Just of 'a

let tag_unwrap (Tag (_, x)) = x

(* ============================================================================
   Tagged disjoint union: elements of `a` get tag 0, of `b` get tag 1.
   ============================================================================ *)
let tagged_union a b =
  union (mapset (fun x -> Tag (0, x)) a) (mapset (fun x -> Tag (1, x)) b)

let disjoint_union a b = tagged_union a b

(* Utility for tests: pink/blue tagged union *)
let pink_tagged_union a b =
  union (mapset (fun x -> Pink x) a) (mapset (fun x -> Blue x) b)

(* ============================================================================
   FinSet category (Ch3.4.1).
   Objects are `'a set`, arrows are `set_arrow` triples (source, fn, target).
   ============================================================================ *)
type 'a set_arrow = SetArrow of 'a set * ('a -> 'a) * 'a set

let set_s (SetArrow (a, _, _)) = a
let set_t (SetArrow (_, _, b)) = b
let set_ident a = SetArrow (a, (fun x -> x), a)

let set_comp (SetArrow (c, g, d)) (SetArrow (a, f, b)) =
  if seteq b c then SetArrow (a, (fun x -> g (f x)), d)
  else raise (Failure "non_composable_pair")

let set_arrow_apply (SetArrow (_, f, _)) x = f x

(* The FinSet category, expressed as a value of type Cat.cat *)
let finset_cat : ('a set, 'a set_arrow) Cat.cat =
  Cat.Cat (set_s, set_t, set_ident, fun (f, g) -> set_comp f g)

(* ============================================================================
   Utility functions referenced by colimits.ml
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

let set_arrow_comp f g = set_comp f g

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

(* find the index of an element in a list *)
let find_ix elems x =
  let rec go i = function
    | [] -> raise (Failure "element not in set")
    | y :: _ when y = x -> i
    | _ :: rest -> go (i + 1) rest
  in
  go 0 elems

(* ============================================================================
   Coequalizer in FinSet (Ch4.6).
   Given a parallel pair f, g : a → b, returns the equivalence classes
   of b under the relation x ~ y iff f(z) = x and g(z) = y for some z in a
   (equivalence closure), plus a quotient map q : b → classes.

   The quotient object is the set of equivalence classes (each a set),
   which is the mathematically meaningful colimit object.
   ============================================================================ *)
let set_coequalizer (f_arrow : 'a set_arrow) (g_arrow : 'a set_arrow) =
  let src_a = set_s f_arrow in
  let src_b = set_t f_arrow in
  let f_fn = set_arrow_apply f_arrow in
  let g_fn = set_arrow_apply g_arrow in
  let a_elems = to_list src_a in
  let b_elems = to_list src_b in
  let uf = init_uf b_elems in
  (* For each z in a, merge the images f(z) and g(z) *)
  List.iter (fun z ->
    let x = f_fn z in
    let y = g_fn z in
    let ix = find_ix b_elems x in
    let iy = find_ix b_elems y in
    union_uf uf ix iy
  ) a_elems;
  (* Each equivalence class is a set of elements *)
  let classes = List.map (fun (_, es) -> dedup es) (group_by_root uf) in
  (* The quotient map q : b → classes sends each element to its class *)
  let q x =
    let ix = find_ix b_elems x in
    let r = find uf ix in
    (* find the class whose first element is in the same root *)
    let cls =
      List.find (fun c -> List.exists (fun y -> find_ix b_elems y = r) c) classes
    in
    cls
  in
  (classes, q)

(* ============================================================================
   Normalization for output (Ch4.9/4.10).
   Flattens tags and deduplicates so the user sees clean mathematical objects.
   ============================================================================ *)
let tag_val (Tag (_, v)) = v

(* Normalize a set of tags into a set of plain values *)
let normalize_tagged_set s =
  dedup (List.map tag_val s)

(* Normalize a plain set: dedup only *)
let normalize_set s =
  dedup s

(* ============================================================================
   Convenience constructor: build a set from a list
   ============================================================================ *)
let of_list lst = dedup lst
