(* Concrete FinSet universals and square preservation share the supplied F. *)
module Make (F : Finite_sets.S) : sig

  val set_initial : (F.set, F.arrow) Universal.Limits.initial_obj
  val set_coproduct : (F.set, F.arrow) Universal.Limits.coproduct
  val set_coequalizer : (F.set, F.arrow) Universal.Limits.coequalizer
  val set_coequalizer_classes :
    F.arrow * F.arrow -> (F.set list, Foundations.Category.error) result
  val set_pushout : (F.set, F.arrow) Universal.Limits.pushout
  val io_cp_ce_finset : (F.set, F.arrow) Universal.Limits.io_cp_ce_cat
  val set_colimit : (F.set, F.arrow) Universal.Limits.colimit
  val cocomplete_finset : (F.set, F.arrow) Universal.Limits.cocomplete_cat

  val set_terminal : (F.set, F.arrow) Universal.Limits.terminal_obj
  val set_product : (F.set, F.arrow) Universal.Limits.product
  val set_equalizer : (F.set, F.arrow) Universal.Limits.equalizer
  val io_cp_ce_dual_finset : (F.set, F.arrow) Universal.Limits.io_cp_ce_cat
  val set_limit : (F.set, F.arrow) Universal.Limits.limit
  val complete_finset : (F.set, F.arrow) Universal.Limits.complete_cat
  val set_pullback : (F.set, F.arrow) Universal.Limits.pullback

