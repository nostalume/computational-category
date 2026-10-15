(* Concrete FinSet universals and square preservation share the supplied F. *)
module Make (F : Finite_sets.S) : sig

  val initial : (F.carrier, F.morphism) Universal.Limits.initial_obj
  val isomorphisms : (F.carrier,F.morphism) Foundations.Category.iso_cat
  val coproduct : (F.carrier, F.morphism) Universal.Limits.coproduct
  val coequalizer : (F.carrier, F.morphism) Universal.Limits.coequalizer
  val coequalizer_classes :
    F.morphism * F.morphism -> (F.carrier list, Foundations.Category.error) result
  val pushout : (F.carrier, F.morphism) Universal.Limits.pushout
  val io_cp_ce_finset : (F.carrier, F.morphism) Universal.Limits.io_cp_ce_cat
  val colimit : (F.carrier, F.morphism) Universal.Limits.colimit
  val cocomplete_finset : (F.carrier, F.morphism) Universal.Limits.cocomplete_cat

  val terminal : (F.carrier, F.morphism) Universal.Limits.terminal_obj
  val product : (F.carrier, F.morphism) Universal.Limits.product
  val equalizer : (F.carrier, F.morphism) Universal.Limits.equalizer
  val io_cp_ce_dual_finset : (F.carrier, F.morphism) Universal.Limits.io_cp_ce_cat
  val limit : (F.carrier, F.morphism) Universal.Limits.limit
  val complete_finset : (F.carrier, F.morphism) Universal.Limits.complete_cat
  val pullback : (F.carrier, F.morphism) Universal.Limits.pullback

