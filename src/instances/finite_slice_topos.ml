module Make (F : Finite_sets.S) = struct
  module T = Finite_set_topos.Make (F)
  open Foundations.Category

  type slice_object = { anchor : F.carrier; total_ : F.carrier; projection_ : F.morphism }
  type slice_morphism = { src_ : slice_object; map_ : F.morphism; tgt_ : slice_object }

  let object_ anchor total projection =
    if F.equal_carrier (F.domain projection) total &&
       F.equal_carrier (F.codomain projection) anchor then
      Ok {anchor; total_=total; projection_=projection}
    else Error (Non_composable "finite slice object: projection endpoints")
  let total x = x.total_
  let projection x = x.projection_
  let source f = f.src_
  let target f = f.tgt_
  let map f = f.map_
  let equal_object a b = F.equal_carrier a.anchor b.anchor &&
    F.equal_carrier a.total_ b.total_ && F.equal_morphism a.projection_ b.projection_

  let morphism src map tgt =
    if not (F.equal_carrier src.anchor tgt.anchor) then
      Error (Different_base "finite slice arrow: anchors")
    else if not (F.equal_carrier (F.domain map) src.total_ &&
                 F.equal_carrier (F.codomain map) tgt.total_) then
      Error (Non_composable "finite slice arrow: endpoints")
    else
      let* left = F.compose tgt.projection_ map in
      if F.equal_morphism left src.projection_ then Ok {src_=src;map_=map;tgt_=tgt}
      else Error (Non_commuting "finite slice arrow: projection square")

  let category _anchor =
    { source; target;
      ident=(fun x ->
        match morphism x (F.identity x.total_) x with
        | Ok a -> a | Error _ -> invalid_arg "finite slice identity");
      comp=(fun (g,f) ->
        if not (equal_object f.tgt_ g.src_) then Error (Non_composable "finite slice composition")
        else let* h = F.compose g.map_ f.map_ in morphism f.src_ h g.tgt_);
      equal_obj=equal_object;
      equal_arr=(fun a b -> equal_object a.src_ b.src_ && equal_object a.tgt_ b.tgt_ &&
        F.equal_morphism a.map_ b.map_) }

  type product_data = { product : slice_object; left : slice_morphism; right : slice_morphism }

  let terminal anchor =
    let* id = object_ anchor anchor (F.identity anchor) in Ok id

  let pair_value x y = F.pair x y
  let pair_parts value =
    match F.view value with
    | F.Pair (x,y) -> Ok (x,y)
    | _ -> Error (Malformed_diagram "finite slice pair value")

  let product anchor x y =
    if not (F.equal_carrier x.anchor anchor && F.equal_carrier y.anchor anchor) then
      Error (Different_base "finite slice product: anchor")
    else
      let pairs = List.concat_map (fun a ->
        List.filter_map (fun b ->
          match F.eval x.projection_ a, F.eval y.projection_ b with
          | Ok pa, Ok pb when F.equal pa pb -> Some (pair_value a b)
          | _ -> None) (F.carrier_to_list y.total_))
        (F.carrier_to_list x.total_) in
      let carrier = F.carrier_of_list pairs in
      let* proj = F.morphism_result carrier (fun v ->
        let* a,_b = pair_parts v in F.eval x.projection_ a) anchor in
      let* obj = object_ anchor carrier proj in
      let* left = F.morphism_result carrier (fun v -> let* a,_ = pair_parts v in Ok a) x.total_ in
      let* right = F.morphism_result carrier (fun v -> let* _,b = pair_parts v in Ok b) y.total_ in
      let* left = morphism obj left x in
      let* right = morphism obj right y in
      Ok {product=obj;left;right}

  let fibre object_ b =
    List.filter (fun x -> match F.eval object_.projection_ x with Ok y -> F.equal y b | Error _ -> false)
      (F.carrier_to_list object_.total_)

  let find_function fs domain codomain wanted =
    List.find_opt (fun fn -> List.for_all (fun (x,want) ->
      match T.evaluate_function domain codomain fn x with Ok y -> F.equal y want | Error _ -> false) wanted)
      (F.carrier_to_list fs)

  type exponential_data = {
    exponential : slice_object;
    evaluation : slice_morphism;
    curry : slice_object -> slice_morphism ->
      (slice_morphism, Foundations.Category.error) result;
  }

  let exponential anchor a b =
    if not (F.equal_carrier a.anchor anchor && F.equal_carrier b.anchor anchor) then
      Error (Different_base "finite slice exponential: anchor")
    else
      let bases = F.carrier_to_list anchor in
      let fibre_functions = List.map (fun z ->
        let* fs = T.function_space (F.carrier_of_list (fibre a z))
          (F.carrier_of_list (fibre b z)) in Ok (z,fs)) bases in
      let* fibre_functions = traverse (fun x -> x) fibre_functions in
      let values = List.concat_map (fun (z,fs) ->
        List.map (fun fn -> F.pair z fn) (F.carrier_to_list fs)) fibre_functions in
      let carrier = F.carrier_of_list values in
      let* proj = F.morphism_result carrier (fun value -> let* z,_ = pair_parts value in Ok z) anchor in
      let* exp = object_ anchor carrier proj in
      let* prod = product anchor a exp in
      let* eval_map = F.morphism_result (total prod.product) (fun value ->
        let* x,e = pair_parts value in
        let* z,fn = pair_parts e in
        if not (F.equal z (match F.eval a.projection_ x with Ok q -> q | Error _ -> F.terminal)) then
          Error (Outside_domain "finite slice evaluation fibre")
        else T.evaluate_function (F.carrier_of_list (fibre a z)) (F.carrier_of_list (fibre b z)) fn x)
        b.total_ in
      let* evaluation = morphism prod.product eval_map b in
      let curry r f =
        if not (F.equal_carrier (source f).anchor anchor) then
          Error (Different_base "finite slice curry: anchor")
        else
          let* pr = product anchor a r in
          if not (equal_object pr.product (source f)) then
            Error (Different_base "finite slice curry: product domain")
          else
            let* entries = traverse (fun y ->
              let* z = F.eval r.projection_ y in
              let wanted = List.map (fun x ->
                let input = F.pair x y in
                let* value = F.eval (map f) input in Ok (x,value)) (fibre a z) in
              let* wanted = traverse (fun q -> q) wanted in
              let* fs = T.function_space (F.carrier_of_list (fibre a z))
                (F.carrier_of_list (fibre b z)) in
              match find_function fs (F.carrier_of_list (fibre a z))
                (F.carrier_of_list (fibre b z)) wanted with
              | Some fn -> Ok (y,F.pair z fn)
              | None -> Error (Malformed_diagram "finite slice curry: function graph")) (F.carrier_to_list r.total_) in
            let* map = F.morphism_result r.total_ (fun y ->
              match List.find_opt (fun (q,_) -> F.equal q y) entries with
              | Some (_,value) -> Ok value
              | None -> Error (Outside_domain "finite slice curry domain")) exp.total_ in
            morphism r map exp
      in
      Ok {exponential=exp;evaluation;curry}

  type classifier = { omega : slice_object; truth : slice_morphism;
    character : slice_morphism -> (slice_morphism,error) result }

  let classifier anchor =
    let bools = [T.truth_value false; T.truth_value true] in
    let values = List.concat_map (fun b -> List.map (fun q -> F.pair b q) bools)
      (F.carrier_to_list anchor) in
    let omega_carrier = F.carrier_of_list values in
    let* omega_projection = F.morphism_result omega_carrier
      (fun value -> let* b,_ = pair_parts value in Ok b) anchor in
    let* omega = object_ anchor omega_carrier omega_projection in
    let* terminal_obj = terminal anchor in
    let* truth_map = F.morphism_result anchor (fun b -> Ok (F.pair b (T.truth_value true))) omega_carrier in
    let* truth = morphism terminal_obj truth_map omega in
    let character mono =
      let src = source mono and tgt = target mono in
      if not (F.equal_carrier src.anchor anchor && F.equal_carrier tgt.anchor anchor) then
        Error (Different_base "finite slice classifier: anchor")
      else
        let image = F.carrier_of_list (List.filter_map (fun x -> match F.eval (map mono) x with Ok y -> Some y | Error _ -> None)
          (F.carrier_to_list src.total_)) in
        if F.cardinality image <> F.cardinality src.total_ then
          Error (Malformed_diagram "finite slice classifier: monomorphism required")
        else
          let* cm = F.morphism_result tgt.total_ (fun x ->
            let* b = F.eval tgt.projection_ x in
            Ok (F.pair b (T.truth_value (F.mem x image)))) omega_carrier in
          morphism tgt cm omega
    in
    Ok {omega;truth;character}
end
