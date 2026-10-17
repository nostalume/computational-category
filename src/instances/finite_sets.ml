(** Closed finite universes. Atomic values must be immutable and equality a
    stable terminating equivalence. Callback exceptions propagate unchanged. *)
module type ATOM = sig
  type t
  val equal : t -> t -> bool
end

(** The equality-owned finite carrier and frozen-morphism interface. *)
module type S = sig
  type atom
  type value
  type view = Atom of atom | Tag of int * value | Pair of value * value | Terminal
  type carrier
  type morphism
  val atom : atom -> value
  val tag : int -> value -> value
  val pair : value -> value -> value
  val terminal : value
  val view : value -> view
  val equal : value -> value -> bool
  val empty : carrier
  val singleton : value -> carrier
  (* Admit one representative from each supplied equality class. *)
  val carrier_of_list : value list -> carrier
  val carrier_to_list : carrier -> value list
  val equal_carrier : carrier -> carrier -> bool
  val mem : value -> carrier -> bool
  val cardinality : carrier -> int
  val is_empty : carrier -> bool
  val union : carrier -> carrier -> carrier
  val inter : carrier -> carrier -> carrier
  val diff : carrier -> carrier -> carrier
  val map_carrier : (value -> value) -> carrier -> carrier
  val cartesian_prod : carrier -> carrier -> carrier
  val disjoint_union : carrier -> carrier -> carrier
  val powerset : carrier -> carrier list
  val split : carrier -> carrier * carrier
  val singleton_split : carrier -> (value * carrier) option
  val morphism : carrier -> (value -> value) -> carrier -> (morphism, Foundations.Category.error) result
  (* Freeze a checked total map, preserving result-valued failures. *)
  val morphism_result :
    carrier -> (value -> (value, Foundations.Category.error) result) -> carrier -> (morphism, Foundations.Category.error) result
  val domain : morphism -> carrier
  val codomain : morphism -> carrier
  val eval : morphism -> value -> (value, Foundations.Category.error) result
  val identity : carrier -> morphism
  val compose : morphism -> morphism -> (morphism, Foundations.Category.error) result
  val equal_morphism : morphism -> morphism -> bool
  (* Operational hooks for construction owners that already carry positions. *)
  module Private : sig
    val cartesian_prod_with_indices :
      carrier -> carrier -> carrier * int array * int array
    val morphism_from_indices :
      carrier -> int array -> carrier -> (morphism, Foundations.Category.error) result
    val carrier_from_indices : carrier -> int array -> carrier
    val target_index_at : morphism -> int -> int option
  end
  val cat : (carrier, morphism) Foundations.Category.cat
end

