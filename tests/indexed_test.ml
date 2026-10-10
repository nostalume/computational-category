open Computational_category
module F = Instances.Finite_sets.Make (struct type t=int let equal (a:int) b=a=b end)
module U = Instances.Finite_set_universals.Make (F)
open Category_test_support.Checks
let set xs = F.of_list (List.map F.atom xs)
module B = struct
  let cat = {Foundations.Category.source=fst;target=snd;ident=(fun x -> x,x);equal_obj=Bool.equal;
    equal_arr=(fun a b -> a=b);comp=(fun ((m,t),(s,n)) ->
      if m=n && (not s || n) && (not m || t) then Ok (s,t)
      else Error (Foundations.Category.Non_composable "base"))}
  let bundle cat initial join make =
    let init={Universal.Limits.init_obj=initial;init_univ=(fun x -> Ok (make initial x))} in
    let coproduct (a,b) =
      let obj=join a b in
      Ok ({Universal.Limits.coprod_obj=obj;coprod_inj1=make a obj;coprod_inj2=make b obj},
        (fun x f g -> if Foundations.Category.has_endpoints cat f a x && Foundations.Category.has_endpoints cat g b x
          then Ok (make obj x) else Error (Foundations.Category.Non_composable "boolean coproduct"))) in
    let coequalizer (f,g) =
      if not (Foundations.Category.parallel cat f g) then Error (Foundations.Category.Non_parallel "boolean coequalizer")
      else let obj=cat.Foundations.Category.target f in
        Ok ({Universal.Limits.coeq_obj=obj;coeq_arrow=cat.Foundations.Category.ident obj},
          (fun x h -> if Foundations.Category.has_endpoints cat h obj x then Ok h
            else Error (Foundations.Category.Non_composable "boolean factor"))) in
    {Universal.Limits.iocc_cat=cat;iocc_initial=init;iocc_coproduct=coproduct;iocc_coequalizer=coequalizer}
  let cc={Universal.Limits.cc_cat=cat;cc_colimit=Universal.Limits.finite_colimit
    (bundle cat false (||) (fun s t -> s,t))}
  let lc={Universal.Limits.co_cat=cat;co_limit=Universal.Limits.dual_colimit (Universal.Limits.finite_colimit
    (bundle (Foundations.Category.dual_cat cat) true (&&) (fun s t -> t,s)))}
end
(* Nonidentity reindexing 0 : FinSet -> FinSet has right adjoint constant 1. *)
module I = struct
  type base_obj=bool
  type base_arr=bool*bool
  type fiber_obj=F.set
  type fiber_arr=F.arrow
  let base=B.cat
  let fiber _=F.cat
  let valid_object _ _=true
  let zero={Foundations.Functor.f_dom=F.cat;f_cod=F.cat;f_omap=(fun _ -> F.emptyset);
    f_amap=(fun _ -> Ok (F.ident F.emptyset))}
  let transport (s,t)=
    if s=t then Ok (Foundations.Functor.id_functor F.cat)
    else if not s && t then Ok zero else Error (Foundations.Category.Non_composable "transport")
end
module G = Constructions.Indexed.Make (I)
module Checked = Constructions.Indexed.Make (struct
  include I
  let valid_object i s=i || List.for_all (fun x -> F.member x (set [1;2])) (F.to_list s)
end)
let preserve base c =
  if fst base=snd base then Ok c else
    let open Foundations.Category in
    let* cc=Universal.Diagrams.map_cocone I.zero c.Universal.Limits.colim_cocone in
    let univ other=
      let* a=F.arrow_result F.emptyset (fun _ -> Error (Outside_domain "empty"))
        (Universal.Diagrams.cocone_apex other) in Universal.Diagrams.cocone_arrow cc a other in
    Ok {Universal.Limits.colim_cocone=cc;colim_univ=univ}
let adjoints base =
  if fst base=snd base then Ok {G.right=Foundations.Functor.id_functor F.cat;
    to_right=(fun _ _ h -> Ok h);from_right=(fun _ _ h -> Ok h)}
  else if not (fst base) && snd base then
    let terminal=F.singleton F.terminal in
    let right={Foundations.Functor.f_dom=F.cat;f_cod=F.cat;f_omap=(fun _ -> terminal);
      f_amap=(fun _ -> Ok (F.ident terminal))} in
    Ok {G.right;to_right=(fun a _ _ -> F.arrow a (fun _ -> F.terminal) terminal);
      from_right=(fun _ b _ -> F.arrow_result F.emptyset
        (fun _ -> Error (Foundations.Category.Outside_domain "empty")) b)}
  else Error (Foundations.Category.Non_composable "adjoint")
