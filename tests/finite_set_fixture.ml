(* Bounded executable evidence, not a proof for arbitrary supplied categories. *)
open Computational_category
open Checks
module I = Instances.Finite_sets.Make (struct type t = int let equal (a : int) b = a = b end)
module U = Instances.Finite_set_universals.Make (I)

let noncomp = function Foundations.Category.Non_composable _ -> true | _ -> false
let nonparallel = function Foundations.Category.Non_parallel _ -> true | _ -> false
let outside = function Foundations.Category.Outside_domain _ -> true | _ -> false
let noncommuting = function Foundations.Category.Non_commuting _ -> true | _ -> false
let ints xs = I.of_list (List.map I.atom xs)
let v x = I.atom x
let base = ints [1;2]
let objects = I.powerset base
let maps_count = ref 0

let rec assignments domain codomain = match domain with
  | [] -> [[]]
  | x :: xs ->
    List.concat_map (fun y ->
      List.map (fun rest -> (x, y) :: rest) (assignments xs codomain)) codomain

let all_maps a b =
  List.map (fun entries ->
    incr maps_count;
    get (I.arrow_result a (fun x ->
      match List.find_opt (fun (y, _) -> I.equal x y) entries with
      | Some (_, z) -> Ok z
      | None -> Error (Foundations.Category.Outside_domain "test finite mapping")) b))
    (assignments (I.to_list a) (I.to_list b))

let composite g f = get (I.compose g f)
let arrow_eq = I.equal_arrow
let endpoints label a s t = check label (Foundations.Category.has_endpoints I.cat a s t)
