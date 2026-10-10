open Foundations.Category
open Diagrams
(* Primitive universal capability contracts. Semantic failures use Foundations.Category.error;
   supplied categories and capabilities remain lawful caller premises. *)
type ('o, 'a) initial_obj = {
  init_obj : 'o;
  init_univ : 'o -> ('a, Foundations.Category.error) result;
}
type ('o, 'a) terminal_obj = {
  term_obj : 'o;
  term_univ : 'o -> ('a, Foundations.Category.error) result;
}
type ('o, 'a) coproduct_data = {
  coprod_obj : 'o; coprod_inj1 : 'a; coprod_inj2 : 'a;
}
type ('o, 'a) coproduct =
  'o * 'o ->
  (('o, 'a) coproduct_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) product_data = {
  prod_obj : 'o; prod_proj1 : 'a; prod_proj2 : 'a;
}
type ('o, 'a) product =
  'o * 'o ->
  (('o, 'a) product_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) coequalizer_data = { coeq_obj : 'o; coeq_arrow : 'a }
type ('o, 'a) coequalizer =
  'a * 'a ->
  (('o, 'a) coequalizer_data *
   ('o -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) equalizer_data = { eq_obj : 'o; eq_arrow : 'a }
type ('o, 'a) equalizer =
  'a * 'a ->
  (('o, 'a) equalizer_data *
   ('o -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) pushout_data = {
  pushout_obj : 'o; pushout_leg1 : 'a; pushout_leg2 : 'a;
}
type ('o, 'a) pushout =
  'a * 'a ->
  (('o, 'a) pushout_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) pullback_data = {
  pullback_obj : 'o; pullback_proj1 : 'a; pullback_proj2 : 'a;
}
type ('o, 'a) pullback =
  'a * 'a ->
  (('o, 'a) pullback_data *
   ('o -> 'a -> 'a -> ('a, Foundations.Category.error) result), Foundations.Category.error) result
type ('o, 'a) io_cp_ce_cat = {
  iocc_cat : ('o, 'a) Foundations.Category.cat;
  iocc_initial : ('o, 'a) initial_obj;
  iocc_coproduct : ('o, 'a) coproduct;
  iocc_coequalizer : ('o, 'a) coequalizer;
}

let iso_initial a b =
  let open Foundations.Category in
  let* f = a.init_univ b.init_obj in
  let* g = b.init_univ a.init_obj in
  Ok (f, g)
type ('o, 'a) colimiting_cocone = {
  colim_cocone : ('o, 'a) cocone;
  colim_univ : ('o, 'a) cocone -> (('o, 'a) cocone_arrow, error) result;
}
type ('o, 'a) colimit =
  ('o, 'a) diagram -> (('o, 'a) colimiting_cocone, error) result
type ('o, 'a) cocomplete_cat = {
  cc_cat : ('o, 'a) cat; cc_colimit : ('o, 'a) colimit;
}
type ('o, 'a) limiting_cone = {
  lim_cone : ('o, 'a) cone;
  lim_univ : ('o, 'a) cone -> (('o, 'a) cone_arrow, error) result;
}
type ('o, 'a) limit =
  ('o, 'a) diagram -> (('o, 'a) limiting_cone, error) result
type ('o, 'a) complete_cat = {
  co_cat : ('o, 'a) cat; co_limit : ('o, 'a) limit;
}

let rec finite_coproduct caps d =
  let cat = caps.iocc_cat in
  match (diagram_nodes d) with
  | [] ->
    let init = caps.iocc_initial in
    let* result = cocone d init.init_obj ~sides:[] in
    let univ other =
      if not (same_base d (cocone_base other)) then Error (Different_base "empty colimit")
      else
        let* arrow = init.init_univ (cocone_apex other) in
        cocone_arrow result arrow other
    in Ok { colim_cocone = result; colim_univ = univ }
  | node :: nodes ->
    let rest = discrete_tail d in
    let* tail = finite_coproduct caps rest in
    let* obj = node_object d node in
    let* cp, fold = caps.iocc_coproduct (obj, (cocone_apex tail.colim_cocone)) in
    let* sides = traverse (fun (n, a) ->
      let* b = compose cat cp.coprod_inj2 a in Ok (n, b))
      (cocone_sides tail.colim_cocone) in
    let* result = cocone d cp.coprod_obj
      ~sides:((node, cp.coprod_inj1) :: sides) in
    let univ other =
      if not (same_base d (cocone_base other)) then Error (Different_base "finite coproduct")
      else
        let* restricted = cocone rest (cocone_apex other)
          ~sides:(List.filter (fun (n, _) -> List.mem n nodes) (cocone_sides other)) in
        let* tail_arrow = tail.colim_univ restricted in
        let* head_arrow = cocone_side other node in
        let* arrow = fold (cocone_apex other) head_arrow (cocone_apex_arrow tail_arrow) in
        cocone_arrow result arrow other
    in Ok { colim_cocone = result; colim_univ = univ }

let rec finite_colimit caps d =
  let cat = caps.iocc_cat in
  match (graph_bindings (diagram_graph d)) with
  | [] -> finite_coproduct caps d
  | (edge, source, target) :: _edges ->
    let rest = without_first_edge d in
    let* previous = finite_colimit caps rest in
    let* left = cocone_side previous.colim_cocone source in
    let* target_side = cocone_side previous.colim_cocone target in
    let* f = edge_arrow d edge in
    let* right = compose cat target_side f in
    let* ce, factor = caps.iocc_coequalizer (left, right) in
    let* sides = traverse (fun (n, a) ->
      let* b = compose cat ce.coeq_arrow a in Ok (n, b))
      (cocone_sides previous.colim_cocone) in
    let* result = cocone d ce.coeq_obj ~sides in
    let univ other =
      if not (same_base d (cocone_base other)) then Error (Different_base ("colimit edge " ^ edge))
      else
        let* restricted = cocone rest (cocone_apex other) ~sides:(cocone_sides other) in
        let* previous_arrow = previous.colim_univ restricted in
        let* arrow = factor (cocone_apex other) (cocone_apex_arrow previous_arrow) in
        cocone_arrow result arrow other
    in Ok { colim_cocone = result; colim_univ = univ }

let dual_colimit colimit d =
  let* cc = colimit (dual_diagram d) in
  let result = dual_cocone cc.colim_cocone in
  let univ other =
    let* arrow = cc.colim_univ (dual_cone other) in
    (* Admission restores the requested input/output cones and verifies direction. *)
    cone_arrow other (cocone_apex_arrow arrow) result
  in Ok { lim_cone = result; lim_univ = univ }

let dual_limit limit d =
  let* co = limit (dual_diagram d) in
  let result = dual_cone co.lim_cone in
  let univ other =
    let* arrow = co.lim_univ (dual_cocone other) in
    cocone_arrow result (cone_apex_arrow arrow) other
  in Ok { colim_cocone = result; colim_univ = univ }

let pushout caps (f, g) =
  let cat = caps.cc_cat in
  if not (cat.equal_obj (cat.source f) (cat.source g)) then
    Error (Non_composable "pushout: common source")
  else
    let* shape = graph ~nodes:["a"; "b"; "c"]
      ~edges:["f", "a", "b"; "g", "a", "c"] in
    let* base = diagram cat shape
      ~objects:["a", cat.source f; "b", cat.target f; "c", cat.target g]
      ~arrows:["f", f; "g", g] in
    let* result = caps.cc_colimit base in
    let cc = result.colim_cocone in
    let* p = cocone_side cc "b" in
    let* q = cocone_side cc "c" in
    let univ x h k =
      if not (has_endpoints cat h (cat.target f) x &&
              has_endpoints cat k (cat.target g) x) then
        Error (Non_composable "pushout mediator: leg endpoints")
      else
        let* a = compose cat h f in
        let* other = cocone base x ~sides:["a", a; "b", h; "c", k] in
        let* arrow = result.colim_univ other in Ok (cocone_apex_arrow arrow)
    in Ok ({ pushout_obj = (cocone_apex cc);
             pushout_leg1 = p; pushout_leg2 = q }, univ)

let pullback caps (f, g) =
  let cat = caps.co_cat in
  if not (cat.equal_obj (cat.target f) (cat.target g)) then
    Error (Non_composable "pullback: common target")
  else
    let* shape = graph ~nodes:["a"; "b"; "c"]
      ~edges:["f", "a", "c"; "g", "b", "c"] in
    let* base = diagram cat shape
      ~objects:["a", cat.source f; "b", cat.source g; "c", cat.target f]
      ~arrows:["f", f; "g", g] in
    let* result = caps.co_limit base in
    let co = result.lim_cone in
    let* p = cone_side co "a" in
    let* q = cone_side co "b" in
    let univ x h k =
      if not (has_endpoints cat h x (cat.source f) &&
              has_endpoints cat k x (cat.source g)) then
        Error (Non_composable "pullback mediator: leg endpoints")
      else
        let* c = compose cat f h in
        let* other = cone base x ~sides:["a", h; "b", k; "c", c] in
        let* arrow = result.lim_univ other in Ok (cone_apex_arrow arrow)
    in Ok ({ pullback_obj = (cone_apex co);
             pullback_proj1 = p; pullback_proj2 = q }, univ)

(* Fixed-shape diagram morphisms and variable-base cone/cocone morphisms.
   These are different from the fixed-base universal arrows above. *)
let map_colimit base source target =
  let cat = (diagram_category (diagram_arrow_domain base)) in
  let* sides = traverse (fun n ->
    let* u = diagram_component base n in
    let* t = cocone_side target.colim_cocone n in
    let* a = compose cat t u in Ok (n,a)) (diagram_nodes (diagram_arrow_domain base)) in
  let* candidate = cocone (diagram_arrow_domain base) (cocone_apex target.colim_cocone) ~sides in
  let* universal = source.colim_univ candidate in
  cocone_map source.colim_cocone base (cocone_apex_arrow universal) target.colim_cocone
let map_limit base source target =
  let cat = (diagram_category (diagram_arrow_domain base)) in
  let* sides = traverse (fun n ->
    let* u = diagram_component base n in
    let* s = cone_side source.lim_cone n in
    let* a = compose cat u s in Ok (n,a)) (diagram_nodes (diagram_arrow_codomain base)) in
  let* candidate = cone (diagram_arrow_codomain base) (cone_apex source.lim_cone) ~sides in
  let* universal = target.lim_univ candidate in
  cone_map source.lim_cone base (cone_apex_arrow universal) target.lim_cone

let coproduct caps (a,b) =
  let* shape = graph ~nodes:["a";"b"] ~edges:[] in
  let* d = diagram caps.cc_cat shape ~objects:["a",a;"b",b] ~arrows:[] in
  let* result = caps.cc_colimit d in
  let c = result.colim_cocone in
  let* left = cocone_side c "a" in let* right = cocone_side c "b" in
  let univ apex f g =
    let* other = cocone d apex ~sides:["a",f;"b",g] in
    let* arrow = result.colim_univ other in Ok (cocone_apex_arrow arrow) in
  Ok ({coprod_obj=(cocone_apex c);coprod_inj1=left;coprod_inj2=right},univ)
let product caps (a,b) =
  let* shape = graph ~nodes:["a";"b"] ~edges:[] in
  let* d = diagram caps.co_cat shape ~objects:["a",a;"b",b] ~arrows:[] in
  let* result = caps.co_limit d in
  let c = result.lim_cone in
  let* left = cone_side c "a" in let* right = cone_side c "b" in
  let univ apex f g =
    let* other = cone d apex ~sides:["a",f;"b",g] in
    let* arrow = result.lim_univ other in Ok (cone_apex_arrow arrow) in
  Ok ({prod_obj=(cone_apex c);prod_proj1=left;prod_proj2=right},univ)
let dual_colimiting c =
  {lim_cone=Diagrams.dual_cocone c.colim_cocone;
   lim_univ=(fun other -> let open Foundations.Category in
     let* a = c.colim_univ (Diagrams.dual_cone other) in
     Ok (Diagrams.dual_cocone_arrow a))}
let dual_limiting c =
  {colim_cocone=Diagrams.dual_cone c.lim_cone;
   colim_univ=(fun other -> let open Foundations.Category in
     let* a = c.lim_univ (Diagrams.dual_cocone other) in
     Ok (Diagrams.dual_cone_arrow a))}
(* Operational fixed-shape free/cofree objects, not an encoding of the entire
   higher universe Cat or a certificate of its 2-functor laws. *)
module Free = struct
  type ('d,'da,'c,'ca) colimit_structure = {
    diagrams:('d,'da) cat;cocones:('c,'ca) cat;
    base_object:'c -> 'd;base_arrow:'ca -> 'da;
    free:'d -> ('c * 'da * ('c -> 'da -> ('ca,error) result),error) result;
  }
  let fixed_colimit cat shape colimit =
    let diagrams = Diagrams.diagrams_category cat shape in
    let cocones = Diagrams.total_cocone_category cat shape in
    let free d =
      let* c = colimit d in
      let factor other base =
        if not (has_endpoints diagrams base d (Diagrams.cocone_base other)) then
          Error (Different_base "abstract colimit: base morphism")
        else
          let* sides = traverse (fun n ->
            let* a = Diagrams.diagram_component base n in
            let* b = Diagrams.cocone_side other n in
            let* u = compose cat b a in Ok (n,u)) (Diagrams.diagram_nodes d) in
          let* candidate = Diagrams.cocone d (Diagrams.cocone_apex other) ~sides in
          let* u = c.colim_univ candidate in
          Diagrams.cocone_map c.colim_cocone base (Diagrams.cocone_apex_arrow u) other in
      Ok (c.colim_cocone,diagrams.ident d,factor) in
    {diagrams;cocones;base_object=Diagrams.cocone_base;base_arrow=Diagrams.cocone_map_base;free}
