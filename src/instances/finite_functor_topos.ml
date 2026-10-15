module Make (F : Finite_sets.S) = struct
  module D = Constructions.Functor_category
  module T = Finite_set_topos.Make (F)
  open Foundations.Category

  type ('o,'a) object_ = ('o,'a,F.carrier,F.morphism) D.finite_functor
  type ('o,'a) morphism = ('o,'a,F.carrier,F.morphism) D.natural_transformation

  let ensure_discrete domain =
    let cat = D.domain_category domain in
    if List.for_all (fun a ->
      List.exists (fun o -> cat.equal_arr a (cat.ident o)) (D.objects domain))
      (D.arrows domain) then Ok ()
    else Error (Malformed_diagram "finite functor topos: source is not discrete")

  let object_map_exn f o = match D.object_map f o with
    | Ok x -> x | Error _ -> invalid_arg "finite functor topos: object map"

  let product_object domain a b =
    D.finite_functor domain F.cat
      ~objects:(fun o -> Ok (F.cartesian_prod (object_map_exn a o) (object_map_exn b o)))
      ~arrows:(fun arrow ->
        let source = D.domain_category domain |> fun c -> c.source arrow in
        Ok (F.identity (F.cartesian_prod (object_map_exn a source) (object_map_exn b source))))

  type ('o,'a) exponential = {
    object_ : ('o,'a) object_;
    evaluation : ('o,'a) morphism;
    curry : ('o,'a) object_ -> ('o,'a) morphism ->
      (('o,'a) morphism, error) result;
  }

  let exponential domain a b =
    let* () = ensure_discrete domain in
    let* e = D.finite_functor domain F.cat
      ~objects:(fun o -> T.function_space (object_map_exn a o) (object_map_exn b o))
      ~arrows:(fun arrow ->
        let c = D.domain_category domain in
        let o = c.source arrow in
        let* fs = T.function_space (object_map_exn a o) (object_map_exn b o) in
        Ok (F.identity fs)) in
    let* prod = product_object domain a e in
    let* evaluation = D.natural_transformation prod b (fun o ->
      let ao = object_map_exn a o and bo = object_map_exn b o in
      let eo = object_map_exn e o in
      T.exponential.eval ao bo eo) in
    let curry r f =
      let* expected = product_object domain a r in
      if not (D.equal_functor (D.source f) expected) then
        Error (Different_base "finite functor curry: product domain")
      else
        D.natural_transformation r e (fun o ->
          let ao = object_map_exn a o and bo = object_map_exn b o in
          let ro = object_map_exn r o in
          let* fo = D.component f o in
          T.exponential.curry ao bo ro fo)
    in
    Ok {object_=e;evaluation;curry}

  type ('o,'a) classifier = {
    omega : ('o,'a) object_;
    truth : ('o,'a) morphism;
    character : ('o,'a) morphism -> (('o,'a) morphism,error) result;
  }

  let classifier domain =
    let* () = ensure_discrete domain in
    let base = T.topos.Universal.Topos.topos_classifier in
    let* omega = D.finite_functor domain F.cat
      ~objects:(fun _ -> Ok base.omega)
      ~arrows:(fun _arrow -> Ok (F.identity base.omega)) in
    let* terminal = D.constant_functor domain F.cat (F.singleton F.terminal) in
    let* truth = D.natural_transformation terminal omega (fun _ -> Ok base.truth) in
    let character mono =
      D.natural_transformation (D.source mono) omega (fun o ->
        let* component = D.component mono o in
        base.character component)
    in
    Ok {omega;truth;character}
end
