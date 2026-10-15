open Foundations.Functor
type ('oa,'aa,'ob,'ab) continuous_functor = {
  ct_functor : ('oa,'aa,'ob,'ab) cat_functor;
  ct_map : ('oa,'aa) Limits.limiting_cone ->
    (('ob,'ab) Limits.limiting_cone,Foundations.Category.error) result;
}

type ('oa, 'aa, 'ob, 'ab) cocontinuous_functor = {
  cc_functor : ('oa, 'aa, 'ob, 'ab) cat_functor;
  cc_map : ('oa, 'aa) Limits.colimiting_cocone ->
    (('ob, 'ab) Limits.colimiting_cocone, Foundations.Category.error) result;
}

let id_cocontinuous_functor c =
  { cc_functor = id_functor c; cc_map = (fun cc -> Ok cc) }

let id_continuous_functor c =
  {ct_functor=id_functor c;ct_map=(fun limit -> Ok limit)}
let dual_continuous f =
  {cc_functor=dual_functor f.ct_functor;
   cc_map=(fun c -> let open Foundations.Category in
     let* l = f.ct_map (Limits.dual_colimiting c) in Ok (Limits.dual_limiting l))}

(* Forward/backward are mutually inverse lawful functors, extensionally under
   their dictionaries. The builds check transported endpoints and triangles. *)
let transport_colimit forward backward colimit d =
  let open Foundations.Category in
  let* mapped = Diagrams.map_diagram forward d in
  let* result = colimit mapped in
  let* cocone = Diagrams.map_cocone backward result.Limits.colim_cocone in
  if not (Diagrams.same_base d (Diagrams.cocone_base cocone)) then
    Error (Different_base "colimit transport: inverse base")
  else
    let univ other =
      let* image = Diagrams.map_cocone forward other in
      let* u = result.Limits.colim_univ image in
      let* a = backward.f_amap (Diagrams.cocone_apex_arrow u) in
      Diagrams.cocone_arrow cocone a other in
    Ok {Limits.colim_cocone=cocone;colim_univ=univ}

(* Proposition 9: transpose a candidate cocone, factor through the original
   colimit, then transpose its mediator. Uniqueness uses the supplied adjunction
   bijection and the original universal property, not another colimit search. *)
let adjoint_cocontinuous adj =
  let left = Adjunction.left adj and right = Adjunction.right adj in
  let preserve colimit =
    let open Foundations.Category in
    let original = colimit.Limits.colim_cocone in
    let base = Diagrams.cocone_base original in
    let* mapped = Diagrams.map_cocone left original in
    let univ other =
      if not (Diagrams.same_base (Diagrams.cocone_base mapped) (Diagrams.cocone_base other)) then
        Error (Different_base "adjoint colimit preservation")
      else
        let* image = Diagrams.map_cocone right other in
        let* sides = traverse (fun n ->
          let* o = Diagrams.node_object base n in
          let* eta = natural_component (Adjunction.unit adj) o in
          let* side = Diagrams.cocone_side image n in
          let* leg = compose right.f_cod side eta in Ok (n,leg)) (Diagrams.diagram_nodes base) in
        let* candidate = Diagrams.cocone base (Diagrams.cocone_apex image) ~sides in
        let* u = colimit.Limits.colim_univ candidate in
        let* factor = Adjunction.transpose adj (Diagrams.cocone_apex original)
          (Diagrams.cocone_apex other) (Diagrams.cocone_apex_arrow u) in
        Diagrams.cocone_arrow mapped factor other in
    Ok {Limits.colim_cocone=mapped;colim_univ=univ} in
  {cc_functor=left;cc_map=preserve}

let adjoint_continuous adj =
  let dual = adjoint_cocontinuous (Adjunction.dual adj) in
  {ct_functor=Adjunction.right adj;
   ct_map=(fun limit -> let open Foundations.Category in
     let* c = dual.cc_map (Limits.dual_limiting limit) in Ok (Limits.dual_colimiting c))}

(* Recompute the image colimit, then check its comparison map is invertible.
   A failed comparison is not a preservation proof. This trades computation
   for an explicit preservation implementation using existing universals. *)
let by_comparison f target isomorphisms =
  let preserve original =
    let open Foundations.Category in
    let* mapped = Diagrams.map_cocone f original.Limits.colim_cocone in
    let* chosen = target.Limits.cc_colimit (Diagrams.cocone_base mapped) in
    let* comparison = chosen.Limits.colim_univ mapped in
    let* inverse = inverse isomorphisms (Diagrams.cocone_apex_arrow comparison) in
    match inverse with
    | None -> Error (Non_commuting "colimit comparison not invertible")
    | Some inverse ->
      let univ other =
        if not (Diagrams.same_base (Diagrams.cocone_base mapped) (Diagrams.cocone_base other)) then
          Error (Different_base "colimit comparison") else
        let* u = chosen.Limits.colim_univ other in
        let* h = compose f.f_cod (Diagrams.cocone_apex_arrow u) inverse in
        Diagrams.cocone_arrow mapped h other in
      Ok {Limits.colim_cocone=mapped;colim_univ=univ} in
  {cc_functor=f;cc_map=preserve}
