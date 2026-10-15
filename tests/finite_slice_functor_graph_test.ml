open Computational_category
module F = Instances.Finite_sets.Make (struct type t=int let equal (a:int) b=a=b end)
module S = Instances.Finite_slice_topos.Make (F)
module K = Constructions.Functor_category
module FT = Instances.Finite_functor_topos.Make (F)
module GT = Instances.Finite_graph_topos.Make (F)
open Category_test_support.Checks

let v x = F.atom x
let set xs = F.carrier_of_list (List.map v xs)
let get = Category_test_support.Checks.get

let test_slice () =
  let base = set [0;1] in
  let x_total = set [10;11;12] and y_total = set [20;21;22] in
  let x_proj = get (F.morphism x_total (fun x -> if F.equal x (v 10) then v 0 else v 1) base) in
  let y_proj = get (F.morphism y_total (fun x -> if F.equal x (v 20) then v 0 else v 1) base) in
  let x = get (S.object_ base x_total x_proj) and y = get (S.object_ base y_total y_proj) in
  let e = get (S.exponential base x y) in
  check "slice exponential fibre cardinality" (F.cardinality (S.total e.exponential) = 5);
  let c = get (S.classifier base) in
  check "slice classifier fibre cardinality" (F.cardinality (S.total c.omega) = 4);
  let mono_map = get (F.morphism (F.singleton (v 10)) (fun _ -> v 10) x_total) in
  let mono = get (S.morphism (get (S.object_ base (F.singleton (v 10))
    (get (F.morphism (F.singleton (v 10)) (fun _ -> v 0) base)))) mono_map x) in
  ignore (get (c.character mono));
  Printf.printf "PASS finite slice topos\n%!"

let discrete_domain () =
  let cat = {Foundations.Category.source=fst;target=snd;ident=(fun x -> x,x);
    equal_obj=Bool.equal;equal_arr=(fun a b -> a=b);
    comp=(fun ((m,t),(s,n)) -> if m=n then Ok (s,t) else Error (Foundations.Category.Non_composable "discrete"))} in
  get (K.finite_domain cat ~objects:[false;true] ~arrows:[false,false;true,true])

let test_functor_topos () =
  let d = discrete_domain () in
  let a = get (K.constant_functor d F.cat (set [1;2])) in
  let b = get (K.constant_functor d F.cat (set [3;4])) in
  let e = get (FT.exponential d a b) in
  check "discrete functor exponential pointwise" (F.cardinality (get (K.object_map e.object_ false)) = 4);
  let c = get (FT.classifier d) in
  check "discrete functor classifier pointwise" (F.cardinality (get (K.object_map c.omega true)) = 2);
  Printf.printf "PASS discrete functor topos\n%!"

let test_graph_topos () =
  let one = set [0] and two = set [0;1] in
  let h = get (GT.graph ~nodes:one ~edges:[]) in
  let g = get (GT.graph ~nodes:two ~edges:[]) in
  let e = get (GT.exponential h g) in
  check "graph exponential vertices" (F.cardinality (GT.nodes e.exponential) = 2);
  let c = GT.classifier () in
  check "graph classifier vertices" (F.cardinality (GT.nodes c.omega) = 2);
  check "graph classifier edges" (F.cardinality (GT.edges c.omega) = 5);
  let loop = get (GT.graph ~nodes:one ~edges:[v 9,v 0,v 0]) in
  let arrow = get (GT.graph ~nodes:two ~edges:[v 8,v 0,v 1]) in
  let loop_exp = get (GT.exponential loop arrow) in
  check "graph exponential incidence edges" (F.cardinality (GT.edges loop_exp.exponential) = 1);
  let sub = get (GT.graph ~nodes:(set [0]) ~edges:[]) in
  let node_inclusion = get (F.morphism (GT.nodes sub) (fun x -> x) (GT.nodes arrow)) in
  let edge_inclusion = get (F.morphism (GT.edges sub) (fun x -> x) (GT.edges arrow)) in
  let inclusion = get (GT.graph_morphism sub ~edges:edge_inclusion ~nodes:node_inclusion arrow) in
  ignore (get (c.character inclusion));
  Printf.printf "PASS finite graph topos\n%!"

let () = test_slice (); test_functor_topos (); test_graph_topos ()