val product_functor : (F.carrier,F.morphism,F.carrier,F.morphism) Foundations.Functor.cat_functor
val product_continuous : (F.carrier,F.morphism,F.carrier,F.morphism) Universal.Preservation.continuous_functor
end = struct
open Foundations.Functor
open Universal.Preservation

  open Foundations.Category

  let isomorphisms =
    {iso_cat=F.cat;iso_inverse=(fun h ->
      let* entries = traverse (fun x -> let* y = F.eval h x in Ok (x,y)) (F.carrier_to_list (F.domain h)) in
      if F.cardinality (F.domain h)<>F.cardinality (F.codomain h) ||
        not (List.for_all (fun y -> List.length (List.filter (fun (_,z) -> F.equal y z) entries)=1)
          (F.carrier_to_list (F.codomain h))) then Ok None
      else let* k = F.morphism_result (F.codomain h) (fun y ->
        match List.find_opt (fun (_,z) -> F.equal y z) entries with
        | Some (x,_) -> Ok x | None -> Error (Outside_codomain "inverse")) (F.domain h) in
        Ok (Some k))}

  let initial =
    { Universal.Limits.init_obj = F.empty;
      init_univ = (fun a ->
        F.morphism_result F.empty
          (fun _ -> Error (Outside_domain "initial: empty source")) a) }

  let coproduct (a, b) =
    let obj = F.disjoint_union a b in
    let* left = F.morphism a (F.tag 0) obj in
    let* right = F.morphism b (F.tag 1) obj in
    let univ c f g =
      if not (has_endpoints F.cat f a c && has_endpoints F.cat g b c) then
        Error (Non_composable "coproduct mediator: leg endpoints")
      else F.morphism_result obj (fun x ->
        match F.view x with
        | F.Tag (0, v) -> F.eval f v
        | F.Tag (1, v) -> F.eval g v
        | _ -> Error (Outside_domain "coproduct mediator: labelled value")) c
    in
    Ok ({ Universal.Limits.coprod_obj = obj; coprod_inj1 = left; coprod_inj2 = right }, univ)

  let partition_data (f, g) =
    if not (parallel F.cat f g) then Error (Non_parallel "coequalizer")
    else
      let codomain = F.codomain f in
      let values = Array.of_list (F.carrier_to_list codomain) in
      let n = Array.length values in
      let parent = Array.init n (fun i -> i) in
      let rec root i =
        if parent.(i) = i then i
        else let r = root parent.(i) in parent.(i) <- r; r
      in
      let merge i j =
        let i = root i and j = root j in
        if i <> j then parent.(max i j) <- min i j
      in
      let index x =
        let rec scan i =
          if i = n then Error (Outside_codomain "coequalizer: target membership")
          else if F.equal x values.(i) then Ok i else scan (i + 1)
        in scan 0
      in
      let same_layout = F.domain f == F.domain g && F.codomain f == F.codomain g in
      let* _ =
        if same_layout then
          let rec loop k =
            if k = F.cardinality (F.domain f) then Ok ()
            else
              match F.Private.target_index_at f k, F.Private.target_index_at g k with
              | Some i, Some j -> merge i j; loop (k + 1)
              | _ -> Error (Outside_domain "coequalizer: morphism position")
          in
          loop 0
        else
          let* _ = traverse (fun x ->
            let* fx = F.eval f x in
            let* gx = F.eval g x in
            let* i = index fx in
            let* j = index gx in
            merge i j; Ok ()) (F.carrier_to_list (F.domain f)) in
          Ok () in
      (* Materialize immutable classes and routes before scratch leaves scope. *)
      let roots = Array.init n root in
      let indices = List.init n (fun i -> i) in
      let routes = List.map (fun i -> values.(i), values.(roots.(i))) indices in
      let representatives = Array.of_list (List.filter_map (fun i ->
        if roots.(i) = i then Some i else None) indices) in
      Ok (codomain, roots, routes, representatives)

  let partition pair =
    let* codomain, roots, routes, representatives = partition_data pair in
    let n = F.cardinality codomain in
    let buckets = Array.make n [] in
    for i = 0 to n - 1 do buckets.(roots.(i)) <- i :: buckets.(roots.(i)) done;
    let classes = Array.to_list representatives |> List.map (fun root ->
      F.Private.carrier_from_indices codomain (Array.of_list (List.rev buckets.(root)))) in
    Ok (classes, routes)

  let coequalizer_classes pair =
    let* classes, _ = partition pair in Ok classes

  let coequalizer ((f, g) as pair) =
    let* codomain, roots, _, representatives = partition_data pair in
    let obj = F.Private.carrier_from_indices codomain representatives in
    let representative_positions = Array.make (Array.length roots) (-1) in
    Array.iteri (fun position root -> representative_positions.(root) <- position) representatives;
    let quotient_indices = Array.map (fun root -> representative_positions.(root)) roots in
    let* q = F.Private.morphism_from_indices codomain quotient_indices obj in
    let univ c h =
      if not (has_endpoints F.cat h (F.codomain f) c) then
        Error (Non_composable "coequalizer mediator: endpoints")
      else
        let* hf = F.compose h f in
        let* hg = F.compose h g in
        if not (F.equal_morphism hf hg) then
          Error (Non_commuting "coequalizer mediator: h f <> h g")
        else F.morphism_result obj (F.eval h) c
    in
    Ok ({ Universal.Limits.coeq_obj = obj; coeq_arrow = q }, univ)

  let io_cp_ce_finset =
    { Universal.Limits.iocc_cat = F.cat; iocc_initial = initial;
      iocc_coproduct = coproduct; iocc_coequalizer = coequalizer }
  let colimit = Universal.Limits.finite_colimit io_cp_ce_finset
  let cocomplete_finset = { Universal.Limits.cc_cat = F.cat; cc_colimit = colimit }
  let pushout = Universal.Limits.pushout cocomplete_finset
  open Foundations.Category

  let terminal =
    let obj = F.singleton F.terminal in
    { Universal.Limits.term_obj = obj;
      term_univ = (fun a -> F.morphism a (fun _ -> F.terminal) obj) }

  let product (a, b) =
    let obj, left_indices, right_indices = F.Private.cartesian_prod_with_indices a b in
    let* left = F.Private.morphism_from_indices obj left_indices a in
    let* right = F.Private.morphism_from_indices obj right_indices b in
    let univ c f g =
      if not (has_endpoints F.cat f c a && has_endpoints F.cat g c b) then
        Error (Non_composable "product mediator: leg endpoints")
      else F.morphism_result c (fun x ->
        let* fx = F.eval f x in
        let* gx = F.eval g x in Ok (F.pair fx gx)) obj
    in
    Ok ({ Universal.Limits.prod_obj = obj; prod_proj1 = left; prod_proj2 = right }, univ)

  let equalizer (f, g) =
    if not (parallel F.cat f g) then Error (Non_parallel "equalizer")
    else
      let* members = traverse (fun x ->
        let* fx = F.eval f x in
        let* gx = F.eval g x in Ok (x, F.equal fx gx)) (F.carrier_to_list (F.domain f)) in
      let obj = F.carrier_of_list (List.filter_map (fun (x, keep) ->
        if keep then Some x else None) members) in
      let* inclusion = F.morphism obj (fun x -> x) (F.domain f) in
      let univ c h =
        if not (has_endpoints F.cat h c (F.domain f)) then
          Error (Non_composable "equalizer mediator: endpoints")
        else
          let* fh = F.compose f h in
          let* gh = F.compose g h in
          if not (F.equal_morphism fh gh) then
            Error (Non_commuting "equalizer mediator: f h <> g h")
          else F.morphism_result c (F.eval h) obj
      in
      Ok ({ Universal.Limits.eq_obj = obj; eq_arrow = inclusion }, univ)

  let io_cp_ce_dual_finset =
    let product pair =
      let* data, univ = product pair in
      Ok ({ Universal.Limits.coprod_obj = data.Universal.Limits.prod_obj;
            coprod_inj1 = data.Universal.Limits.prod_proj1;
            coprod_inj2 = data.Universal.Limits.prod_proj2 }, univ)
    in
    let equalizer pair =
      let* data, univ = equalizer pair in
      Ok ({ Universal.Limits.coeq_obj = data.Universal.Limits.eq_obj;
            coeq_arrow = data.Universal.Limits.eq_arrow }, univ)
    in
    { Universal.Limits.iocc_cat = dual_cat F.cat;
      iocc_initial = { Universal.Limits.init_obj = terminal.Universal.Limits.term_obj;
                      init_univ = terminal.Universal.Limits.term_univ };
      iocc_coproduct = product; iocc_coequalizer = equalizer }
  let limit = Universal.Limits.dual_colimit (Universal.Limits.finite_colimit io_cp_ce_dual_finset)
  let complete_finset = { Universal.Limits.co_cat = F.cat; co_limit = limit }
  let pullback = Universal.Limits.pullback complete_finset
  let product_functor =
    let obj_map a = F.cartesian_prod a a in
    let arr_map f =
      F.morphism_result (obj_map (F.domain f)) (fun x ->
        let open Foundations.Category in
        match F.view x with
        | F.Pair (a, b) ->
          let* fa = F.eval f a in
          let* fb = F.eval f b in Ok (F.pair fa fb)
        | _ -> Error (Outside_domain "product functor: pair expected"))
        (obj_map (F.codomain f))
    in
    { f_dom = F.cat; f_omap = (fun a -> Ok (obj_map a)); f_amap = arr_map; f_cod = F.cat }

  (* X preserves limits: project each candidate side, use the two original
     universal maps, then pair their mediators. No colimit preservation claim. *)
  let product_continuous =
    let preserve limiting =
      let open Foundations.Category in
      let original = limiting.Universal.Limits.lim_cone in
      let base = Universal.Diagrams.cone_base original in
      let* result = Universal.Diagrams.map_cone product_functor original in
      let univ other =
        let project first =
          let* sides = traverse (fun n ->
            let* side = Universal.Diagrams.cone_side other n in
            let* target = Universal.Diagrams.node_object base n in
            let* a = F.morphism_result (Universal.Diagrams.cone_apex other) (fun x ->
              let* y = F.eval side x in match F.view y with
              | F.Pair (l,r) -> Ok (if first then l else r)
              | _ -> Error (Outside_codomain "X limit: pair expected")) target in
            Ok (n,a)) (Universal.Diagrams.diagram_nodes base) in
          let* candidate = Universal.Diagrams.cone base (Universal.Diagrams.cone_apex other) ~sides in
          let* arrow = limiting.Universal.Limits.lim_univ candidate in
          Ok (Universal.Diagrams.cone_apex_arrow arrow) in
        let* left = project true in let* right = project false in
        let* arrow = F.morphism_result (Universal.Diagrams.cone_apex other) (fun x ->
          let* l = F.eval left x in let* r = F.eval right x in Ok (F.pair l r))
          (Universal.Diagrams.cone_apex result) in
        Universal.Diagrams.cone_arrow other arrow result in
      Ok {Universal.Limits.lim_cone=result;lim_univ=univ} in
    {ct_functor=product_functor;ct_map=preserve}
end
