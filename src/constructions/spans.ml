(* Spans retain witnesses; the finite relation image is a separate projection. *)
type ('o, 'a) span = {
  sp_src_set : 'o;
  sp_arrow1 : 'a;
  sp_arrow2 : 'a;
}

let span cat left right =
  let source = cat.Foundations.Category.source left in
  if cat.Foundations.Category.equal_obj source (cat.Foundations.Category.source right) then
    Ok { sp_src_set = source; sp_arrow1 = left; sp_arrow2 = right }
  else Error (Foundations.Category.Malformed_relation "span: legs need a common source")

let span_source s = s.sp_src_set
let span_left s = s.sp_arrow1
let span_right s = s.sp_arrow2

let identity cat obj =
  let arrow = cat.Foundations.Category.ident obj in
  { sp_src_set = obj; sp_arrow1 = arrow; sp_arrow2 = arrow }

(* next after previous, matching categorical composition order. *)
let compose complete next previous =
  let open Foundations.Category in
  let cat = complete.Universal.Limits.co_cat in
  if not (cat.equal_obj (cat.target previous.sp_arrow2) (cat.target next.sp_arrow1)) then
    Error (Non_composable "span composition: intermediate endpoints")
  else
    let* pb, _ = Universal.Limits.pullback complete (previous.sp_arrow2, next.sp_arrow1) in
    let* left = Foundations.Category.compose cat previous.sp_arrow1 pb.Universal.Limits.pullback_proj1 in
    let* right = Foundations.Category.compose cat next.sp_arrow2 pb.Universal.Limits.pullback_proj2 in
    span cat left right

