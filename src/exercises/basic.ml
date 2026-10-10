(* ============================================================================
   Basic — shared foundational types and utilities.
   Natural numbers, binary trees, list functions, monoids.
   ============================================================================ *)

(* Natural numbers (Ch2 Ex3) *)
type num = Zero | Succ of num

let rec numprint n =
  match n with
  | Zero -> 0
  | Succ m -> numprint m + 1

let rec add m n =
  match m with
  | Zero -> n
  | Succ m' -> Succ (add m' n)

(* Binary trees (Ch2 Ex6) *)
type 'a bintree = Tip of 'a | Node of 'a bintree * 'a bintree

let rec breadth t =
  match t with
  | Tip _ -> 1
  | Node (l, r) -> breadth l + breadth r

let rec depth t =
  match t with
  | Tip _ -> 1
  | Node (l, r) -> max (depth l) (depth r) + 1

let rec tips t =
  match t with
  | Tip a -> [a]
  | Node (l, r) -> tips l @ tips r

(* List utilities (Ch2 Ex5) *)
exception EmptyList

let rec int_pow base n =
  if n = 0 then 1 else base * int_pow base (n - 1)

let rec fold f init lst =
  match lst with
  | [] -> init
  | a :: s -> fold f (f a init) s

let rec maplist f lst =
  match lst with
  | [] -> []
  | a :: s -> f a :: maplist f s

let rec reverse_list lst =
  match lst with
  | [] -> []
  | a :: s -> reverse_list s @ [a]

let sum_list lst = fold (fun a b -> a + b) 0 lst

let rec max_list lst =
  match lst with
  | [] -> raise EmptyList
  | [a] -> a
  | a :: s -> let m = max_list s in if a > m then a else m

let poly coeffs x =
  (* Evaluate c0 + c1·x + c2·x² + ... where coeffs = [c0; c1; c2; ...]
     (constant term first). *)
  let rec eval lst i acc =
    match lst with
    | [] -> acc
    | c :: rest -> eval rest (i + 1) (acc + c * int_pow x i)
  in
  eval coeffs 0 0

(* Monoid structure (Ch2 Ex11) *)
type 'a monoid = { op : 'a * 'a -> 'a; identity : 'a }

let free_monoid_hom (m : 'a monoid) f lst =
  List.fold_left (fun acc x -> m.op (acc, f x)) m.identity lst