let cc=G.cocomplete B.cc (fun _ -> U.cocomplete_finset) preserve
let lc=G.complete B.lc (fun _ -> U.complete_finset) adjoints
let obj i s=get (G.object_ i s)
let arr a b h c=get (G.arrow a b h c)
let triples=ref 0
let mediator_checks=ref 0
let all_maps a b =
  let rec assignments xs=match xs with
    | [] -> [[]] | x::xs -> List.concat_map (fun y ->
      List.map (fun rest -> (x,y)::rest) (assignments xs)) (F.to_list b) in
  List.map (fun xs -> get (F.arrow_result a (fun x ->
    match List.find_opt (fun (y,_) -> F.equal x y) xs with
    | Some (_,y) -> Ok y | None -> Error (Foundations.Category.Outside_domain "oracle")) b))
    (assignments (F.to_list a))
let all_arrows a b =
  let base=G.index a,G.index b in
  if fst base && not (snd base) then [] else
    let f=get (I.transport base) in
    List.map (fun h -> arr a base h b) (all_maps (f.Foundations.Functor.f_omap (G.value a)) (G.value b))
let laws arrows =
  let cp g f=get (Foundations.Category.compose G.category g f) in
  List.iter (fun f ->
    check "indexed left identity" (G.category.Foundations.Category.equal_arr
      (cp (G.category.Foundations.Category.ident (G.target f)) f) f);
    check "indexed right identity" (G.category.Foundations.Category.equal_arr
      (cp f (G.category.Foundations.Category.ident (G.source f))) f);
    List.iter (fun g -> if G.category.Foundations.Category.equal_obj (G.target f) (G.source g) then
      List.iter (fun h -> if G.category.Foundations.Category.equal_obj (G.target g) (G.source h) then begin
        incr triples;check "indexed associativity" (G.category.Foundations.Category.equal_arr
          (cp h (cp g f)) (cp (cp h g) f))
      end) arrows) arrows) arrows
let test_indexed () =
  reject_any "indexed object fiber membership" (Checked.object_ false (set [3]));
  ignore (get (Checked.object_ true (set [3])));
  let objects=List.concat_map (fun i -> List.map (obj i) (F.powerset (set [1;2]))) [false;true] in
  laws (List.concat_map (fun a -> List.concat_map (all_arrows a) objects) objects);
  let x=obj false (set [1;2]) and y=obj true (set [1;2]) in
  let h=arr x (false,true) (get (F.arrow_result F.emptyset
    (fun _ -> Error (Foundations.Category.Outside_domain "empty")) (G.value y))) y in
  reject_any "fiber endpoints" (G.arrow x (false,true) (F.ident (G.value x)) y);
  let shape=get (Universal.Diagrams.graph ~nodes:["x";"y"] ~edges:["h","x","y"]) in
  let d=get (Universal.Diagrams.diagram G.category shape ~objects:["x",x;"y",y] ~arrows:["h",h]) in
  let c=get (cc.Universal.Limits.cc_colimit d) and l=get (lc.Universal.Limits.co_limit d) in
  let co=Universal.Diagrams.cocone_apex c.Universal.Limits.colim_cocone and li=Universal.Diagrams.cone_apex l.Universal.Limits.lim_cone in
  check "colimit index/fiber" (G.index co && F.cardinality (G.value co)=2);
  check "limit index/fiber" (not (G.index li) && F.cardinality (G.value li)=2);
  let u=get (c.Universal.Limits.colim_univ c.Universal.Limits.colim_cocone) in
  let v=get (l.Universal.Limits.lim_univ l.Universal.Limits.lim_cone) in
  check "indexed colimit self" (G.category.Foundations.Category.equal_arr (Universal.Diagrams.cocone_apex_arrow u) (G.category.Foundations.Category.ident co));
  check "indexed limit self" (G.category.Foundations.Category.equal_arr (Universal.Diagrams.cone_apex_arrow v) (G.category.Foundations.Category.ident li));
  let single=get (Universal.Diagrams.graph ~nodes:["x"] ~edges:[]) in
  let one=get (Universal.Diagrams.diagram G.category single ~objects:["x",x] ~arrows:[]) in
  let one_colimit=get (cc.Universal.Limits.cc_colimit one) in
  let candidate=get (Universal.Diagrams.cocone one y ~sides:["x",h]) in
  let mapped=get (one_colimit.Universal.Limits.colim_univ candidate) in
  check "nonidentity colimit preservation used" (G.base_map (Universal.Diagrams.cocone_apex_arrow mapped)=(false,true));
  let bad_preserve _ c=Ok c in
  let bad=get ((G.cocomplete B.cc (fun _ -> U.cocomplete_finset) bad_preserve).Universal.Limits.cc_colimit one) in
  reject_any "preservation wrong fiber" (bad.Universal.Limits.colim_univ candidate);
  let ay=arr y (true,true) (get (F.arrow (G.value y) (fun _ -> F.atom 1) (G.value y))) y in
  let by=get (Foundations.Category.compose G.category ay h) in
  let other=get (Universal.Diagrams.cocone d y ~sides:["x",by;"y",ay]) in
  let factor=get (c.Universal.Limits.colim_univ other) in
  let candidates=List.filter (fun a -> List.for_all (fun n ->
    G.category.Foundations.Category.equal_arr (get (Foundations.Category.compose G.category a
      (get (Universal.Diagrams.cocone_side c.Universal.Limits.colim_cocone n))))
      (get (Universal.Diagrams.cocone_side other n))) ["x";"y"]) (all_arrows co y) in
  incr mediator_checks;
  check "indexed colimit unique" (List.length candidates=1 &&
    G.category.Foundations.Category.equal_arr (List.hd candidates) (Universal.Diagrams.cocone_apex_arrow factor));
  let ax=arr x (false,false) (get (F.arrow (G.value x) (fun _ -> F.atom 1) (G.value x))) x in
  let bx=get (Foundations.Category.compose G.category h ax) in
  let other=get (Universal.Diagrams.cone d x ~sides:["x",ax;"y",bx]) in
  let factor=get (l.Universal.Limits.lim_univ other) in
  let candidates=List.filter (fun a -> List.for_all (fun n ->
    G.category.Foundations.Category.equal_arr (get (Foundations.Category.compose G.category
      (get (Universal.Diagrams.cone_side l.Universal.Limits.lim_cone n)) a))
      (get (Universal.Diagrams.cone_side other n))) ["x";"y"]) (all_arrows x li) in
  incr mediator_checks;
  check "indexed limit unique" (List.length candidates=1 &&
    G.category.Foundations.Category.equal_arr (List.hd candidates) (Universal.Diagrams.cone_apex_arrow factor));
  let bad_adj f=let a=get (adjoints f) in Ok {a with G.to_right=(fun _ _ h -> Ok h)} in
  reject_any "bad mate endpoint" ((G.complete B.lc (fun _ -> U.complete_finset) bad_adj).Universal.Limits.co_limit d);
  let shape=get (Universal.Diagrams.graph ~nodes:[] ~edges:[]) in
  let empty=get (Universal.Diagrams.diagram G.category shape ~objects:[] ~arrows:[]) in
  let initial=get (cc.Universal.Limits.cc_colimit empty) and terminal=get (lc.Universal.Limits.co_limit empty) in
  check "indexed initial" (not (G.index (Universal.Diagrams.cocone_apex initial.Universal.Limits.colim_cocone)) &&
    F.is_empty (G.value (Universal.Diagrams.cocone_apex initial.Universal.Limits.colim_cocone)));
  check "indexed terminal" (G.index (Universal.Diagrams.cone_apex terminal.Universal.Limits.lim_cone) &&
    F.cardinality (G.value (Universal.Diagrams.cone_apex terminal.Universal.Limits.lim_cone))=1)
