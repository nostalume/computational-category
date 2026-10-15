open Foundations.Category

type symbol = { name : string; labels : string array }
let symbol name labels =
  let labels = Array.of_list labels in
  let sorted = Array.to_list labels |> List.sort String.compare in
  let rec unique = function
    | [] | [_] -> true
    | a :: b :: rest -> a <> b && unique (b :: rest)
  in
  if not (unique sorted) then Error (Malformed_term "unification symbol: duplicate argument label")
  else Ok {name;labels}
let symbol_name s = s.name
let symbol_arguments s = Array.to_list s.labels

type term = Variable of string | Application of symbol * term array
type core = CVar of int | CApp of symbol * core array
let variable x = Variable x

let application op entries =
  let find label = List.find_opt (fun (l,_) -> String.equal l label) entries in
  let* args = traverse (fun label ->
    match find label with
    | Some (_,t) -> Ok t
    | None -> Error (Malformed_term ("unification application: missing " ^ label)))
    (Array.to_list op.labels) in
  if List.length entries <> Array.length op.labels then
    Error (Malformed_term "unification application: arity mismatch")
  else Ok (Application (op, Array.of_list args))

let rec equal_term a b = match a,b with
  | Variable x, Variable y -> String.equal x y
  | Application (s,xs), Application (t,ys) ->
    String.equal s.name t.name && Array.length s.labels = Array.length t.labels &&
    Array.for_all2 String.equal s.labels t.labels &&
    Array.length xs = Array.length ys && Array.for_all2 equal_term xs ys
  | _ -> false

let rec from_terms (t : Terms.term) =
  match Terms.view t with
  | Terms.Variable x -> Ok (Variable x)
  | Terms.Application (op, entries) ->
    let* s = symbol (Terms.operator_name op) (Terms.operator_args op) in
    let* entries = traverse (fun (label,x) -> let* y = from_terms x in Ok (label,y)) entries in
    application s entries

let rec to_terms t = match t with
  | Variable x -> Ok (Terms.var x)
  | Application (s,args) ->
    let* op = Terms.operator s.name (Array.to_list s.labels) in
    let entries = Array.to_list (Array.mapi (fun i x -> s.labels.(i),x) args) in
    let* entries = traverse (fun (label,x) -> let* y = to_terms x in Ok (label,y)) entries in
    Terms.application op (fun label ->
      match List.find_opt (fun (l,_) -> String.equal l label) entries with
      | Some (_,x) -> x
      | None -> Terms.var label)

type equation = term * term

type substitution = { names : string array; images : term array }
let substitution_domain s = Array.to_list s.names

let names_of_terms equations =
  let set = Hashtbl.create 16 in
  let rec visit = function
    | Variable x -> Hashtbl.replace set x ()
    | Application (_,args) -> Array.iter visit args
  in
  List.iter (fun (a,b) -> visit a; visit b) equations;
  Hashtbl.to_seq_keys set |> List.of_seq |> List.sort String.compare