module Make (E : ATOM) : S with type atom = E.t = struct
  type atom = E.t
  type value = Atom of atom | Tag of int * value | Pair of value * value | Terminal
  type view = value = Atom of atom | Tag of int * value | Pair of value * value | Terminal
  type carrier = value array
  type morphism = {
    dom : carrier;
    cod : carrier;
    table : value array;
    target_indices : int array;
  }

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

  let rec array_exists p a i limit =
    i < limit && (p a.(i) || array_exists p a (i + 1) limit)
  let rec array_forall p a i =
    i = Array.length a || (p a.(i) && array_forall p a (i + 1))
  let mem x s = array_exists (equal x) s 0 (Array.length s)
  let finish_admitted buffer count =
    if count = Array.length buffer then buffer else Array.sub buffer 0 count
  let admit_arrays arrays total first =
    let buffer = Array.make total first in
    let count = ref 0 in
    let add x =
      if not (array_exists (equal x) buffer 0 !count) then begin
        buffer.(!count) <- x;
        incr count
      end
    in
    List.iter (fun values -> Array.iter add values) arrays;
    finish_admitted buffer !count
  let carrier_of_list xs =
    match xs with
    | [] -> [||]
    | first :: _ ->
      let total = List.length xs in
      let buffer = Array.make total first in
      let count = ref 0 in
      List.iter (fun x ->
        if not (array_exists (equal x) buffer 0 !count) then begin
          buffer.(!count) <- x;
          incr count
        end) xs;
      finish_admitted buffer !count
  let carrier_to_list = Array.to_list
  let empty = [||]
  let singleton x = [|x|]
  let equal_carrier a b =
    a == b ||
    (Array.length a = Array.length b &&
     array_forall (fun x -> mem x b) a 0 &&
     array_forall (fun x -> mem x a) b 0)
  let cardinality = Array.length
  let is_empty s = Array.length s = 0
  let array_filter p a =
    if is_empty a then [||]
    else begin
      let result = Array.make (Array.length a) a.(0) in
      let count = ref 0 in
      Array.iter (fun x -> if p x then begin result.(!count) <- x; incr count end) a;
      finish_admitted result !count
    end
  let union a b =
    if Array.length a = 0 then Array.copy b
    else if Array.length b = 0 then Array.copy a
    else admit_arrays [a; b] (Array.length a + Array.length b) a.(0)
  let inter a b = array_filter (fun x -> mem x b) a
  let diff a b = array_filter (fun x -> not (mem x b)) a
  let map_carrier f s =
    if is_empty s then [||]
    else begin
      let result = Array.make (Array.length s) (f s.(0)) in
      let count = ref 1 in
      for i = 1 to Array.length s - 1 do
        let x = f s.(i) in
        if not (array_exists (equal x) result 0 !count) then begin
          result.(!count) <- x;
          incr count
        end
      done;
      finish_admitted result !count
    end
  let cartesian_prod_with_indices a b =
    let left = Array.length a and right = Array.length b in
    if left = 0 || right = 0 then [||], [||], [||]
    else
      let size = left * right in
      (Array.init size (fun i -> pair a.(i / right) b.(i mod right)),
       Array.init size (fun i -> i / right),
       Array.init size (fun i -> i mod right))
  let cartesian_prod a b = let product, _, _ = cartesian_prod_with_indices a b in product
  let disjoint_union a b =
    let left = Array.length a and right = Array.length b in
    if left + right = 0 then [||]
    else begin
      let seed = if left > 0 then tag 0 a.(0) else tag 1 b.(0) in
      let result = Array.make (left + right) seed in
      for i = 0 to left - 1 do result.(i) <- tag 0 a.(i) done;
      for i = 0 to right - 1 do result.(left + i) <- tag 1 b.(i) done;
      result
    end
  let singleton_split s =
    if is_empty s then None
    else Some (s.(0), Array.sub s 1 (Array.length s - 1))
  let prepend x s =
    let result = Array.make (Array.length s + 1) x in
    Array.blit s 0 result 1 (Array.length s);
    result
  let powerset s =
    let rec build i =
      if i = Array.length s then [empty]
      else
        let rest = build (i + 1) in
        rest @ List.map (prepend s.(i)) rest
    in
    build 0
  let split s =
    let left = (Array.length s + 1) / 2 and right = Array.length s / 2 in
    (Array.init left (fun i -> s.(2 * i)),
     Array.init right (fun i -> s.(2 * i + 1)))
  let domain a = a.dom
  let codomain a = a.cod

  let morphism_result src fn tgt =
    let open Foundations.Category in
    if is_empty src then Ok { dom = src; cod = tgt; table = [||]; target_indices = [||] }
    else begin
      let table = Array.make (Array.length src) src.(0) in
      let target_indices = Array.make (Array.length src) 0 in
      let rec target_index x i =
        if i = Array.length tgt then None
        else if equal x tgt.(i) then Some i
        else target_index x (i + 1)
      in
      let rec loop i =
        if i = Array.length src then Ok { dom = src; cod = tgt; table; target_indices }
        else
          let* y = fn src.(i) in
          match target_index y 0 with
          | Some j -> table.(i) <- y; target_indices.(i) <- j; loop (i + 1)
          | None -> Error (Outside_codomain "FinSet.morphism: image not in codomain")
      in
      loop 0
    end

  let morphism src fn tgt = morphism_result src (fun x -> Ok (fn x)) tgt

  let index_of x values =
    let rec find i =
      if i = Array.length values then None
      else if equal x values.(i) then Some i else find (i + 1)
    in
    find 0

  let eval_indexed a x =
    match index_of x a.dom with
    | Some i -> Ok (a.table.(i), a.target_indices.(i))
    | None -> Error (Foundations.Category.Outside_domain "FinSet.eval: value not in domain")
  let eval a x =
    match eval_indexed a x with
    | Ok (y, _) -> Ok y
    | Error e -> Error e

  let identity s =
    { dom = s; cod = s; table = Array.copy s;
      target_indices = Array.init (Array.length s) (fun i -> i) }

  let compose g f =
    let open Foundations.Category in
    if not (equal_carrier f.cod g.dom) then Error (Non_composable "FinSet.compose: middle objects")
    else if is_empty f.dom then
      Ok { dom = f.dom; cod = g.cod; table = [||]; target_indices = [||] }
    else begin
      let table = Array.make (Array.length f.dom) f.dom.(0) in
      let target_indices = Array.make (Array.length f.dom) 0 in
      let rec loop i =
        if i = Array.length f.dom then Ok { dom = f.dom; cod = g.cod; table; target_indices }
        else
          let* y, j = eval_indexed g f.table.(i) in
          table.(i) <- y;
          target_indices.(i) <- j;
          loop (i + 1)
      in
      loop 0
    end

  let equal_morphism f g =
    equal_carrier f.dom g.dom && equal_carrier f.cod g.cod &&
    let rec same i =
      if i = Array.length f.dom then true
      else match index_of f.dom.(i) g.dom with
        | Some j -> equal f.table.(i) g.table.(j) && same (i + 1)
        | None -> false
    in
    same 0

  module Private = struct
    let cartesian_prod_with_indices = cartesian_prod_with_indices
    let carrier_from_indices carrier indices =
      Array.init (Array.length indices) (fun i -> carrier.(indices.(i)))
    let morphism_from_indices src indices tgt =
      let open Foundations.Category in
      if Array.length src <> Array.length indices then
        Error (Outside_domain "FinSet.Private.morphism_from_indices: source length")
      else
        let rec check i =
          if i = Array.length indices then
            let table = Array.init (Array.length indices) (fun j -> tgt.(indices.(j))) in
            Ok { dom = src; cod = tgt; table; target_indices = Array.copy indices }
          else if indices.(i) < 0 || indices.(i) >= Array.length tgt then
            Error (Outside_codomain "FinSet.Private.morphism_from_indices: target index")
          else check (i + 1)
        in
        check 0
    let target_index_at a i =
      if i < 0 || i >= Array.length a.target_indices then None
      else Some a.target_indices.(i)
  end

  let cat = { Foundations.Category.source = domain; target = codomain; ident = identity; equal_obj = equal_carrier;
              equal_arr = equal_morphism; comp = (fun (g, f) -> compose g f) }
end