val product_functor : (F.set,F.arrow,F.set,F.arrow) Foundations.Functor.cat_functor
val product_continuous : (F.set,F.arrow,F.set,F.arrow) Universal.Preservation.continuous_functor
end = struct
open Foundations.Functor
open Universal.Preservation

  open Foundations.Category

  let set_initial =
    { Universal.Limits.init_obj = F.emptyset;
      init_univ = (fun a ->
        F.arrow_result F.emptyset
          (fun _ -> Error (Outside_domain "initial: empty source")) a) }

  let set_coproduct (a, b) =
    let obj = F.disjoint_union a b in
    let* left = F.arrow a (F.tag 0) obj in
    let* right = F.arrow b (F.tag 1) obj in
    let univ c f g =
      if not (has_endpoints F.cat f a c && has_endpoints F.cat g b c) then
        Error (Non_composable "coproduct mediator: leg endpoints")
      else F.arrow_result obj (fun x ->
        match F.view x with
        | F.Tag (0, v) -> F.apply f v
        | F.Tag (1, v) -> F.apply g v
        | _ -> Error (Outside_domain "coproduct mediator: labelled value")) c
    in
    Ok ({ Universal.Limits.coprod_obj = obj; coprod_inj1 = left; coprod_inj2 = right }, univ)

  let partition (f, g) =
    if not (parallel F.cat f g) then Error (Non_parallel "coequalizer")
    else
      let values = Array.of_list (F.to_list (F.target f)) in
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
      let* _ = traverse (fun x ->
        let* fx = F.apply f x in
        let* gx = F.apply g x in
        let* i = index fx in
        let* j = index gx in
        merge i j; Ok ()) (F.to_list (F.source f)) in
      (* Materialize immutable classes and routes before scratch leaves scope. *)
      let roots = Array.init n root in
      let indices = List.init n (fun i -> i) in
      let classes = List.filter_map (fun i ->
        if roots.(i) <> i then None
        else Some (F.of_list (List.filter_map (fun j ->
          if roots.(j) = i then Some values.(j) else None) indices))) indices in
      let routes = List.map (fun i -> values.(i), values.(roots.(i))) indices in
      Ok (classes, routes)

  let set_coequalizer_classes pair =
    let* classes, _ = partition pair in Ok classes

  let set_coequalizer ((f, g) as pair) =
    let* _, routes = partition pair in
    let obj = F.of_list (List.map snd routes) in
    let* q = F.arrow_result (F.target f) (fun x ->
      match List.find_opt (fun (v, _) -> F.equal v x) routes with
      | Some (_, rep) -> Ok rep
      | None -> Error (Outside_domain "coequalizer: quotient input")) obj in
    let univ c h =
      if not (has_endpoints F.cat h (F.target f) c) then
        Error (Non_composable "coequalizer mediator: endpoints")
      else
        let* hf = F.compose h f in
        let* hg = F.compose h g in
        if not (F.equal_arrow hf hg) then
          Error (Non_commuting "coequalizer mediator: h f <> h g")
        else F.arrow_result obj (F.apply h) c
    in
    Ok ({ Universal.Limits.coeq_obj = obj; coeq_arrow = q }, univ)

  let io_cp_ce_finset =
    { Universal.Limits.iocc_cat = F.cat; iocc_initial = set_initial;
      iocc_coproduct = set_coproduct; iocc_coequalizer = set_coequalizer }
  let set_colimit = Universal.Limits.finite_colimit io_cp_ce_finset
  let cocomplete_finset = { Universal.Limits.cc_cat = F.cat; cc_colimit = set_colimit }
  let set_pushout = Universal.Limits.pushout cocomplete_finset
  open Foundations.Category

  let set_terminal =
    let obj = F.singleton F.terminal in
    { Universal.Limits.term_obj = obj;
      term_univ = (fun a -> F.arrow a (fun _ -> F.terminal) obj) }

  let set_product (a, b) =
    let obj = F.cartesian_prod a b in
    let* left = F.arrow_result obj (fun x -> match F.view x with
      | F.Pair (v, _) -> Ok v
      | _ -> Error (Outside_domain "product: pair expected")) a in
    let* right = F.arrow_result obj (fun x -> match F.view x with
      | F.Pair (_, v) -> Ok v
      | _ -> Error (Outside_domain "product: pair expected")) b in
    let univ c f g =
      if not (has_endpoints F.cat f c a && has_endpoints F.cat g c b) then
        Error (Non_composable "product mediator: leg endpoints")
      else F.arrow_result c (fun x ->
        let* fx = F.apply f x in
        let* gx = F.apply g x in Ok (F.pair fx gx)) obj
    in
    Ok ({ Universal.Limits.prod_obj = obj; prod_proj1 = left; prod_proj2 = right }, univ)

  let set_equalizer (f, g) =
    if not (parallel F.cat f g) then Error (Non_parallel "equalizer")
    else
      let* members = traverse (fun x ->
        let* fx = F.apply f x in
        let* gx = F.apply g x in Ok (x, F.equal fx gx)) (F.to_list (F.source f)) in
      let obj = F.of_list (List.filter_map (fun (x, keep) ->
        if keep then Some x else None) members) in
      let* inclusion = F.arrow obj (fun x -> x) (F.source f) in
      let univ c h =
        if not (has_endpoints F.cat h c (F.source f)) then
          Error (Non_composable "equalizer mediator: endpoints")
        else
          let* fh = F.compose f h in
          let* gh = F.compose g h in
          if not (F.equal_arrow fh gh) then
            Error (Non_commuting "equalizer mediator: f h <> g h")
          else F.arrow_result c (F.apply h) obj
      in
      Ok ({ Universal.Limits.eq_obj = obj; eq_arrow = inclusion }, univ)

  let io_cp_ce_dual_finset =
    let product pair =
      let* data, univ = set_product pair in
      Ok ({ Universal.Limits.coprod_obj = data.Universal.Limits.prod_obj;
            coprod_inj1 = data.Universal.Limits.prod_proj1;
            coprod_inj2 = data.Universal.Limits.prod_proj2 }, univ)
    in
    let equalizer pair =
      let* data, univ = set_equalizer pair in
      Ok ({ Universal.Limits.coeq_obj = data.Universal.Limits.eq_obj;
            coeq_arrow = data.Universal.Limits.eq_arrow }, univ)
    in
    { Universal.Limits.iocc_cat = dual_cat F.cat;
      iocc_initial = { Universal.Limits.init_obj = set_terminal.Universal.Limits.term_obj;
                      init_univ = set_terminal.Universal.Limits.term_univ };
      iocc_coproduct = product; iocc_coequalizer = equalizer }
  let set_limit = Universal.Limits.dual_colimit (Universal.Limits.finite_colimit io_cp_ce_dual_finset)
  let complete_finset = { Universal.Limits.co_cat = F.cat; co_limit = set_limit }
  let set_pullback = Universal.Limits.pullback complete_finset
  let product_functor =
    let obj_map a = F.cartesian_prod a a in
    let arr_map f =
      F.arrow_result (obj_map (F.source f)) (fun x ->
        let open Foundations.Category in
        match F.view x with
        | F.Pair (a, b) ->
          let* fa = F.apply f a in
          let* fb = F.apply f b in Ok (F.pair fa fb)
        | _ -> Error (Outside_domain "product functor: pair expected"))
        (obj_map (F.target f))
    in
    { f_dom = F.cat; f_omap = obj_map; f_amap = arr_map; f_cod = F.cat }

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
            let* a = F.arrow_result (Universal.Diagrams.cone_apex other) (fun x ->
              let* y = F.apply side x in match F.view y with
              | F.Pair (l,r) -> Ok (if first then l else r)
              | _ -> Error (Outside_codomain "X limit: pair expected")) target in
            Ok (n,a)) (Universal.Diagrams.diagram_nodes base) in
          let* candidate = Universal.Diagrams.cone base (Universal.Diagrams.cone_apex other) ~sides in
          let* arrow = limiting.Universal.Limits.lim_univ candidate in
          Ok (Universal.Diagrams.cone_apex_arrow arrow) in
        let* left = project true in let* right = project false in
        let* arrow = F.arrow_result (Universal.Diagrams.cone_apex other) (fun x ->
          let* l = F.apply left x in let* r = F.apply right x in Ok (F.pair l r))
          (Universal.Diagrams.cone_apex result) in
        Universal.Diagrams.cone_arrow other arrow result in
      Ok {Universal.Limits.lim_cone=result;lim_univ=univ} in
    {ct_functor=product_functor;ct_map=preserve}
end