let unify equations =
  let names = Array.of_list (names_of_terms equations) in
  let index = Hashtbl.create (Array.length names) in
  Array.iteri (fun i n -> Hashtbl.add index n i) names;
  let rec compile = function
    | Variable x ->
      (match Hashtbl.find_opt index x with Some i -> Ok (CVar i) | None -> Error (Malformed_term "unification variable"))
    | Application (s,args) ->
      let* args = traverse (fun x -> let* c = compile x in Ok c) (Array.to_list args) in
      Ok (CApp (s,Array.of_list args))
  in
  let* compiled = traverse (fun (a,b) -> let* x = compile a in let* y = compile b in Ok (x,y)) equations in
  let n = Array.length names in
  let parent = Array.init n Fun.id and rank = Array.make n 0 and binding = Array.make n None in
  let rec find x =
    if parent.(x) = x then x else let r = find parent.(x) in parent.(x) <- r; r
  in
  let rec repr = function
    | CVar i ->
      let r = find i in
      (match binding.(r) with None -> CVar r | Some t -> repr t)
    | CApp (s,args) -> CApp (s,Array.map repr args)
  in
  let rec occurs root = function
    | CVar i ->
      let r = find i in
      if r = root then true else
        (match binding.(r) with None -> false | Some t -> occurs root t)
    | CApp (_,args) -> Array.exists (occurs root) args
  in
  let link a b =
    let ra = find a and rb = find b in
    if ra = rb then ()
    else if rank.(ra) < rank.(rb) then parent.(ra) <- rb
    else if rank.(ra) > rank.(rb) then parent.(rb) <- ra
    else (parent.(rb) <- ra; rank.(ra) <- rank.(ra) + 1)
  in
  let work = Queue.create () in
  List.iter (fun pair -> Queue.add pair work) compiled;
  let rec loop () =
    if Queue.is_empty work then Ok ()
    else
      let left,right = Queue.take work in
      match repr left, repr right with
      | CVar a,CVar b -> link a b; loop ()
      | CVar a,t | t,CVar a ->
        let r = find a in
        if occurs r t then Error (Malformed_term "unification cyclic")
        else (binding.(r) <- Some t; loop ())
      | CApp (s,xs),CApp (t,ys) ->
        if not (String.equal s.name t.name && Array.length s.labels = Array.length t.labels &&
                Array.for_all2 String.equal s.labels t.labels) then
          Error (Malformed_term "unification clash")
        else (Array.iter2 (fun x y -> Queue.add (x,y) work) xs ys; loop ())
  in
  let* () = loop () in
  let rec reify seen = function
    | CVar i ->
      let r = find i in
      if List.mem r seen then Error (Malformed_term "unification cyclic")
      else
        (match binding.(r) with None -> Ok (Variable names.(r)) | Some t -> reify (r::seen) t)
    | CApp (s,args) ->
      let* args = traverse (reify seen) (Array.to_list args) in
      Ok (Application (s,Array.of_list args))
  in
  let* images = traverse (fun i -> reify [] (CVar i)) (List.init n Fun.id) in
  Ok {names;images=Array.of_list images}

let image substitution name =
  match Array.find_index (String.equal name) substitution.names with
  | Some i -> Ok substitution.images.(i)
  | None -> Error (Outside_domain "unification substitution variable")

let apply substitution term =
  let rec go seen = function
    | Variable x ->
      if List.mem x seen then Error (Malformed_term "unification substitution cycle")
      else (match image substitution x with Ok t -> go (x::seen) t | Error _ -> Ok (Variable x))
    | Application (s,args) ->
      let* args = traverse (go seen) (Array.to_list args) in Ok (Application (s,Array.of_list args))
  in go [] term

module PairTable = Hashtbl.Make(struct
  type t = term * term
  let equal (a,b) (c,d) = equal_term a c && equal_term b d
  let rec term_hash = function
    | Variable x -> Hashtbl.hash (0,x)
    | Application (s,args) -> Hashtbl.hash (1,s.name,Array.to_list s.labels,Array.to_list (Array.map term_hash args))
  let hash (a,b) = Hashtbl.hash (term_hash a,term_hash b)
end)

type generalization = { pattern : term; left : substitution; right : substitution }

let generalize left right =
  let table = PairTable.create 32 and counter = ref 0 and lbind = ref [] and rbind = ref [] in
  let fresh a b =
    match PairTable.find_opt table (a,b) with
    | Some v -> v
    | None ->
      let v = Variable ("g" ^ string_of_int !counter) in
      incr counter; PairTable.add table (a,b) v; lbind := (v,a)::!lbind; rbind := (v,b)::!rbind; v
  in
  let rec go a b =
    if equal_term a b then Ok a
    else match a,b with
      | Application (s,xs), Application (t,ys)
        when String.equal s.name t.name && Array.length xs = Array.length ys &&
             Array.for_all2 String.equal s.labels t.labels ->
        let* args = traverse (fun i -> go xs.(i) ys.(i)) (List.init (Array.length xs) Fun.id) in
        Ok (Application (s,Array.of_list args))
      | _ -> Ok (fresh a b)
  in
  let* pattern = go left right in
  let make bindings =
    let names = Array.of_list (List.map (fun (value,_) -> match value with Variable x -> x | _ -> "") bindings) in
    let images = Array.of_list (List.map snd bindings) in
    {names;images}
  in
  Ok {pattern;left=make (List.rev !lbind);right=make (List.rev !rbind)}
