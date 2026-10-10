module Make (F : Finite_sets.S) = struct
  let relation_span ~left ~right carrier =
    let open Foundations.Category in
    let* entries = traverse (fun (index, value) ->
      let context = "relation pair " ^ string_of_int index ^ ": " in
      match F.view value with
      | F.Pair (x, y) ->
        if not (F.member x left) then Error (Malformed_relation (context ^ "left component outside endpoint"))
        else if not (F.member y right) then Error (Malformed_relation (context ^ "right component outside endpoint"))
        else Ok (value, x, y)
      | _ -> Error (Malformed_relation (context ^ "pair expected")))
      (List.mapi (fun i value -> i, value) (F.to_list carrier)) in
    (* Both frozen projection maps consume the same admitted pair entries. *)
    let make_projection select target =
      F.arrow_result carrier (fun value ->
        match List.find_opt (fun (v, _, _) -> F.equal value v) entries with
        | Some entry -> Ok (select entry)
        | None -> Error (Outside_domain "relation projection: carrier value")) target
    in
    let* l = make_projection (fun (_, x, _) -> x) left in
    let* r = make_projection (fun (_, _, y) -> y) right in
    Constructions.Spans.span F.cat l r

  let image s =
    let open Foundations.Category in
    let* values = traverse (fun witness ->
      let* x = F.apply (Constructions.Spans.span_left s) witness in
      let* y = F.apply (Constructions.Spans.span_right s) witness in
      Ok (F.pair x y)) (F.to_list (Constructions.Spans.span_source s)) in
    Ok (F.of_list values)
end