let test_abstract () =
  let shape=get (Universal.Diagrams.graph ~nodes:["a"] ~edges:[]) in
  let a=set [1] and b=set [1;2] in
  let d=get (Universal.Diagrams.diagram F.cat shape ~objects:["a",a] ~arrows:[]) in
  let e=get (Universal.Diagrams.diagram F.cat shape ~objects:["a",b] ~arrows:[]) in
  let injection=get (F.arrow a (fun x -> x) b) in
  let base=get (Universal.Diagrams.diagram_arrow d e ~components:["a",injection]) in
  let c=Universal.Limits.Free.fixed_colimit F.cat shape U.set_colimit in
  let free,unit,factor=get (c.Universal.Limits.Free.free d) in
  let other=get (Universal.Diagrams.cocone e b ~sides:["a",F.ident b]) in
  let arrow=get (factor other base) in
  check "abstract free base" (c.Universal.Limits.Free.diagrams.Foundations.Category.equal_arr
    (get (Foundations.Category.compose c.Universal.Limits.Free.diagrams (c.Universal.Limits.Free.base_arrow arrow) unit)) base);
  check "abstract free triangle" (F.equal_arrow (get (F.compose
    (Universal.Diagrams.cocone_map_apex arrow) (get (Universal.Diagrams.cocone_side free "a")))) injection);
  let self=get (factor free unit) in
  check "free identity" (c.Universal.Limits.Free.cocones.Foundations.Category.equal_arr self (c.Universal.Limits.Free.cocones.Foundations.Category.ident free));
  let l=Universal.Limits.Cofree.fixed_limit F.cat shape U.set_limit in
  let cofree,counit,factor=get (l.Universal.Limits.Cofree.cofree e) in
  let other=get (Universal.Diagrams.cone d a ~sides:["a",F.ident a]) in
  let arrow=get (factor other base) in
  check "abstract cofree base" (l.Universal.Limits.Cofree.limit_diagrams.Foundations.Category.equal_arr
    (get (Foundations.Category.compose l.Universal.Limits.Cofree.limit_diagrams counit (l.Universal.Limits.Cofree.cone_base_arrow arrow))) base);
  check "abstract cofree triangle" (F.equal_arrow (get (F.compose
    (get (Universal.Diagrams.cone_side cofree "a")) (Universal.Diagrams.cone_map_apex arrow))) injection)
let () =
  List.iter (fun (name,test) -> test ();Printf.printf "PASS %s\n%!" name)
    ["indexed laws and inherited universals",test_indexed;"abstract fixed-shape free/cofree objects",test_abstract];
  Printf.printf "Indexed coverage: %d law triples, %d exhaustive selected mediators.\n%!"
    !triples !mediator_checks

