module Make (F : Finite_sets.S) = struct
  module G = Finite_graphs.Make (F)
  module T = Finite_set_topos.Make (F)
  open Foundations.Category

  type graph = G.graph
  type graph_morphism = G.graph_morphism
  let graph = G.graph
  let nodes = G.nodes
  let edges = G.edges
  let incidence = G.incidence
  let graph_morphism = G.graph_morphism
  let source = G.source
  let target = G.target
  let edge_map = G.edge_map
  let node_map = G.node_map

  let pair_parts v = match F.view v with
    | F.Pair (x,y) -> Ok (x,y)
    | _ -> Error (Malformed_diagram "graph topos pair value")

  let triple_parts v =
    let* xy,e = pair_parts v in
    let* x,y = pair_parts xy in Ok (x,y,e)

  let function_values domain codomain =
    T.function_space domain codomain

  type exponential_data = {
    exponential : graph;
    evaluation : graph_morphism;
    curry : graph -> graph_morphism -> (graph_morphism,error) result;
  }

  let exponential h g =
    let* node_maps = function_values (nodes h) (nodes g) in
    let* edge_maps = function_values (edges h) (edges g) in
    let node_values = F.carrier_to_list node_maps and edge_values = F.carrier_to_list edge_maps in
    let edge_bindings = List.concat_map (fun em ->
      List.concat_map (fun sm ->
        List.filter_map (fun tm ->
          let valid = List.for_all (fun e ->
            match F.eval (incidence h) e,
                  T.evaluate_function (edges h) (edges g) em e with
            | Ok hv, Ok ge ->
              (match pair_parts hv, F.eval (incidence g) ge with
               | Ok (hs,ht), Ok gv ->
                 (match pair_parts gv,
                    T.evaluate_function (nodes h) (nodes g) sm hs,
                    T.evaluate_function (nodes h) (nodes g) tm ht with
                  | Ok (gs,gt), Ok s', Ok t' -> F.equal gs s' && F.equal gt t'
                  | _ -> false)
               | _ -> false)
            | _ -> false) (F.carrier_to_list (edges h)) in
          if valid then
            let value = F.pair (F.pair sm tm) em in
            Some (value,sm,tm)
          else None) node_values) node_values) edge_values in
    let product_graph x y =
      let ns = F.cartesian_prod (nodes x) (nodes y) in
      let bindings = List.concat_map (fun ex ->
        List.filter_map (fun ey ->
          match F.eval (incidence x) ex, F.eval (incidence y) ey with
          | Ok vx, Ok vy ->
            (match pair_parts vx, pair_parts vy with
             | Ok (sx,tx), Ok (sy,ty) ->
               Some (F.pair ex ey, F.pair sx sy, F.pair tx ty)
             | _ -> None)
          | _ -> None) (F.carrier_to_list (edges y))) (F.carrier_to_list (edges x)) in
      G.graph ~nodes:ns ~edges:bindings
    in
    let* exp = G.graph ~nodes:node_maps
      ~edges:(List.map (fun (value,sm,tm) -> (value,sm,tm)) edge_bindings) in
    let* prod = product_graph h exp in
    let* node_eval = F.morphism_result (nodes prod) (fun value ->
      let* x,e = pair_parts value in
      T.evaluate_function (nodes h) (nodes g) e x) (nodes g) in
    let* edge_eval = F.morphism_result (edges prod) (fun value ->
      let* h_e,e = pair_parts value in
      let* _sm,_tm,em = triple_parts e in
      T.evaluate_function (edges h) (edges g) em h_e) (edges g) in
    let* evaluation = G.graph_morphism prod
      ~edges:edge_eval ~nodes:node_eval g in
    let curry r f =
      let* expected = product_graph h r in
      if not (G.category.equal_obj (source f) expected) then
        Error (Different_base "graph exponential curry: product domain")
      else
        let* node_entries = traverse (fun rnode ->
          let wanted = List.map (fun hnode ->
            let input = F.pair hnode rnode in
            let* value = F.eval (node_map f) input in Ok (hnode,value))
            (F.carrier_to_list (nodes h)) in
          let* wanted = traverse (fun q -> q) wanted in
          match T.function_space (nodes h) (nodes g) with
          | Error e -> Error e
          | Ok fs ->
            let fn = List.find_opt (fun candidate ->
              List.for_all (fun (x,want) -> match T.evaluate_function (nodes h) (nodes g) candidate x with
                | Ok y -> F.equal y want | Error _ -> false) wanted)
              (F.carrier_to_list fs) in
            (match fn with Some value -> Ok (rnode,value) | None -> Error (Malformed_diagram "graph exponential curry: node graph")))
          (F.carrier_to_list (nodes r)) in
        let* edge_entries = traverse (fun redge ->
          let* rv = F.eval (incidence r) redge in
          let* rs,rt = pair_parts rv in
          let sm = match List.find_opt (fun (x,_) -> F.equal x rs) node_entries with Some (_,v) -> v | None -> F.terminal in
          let tm = match List.find_opt (fun (x,_) -> F.equal x rt) node_entries with Some (_,v) -> v | None -> F.terminal in
          let wanted = List.map (fun hedge ->
            let input = F.pair hedge redge in
            let* value = F.eval (edge_map f) input in Ok (hedge,value)) (F.carrier_to_list (edges h)) in
          let* wanted = traverse (fun q -> q) wanted in
          match T.function_space (edges h) (edges g) with
          | Error e -> Error e
          | Ok fs ->
            let fn = List.find_opt (fun candidate ->
              List.for_all (fun (x,want) -> match T.evaluate_function (edges h) (edges g) candidate x with
                | Ok y -> F.equal y want | Error _ -> false) wanted)
              (F.carrier_to_list fs) in
            (match fn with
             | None -> Error (Malformed_diagram "graph exponential curry: edge graph")
             | Some em -> Ok (redge,F.pair (F.pair sm tm) em)))
          (F.carrier_to_list (edges r)) in
        let* nm = F.morphism_result (nodes r) (fun x ->
          match List.find_opt (fun (q,_) -> F.equal q x) node_entries with
          | Some (_,v) -> Ok v | None -> Error (Outside_domain "graph exponential curry nodes")) node_maps in
        let* em = F.morphism_result (edges r) (fun x ->
          match List.find_opt (fun (q,_) -> F.equal q x) edge_entries with
          | Some (_,v) -> Ok v | None -> Error (Outside_domain "graph exponential curry edges")) (edges exp) in
        G.graph_morphism r ~edges:em ~nodes:nm exp
    in
    Ok {exponential=exp;evaluation;curry}

  type classifier = {
    omega : graph;
    truth : graph_morphism;
    character : graph_morphism -> (graph_morphism,error) result;
  }

  let classifier () =
    let false_ = T.truth_value false and true_ = T.truth_value true in
    let edge code = F.tag (940000 + code) F.terminal in
    let e0 = edge 0 and es = edge 1 and et = edge 2 and est = edge 3 and eall = edge 4 in
    let omega = match G.graph ~nodes:(F.carrier_of_list [false_;true_])
      ~edges:[e0,false_,false_; es,true_,false_; et,false_,true_; est,true_,true_; eall,true_,true_] with
      | Ok x -> x | Error _ -> invalid_arg "graph topos classifier" in
    let terminal = match G.graph ~nodes:(F.singleton F.terminal)
      ~edges:[F.tag 940100 F.terminal,F.terminal,F.terminal] with
      | Ok x -> x | Error _ -> invalid_arg "graph topos terminal" in
    let tn = match F.morphism (nodes terminal) (fun _ -> true_) (nodes omega) with
      | Ok x -> x | Error _ -> invalid_arg "graph topos truth nodes" in
    let tm = match F.morphism (edges terminal) (fun _ -> eall) (edges omega) with
      | Ok x -> x | Error _ -> invalid_arg "graph topos truth edges" in
    let truth = match G.graph_morphism terminal ~edges:tm ~nodes:tn omega with
      | Ok x -> x | Error _ -> invalid_arg "graph topos truth" in
    let edge_for node_s node_t member =
      match member,node_s,node_t with
      | false,false,false -> e0 | false,true,false -> es | false,false,true -> et
      | false,true,true -> est | true,_,_ -> eall in
    let character mono =
      let h = source mono and g = target mono in
      let image_nodes = F.carrier_of_list (List.filter_map (fun x -> match F.eval (node_map mono) x with Ok y -> Some y | Error _ -> None)
        (F.carrier_to_list (nodes h))) in
      let image_edges = F.carrier_of_list (List.filter_map (fun x -> match F.eval (edge_map mono) x with Ok y -> Some y | Error _ -> None)
        (F.carrier_to_list (edges h))) in
      if F.cardinality image_nodes <> F.cardinality (nodes h) || F.cardinality image_edges <> F.cardinality (edges h) then
        Error (Malformed_graph "graph topos classifier: monomorphism required")
      else
        let* nm = F.morphism_result (nodes g) (fun x -> Ok (if F.mem x image_nodes then true_ else false_)) (nodes omega) in
        let* em = F.morphism_result (edges g) (fun e ->
          let* inc = F.eval (incidence g) e in
          let* s,t = pair_parts inc in
          Ok (edge_for (F.mem s image_nodes) (F.mem t image_nodes) (F.mem e image_edges))) (edges omega) in
        G.graph_morphism g ~edges:em ~nodes:nm omega
    in
    {omega;truth;character}
end
