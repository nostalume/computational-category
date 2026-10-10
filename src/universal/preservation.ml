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
