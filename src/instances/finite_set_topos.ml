module Make (F : Finite_sets.S) = struct
  module U = Finite_set_universals.Make (F)
  module C = Universal.Closed
  module T = Universal.Topos
  open Foundations.Category

  type power_object = { power_obj : F.carrier; membership : F.morphism }

  (* Distinct tags are chosen from the complete finite input snapshot.  This
     keeps generated graph values separate from admitted values without adding
     a second value universe to FinSet. *)
  let rec contains_tag tag value =
    match F.view value with
    | F.Tag (i, x) -> i = tag || contains_tag tag x
    | F.Pair (x, y) -> contains_tag tag x || contains_tag tag y
    | F.Atom _ | F.Terminal -> false

  let fresh_tag values =
    let rec choose tag =
      if List.exists (contains_tag tag) values then choose (tag + 1) else tag
    in choose 1000000

  let truth_tag = 910000
  let truth_value = function
    | true -> F.tag truth_tag (F.tag 1 F.terminal)
    | false -> F.tag truth_tag (F.tag 0 F.terminal)

  let is_true value = F.equal value (truth_value true)

  let rec all_functions domain codomain =
    match domain with
    | [] -> [ [] ]
    | x :: xs ->
      List.concat_map (fun y ->
        List.map (fun rest -> (x,y) :: rest) (all_functions xs codomain)) codomain

  let encode_graph tag entries =
    List.fold_right (fun (x,y) tail ->
      F.tag tag (F.pair (F.pair x y) tail)) entries (F.tag tag F.terminal)

  let decode_graph tag value =
    let rec loop = function
      | value when F.equal value (F.tag tag F.terminal) -> Ok []
      | value ->
        match F.view value with
        | F.Tag (i, payload) when i = tag ->
          (match F.view payload with
           | F.Pair (entry, tail) ->
             (match F.view entry with
              | F.Pair (x,y) ->
                let* rest = loop tail in Ok ((x,y) :: rest)
              | _ -> Error (Malformed_diagram "FinSet function graph entry"))
           | _ -> Error (Malformed_diagram "FinSet function graph tail"))
        | _ -> Error (Malformed_diagram "FinSet function graph tag")
    in loop value

  let function_space_with_tag a b =
    let tag = fresh_tag (F.carrier_to_list a @ F.carrier_to_list b) in
    let values = all_functions (F.carrier_to_list a) (F.carrier_to_list b) in
    Ok (F.carrier_of_list (List.map (encode_graph tag) values), tag)

  let function_space a b =
    let* values, _ = function_space_with_tag a b in Ok values

  let infer_tag fs =
    match List.find_opt (fun _ -> true) (F.carrier_to_list fs) with
    | Some value ->
      (match F.view value with
       | F.Tag (tag, _) -> Ok tag
       | _ -> Error (Malformed_diagram "FinSet function-space value"))
    | None -> Error (Malformed_diagram "FinSet empty function-space")

  let evaluate_function _domain _codomain fn x =
    let* tag = infer_tag (F.singleton fn) in
    let* entries = decode_graph tag fn in
    match List.find_opt (fun (y,_) -> F.equal x y) entries with
    | Some (_,value) -> Ok value
    | None -> Error (Outside_domain "FinSet exponential application")

  let evaluation_morphism a b fs =
    let* product, _ = U.product (a, fs) in
    let* eval = F.morphism_result product.Universal.Limits.prod_obj (fun value ->
      match F.view value with
      | F.Pair (x,fn) -> evaluate_function a b fn x
      | _ -> Error (Malformed_diagram "FinSet exponential evaluation pair")) b in
    Ok eval

  let currying_morphism a b c f =
    let* fs, tag = function_space_with_tag a b in
    let* result = F.morphism_result c (fun y ->
      let* entries = traverse (fun x ->
        let input = F.pair x y in
        let* value = F.eval f input in Ok (x,value)) (F.carrier_to_list a) in
      Ok (encode_graph tag entries)) fs in
    Ok result

  let exponential = {
    C.exponential_object = (fun a b -> function_space a b);
    eval = evaluation_morphism;
    curry = currying_morphism;
  }

  let closed = { C.cc_cat=F.cat; cc_complete=U.complete_finset; cc_exponential=exponential }

  let omega = F.carrier_of_list [truth_value true; truth_value false]

  let truth_arrow =
    let source = F.singleton F.terminal in
    match F.morphism source (fun _ -> truth_value true) omega with
    | Ok arrow -> arrow
    | Error _ -> invalid_arg "FinSet topos truth arrow"

  let classifier_character m =
    let image = F.carrier_of_list (List.filter_map (fun x ->
      match F.eval m x with Ok y -> Some y | Error _ -> None) (F.carrier_to_list (F.domain m))) in
    F.morphism (F.codomain m) (fun x -> if F.mem x image then truth_value true else truth_value false) omega

  let classifier = {
    T.omega=omega;
    truth=truth_arrow;
    character=classifier_character;
  }

  let topos = {
    T.topos_cat=F.cat;
    topos_initial=U.initial;
    topos_terminal=U.terminal;
    topos_complete=U.complete_finset;
    topos_cocomplete=U.cocomplete_finset;
    topos_product=U.product;
    topos_coproduct=U.coproduct;
    topos_equalizer=U.equalizer;
    topos_pushout=U.pushout;
    topos_closed=closed;
    topos_classifier=classifier;
  }

  let power_object a =
    let* object_, _ = function_space_with_tag a omega in
    let* product, _ = U.product (a, object_) in
    let* values = traverse (fun value ->
      match F.view value with
      | F.Pair (x,fn) ->
        let* tag = infer_tag (F.singleton fn) in
        let* entries = decode_graph tag fn in
        (match List.find_opt (fun (y,_) -> F.equal x y) entries with
         | Some (_,truth) when is_true truth -> Ok (Some value)
         | _ -> Ok None)
      | _ -> Error (Malformed_diagram "FinSet power membership pair"))
      (F.carrier_to_list product.Universal.Limits.prod_obj) in
    let carrier_set = F.carrier_of_list (List.filter_map (fun x -> x) values) in
    let* carrier = F.morphism carrier_set (fun x -> x) product.Universal.Limits.prod_obj in
    (* The carrier is a subobject of a x P(a); its inclusion is the
       membership relation used by the generic power-object construction. *)
    Ok {power_obj=object_; membership=carrier}

  let exists a =
    let* object_, _ = function_space_with_tag a omega in
    F.morphism_result object_ (fun fn ->
      let* tag = infer_tag (F.singleton fn) in
      let* entries = decode_graph tag fn in
      Ok (truth_value (List.exists (fun (_,v) -> is_true v) entries))) omega
end