end
module Cofree = struct
  type ('d,'da,'c,'ca) limit_structure = {
    limit_diagrams:('d,'da) cat;cones:('c,'ca) cat;
    cone_base:'c -> 'd;cone_base_arrow:'ca -> 'da;
    cofree:'d -> ('c * 'da * ('c -> 'da -> ('ca,error) result),error) result;
  }
  let fixed_limit cat shape limit =
    let limit_diagrams = Diagrams.diagrams_category cat shape in
    let cones = Diagrams.total_cone_category cat shape in
    let cofree d =
      let* c = limit d in
      let factor other base =
        if not (has_endpoints limit_diagrams base (Diagrams.cone_base other) d) then
          Error (Different_base "abstract limit: base morphism")
        else
          let* sides = traverse (fun n ->
            let* a = Diagrams.diagram_component base n in
            let* b = Diagrams.cone_side other n in
            let* u = compose cat a b in Ok (n,u)) (Diagrams.diagram_nodes d) in
          let* candidate = Diagrams.cone d (Diagrams.cone_apex other) ~sides in
          let* u = c.lim_univ candidate in
          Diagrams.cone_map other base (Diagrams.cone_apex_arrow u) c.lim_cone in
      Ok (c.lim_cone,limit_diagrams.ident d,factor) in
    {limit_diagrams;cones;cone_base=Diagrams.cone_base;cone_base_arrow=Diagrams.cone_map_base;cofree}

end
