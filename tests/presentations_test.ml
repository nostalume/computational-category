open Computational_category
open Category_test_support.Checks
open Foundations.Category
module P = Constructions.Presentations

module Logic = struct
  type signature = string
  type signature_arrow = { src : string; dst : string; label : string }
  type sentence = string
  type constraint_expr = string list
  let signature_category =
    { Foundations.Category.source=(fun a -> a.src);
      target=(fun a -> a.dst);
      ident=(fun s -> {src=s;dst=s;label="id"});
      equal_obj=String.equal;
      equal_arr=(fun a b -> String.equal a.src b.src && String.equal a.dst b.dst && String.equal a.label b.label);
      comp=(fun (g,f) ->
        if String.equal f.dst g.src then Ok {src=f.src;dst=g.dst;label=f.label ^ "." ^ g.label}
        else Error (Foundations.Category.Non_composable "logic arrow")) }
  let equal_constraints a b =
    List.length a = List.length b && List.for_all (fun x -> List.mem x b) a
  let empty _ = []
  let singleton _ sentence = Ok [sentence]
  let union a b = List.sort_uniq String.compare (a @ b)
  let translate arrow expr = Ok (List.map (fun sentence -> arrow.label ^ ":" ^ sentence) expr)
  let inverse_translate _ expr = Ok expr
  let close _ expr = Ok (union expr [])
  let data expr = List.map (fun x -> "data:" ^ x) expr
  let preserves arrow ~source ~target =
    let* translated = translate arrow source in
    if List.for_all (fun x -> List.mem x target) translated then Ok ()
    else Error (Foundations.Category.Non_commuting "constraint preservation")
  type coproduct = {sum:signature;left:signature_arrow;right:signature_arrow}
  let coproduct left right =
    let sum = left ^ "+" ^ right in
    Ok {sum;left={src=left;dst=sum;label="L"};right={src=right;dst=sum;label="R"}}
  type pushout = {pushout:signature;leg_left:signature_arrow;leg_right:signature_arrow}
  let pushout left right =
    let p = left.dst ^ "+_" ^ right.dst in
    Ok {pushout=p;leg_left={src=left.dst;dst=p;label="PL"};leg_right={src=right.dst;dst=p;label="PR"}}
end

module T = P.Make (Logic)

let test_operations () =
  let left = T.presentation "S" ["a"] and right = T.presentation "T" ["b"] in
  let combined = get (T.combine left right) in
  check "presentation combine signature" (String.equal (T.signature combined) "S+T");
  check "presentation combine constraints" (List.length (T.constraints combined) = 2);
  let extension = {Logic.src="S";dst="U";label="E"} in
  let enriched = get (T.enrich left ~extension ~additions:["c"]) in
  check "presentation enrich signature" (String.equal (T.signature enriched) "U");
  check "presentation close" (T.signature (get (T.close enriched)) = T.signature enriched);
  let req = T.presentation "R" ["r"] and param = T.presentation "P" ["p"] in
  let rm = {Logic.src="R";dst="S";label="RM"} and pm = {Logic.src="R";dst="P";label="PM"} in
  let applied = get (T.parameter_apply ~requirement:req ~parameter:param ~requirement_map:rm ~parameter_map:pm) in
  check "presentation parameter pushout" (String.equal (T.signature applied) "S+_P");
  Printf.printf "PASS generalized presentations\n%!"

let () = test_operations ()
