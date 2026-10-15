module type LOGIC = sig
  type signature
  type signature_arrow
  type sentence
  type constraint_expr
  val signature_category : (signature, signature_arrow) Foundations.Category.cat
  val equal_constraints : constraint_expr -> constraint_expr -> bool
  val empty : signature -> constraint_expr
  val singleton : signature -> sentence -> (constraint_expr, Foundations.Category.error) result
  val union : constraint_expr -> constraint_expr -> constraint_expr
  val translate : signature_arrow -> constraint_expr -> (constraint_expr, Foundations.Category.error) result
  val inverse_translate : signature_arrow -> constraint_expr -> (constraint_expr, Foundations.Category.error) result
  val close : signature -> constraint_expr -> (constraint_expr, Foundations.Category.error) result
  val data : constraint_expr -> constraint_expr
  val preserves : signature_arrow -> source:constraint_expr -> target:constraint_expr ->
    (unit, Foundations.Category.error) result
  type coproduct = { sum : signature; left : signature_arrow; right : signature_arrow }
  val coproduct : signature -> signature -> (coproduct, Foundations.Category.error) result
  type pushout = { pushout : signature; leg_left : signature_arrow; leg_right : signature_arrow }
  val pushout : signature_arrow -> signature_arrow -> (pushout, Foundations.Category.error) result
end

module Make (L : LOGIC) = struct
  open Foundations.Category

  type presentation = { signature_ : L.signature; constraints_ : L.constraint_expr }
  type theory_arrow = { source_ : presentation; map_ : L.signature_arrow; target_ : presentation }

  let presentation signature constraints = {signature_=signature;constraints_=constraints}
  let signature p = p.signature_
  let constraints p = p.constraints_
  let close p =
    let* constraints = L.close p.signature_ p.constraints_ in
    Ok {p with constraints_ = constraints}

  let theory_arrow source map target =
    let* () = L.preserves map ~source:source.constraints_ ~target:target.constraints_ in
    Ok {source_=source;map_=map;target_=target}
  let arrow_source a = a.source_
  let arrow_target a = a.target_
  let arrow_map a = a.map_

  let combine left right =
    let* coprod = L.coproduct left.signature_ right.signature_ in
    let* left_constraints = L.translate coprod.left left.constraints_ in
    let* right_constraints = L.translate coprod.right right.constraints_ in
    Ok {signature_=coprod.sum;constraints_=L.union left_constraints right_constraints}

  let enrich base ~extension ~additions =
    let* translated = L.translate extension base.constraints_ in
    Ok {signature_=L.signature_category.target extension;
        constraints_=L.union translated additions}

  let parameter_apply ~requirement ~parameter ~requirement_map ~parameter_map =
    let* square = L.pushout requirement_map parameter_map in
    let* req_constraints = L.translate square.leg_left requirement.constraints_ in
    let* param_constraints = L.translate square.leg_right parameter.constraints_ in
    Ok {signature_=square.pushout;
        constraints_=L.union req_constraints param_constraints}

  let category =
    let ident p =
      {source_=p; map_=L.signature_category.ident p.signature_; target_=p} in
    let comp (g,f) =
      if not (L.equal_constraints f.target_.constraints_ g.source_.constraints_) ||
         not (L.signature_category.equal_obj f.target_.signature_ g.source_.signature_) then
        Error (Non_composable "presentation arrow: middle object")
      else
        let* map = compose L.signature_category g.map_ f.map_ in
        theory_arrow f.source_ map g.target_ in
    {source=arrow_source;target=arrow_target;ident;comp;
     equal_obj=(fun a b ->
       L.signature_category.equal_obj a.signature_ b.signature_ &&
       L.equal_constraints a.constraints_ b.constraints_);
     equal_arr=(fun a b ->
       L.signature_category.equal_arr a.map_ b.map_ &&
       L.signature_category.equal_obj a.source_.signature_ b.source_.signature_ &&
       L.signature_category.equal_obj a.target_.signature_ b.target_.signature_ &&
       L.equal_constraints a.source_.constraints_ b.source_.constraints_ &&
       L.equal_constraints a.target_.constraints_ b.target_.constraints_)}
end
