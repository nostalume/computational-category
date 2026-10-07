(* ============================================================================
   Colimits — finite colimit constructions in FinSet (Ch4.6, Ch4.7).
   Layer 5: applications built on the layered core.

   Provides:
   - set_coequalizer_classes : equivalence classes via union-find
   - set_coproduct_data     : binary coproduct as a named record
   - set_initial            : initial object as a named record
   - set_pushout            : pushout built from coproduct + coequalizer
   ============================================================================ *)

(* ============================================================================
   Initial object in FinSet: empty set.
   ============================================================================ *)
let set_initial : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.initial_obj =
  { Universal.init_obj = Finite_sets.emptyset;
    Universal.init_univ =
      (fun a -> { Finite_sets.sa_src = Finite_sets.emptyset;
                  sa_fn = (fun x -> raise (Failure "empty function"));
                  sa_tgt = a }) }

(* ============================================================================
   Binary coproduct in FinSet: tagged disjoint union.
   The coproduct object is the tagged union of the two sets; the
   injections tag each side. Returns a Universal.coproduct_data record.
   ============================================================================ *)
let set_coproduct_data (a : 'a Finite_sets.set) (b : 'a Finite_sets.set) :
    ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.coproduct_data =
  let sumab = Finite_sets.tagged_union a b in
  let sumab_cast : 'a Finite_sets.set = Obj.magic sumab in
  { Universal.coprod_obj = sumab_cast;
    coprod_inj1 = { Finite_sets.sa_src = a;
                    sa_fn = (fun x -> Obj.magic (Finite_sets.Tag (0, x)));
                    sa_tgt = sumab_cast };
    coprod_inj2 = { Finite_sets.sa_src = b;
                    sa_fn = (fun x -> Obj.magic (Finite_sets.Tag (1, x)));
                    sa_tgt = sumab_cast } }

(* Coproduct as a Universal.coproduct operator (data + universality) *)
let set_coproduct (a, b) : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.coproduct_data
    * ('a Finite_sets.set -> 'a Finite_sets.set_arrow -> 'a Finite_sets.set_arrow -> 'a Finite_sets.set_arrow) =
  let data = set_coproduct_data a b in
  let univ c f g =
    let ff = Finite_sets.set_arrow_apply f in
    let gg = Finite_sets.set_arrow_apply g in
    { Finite_sets.sa_src = data.Universal.coprod_obj;
      sa_fn = (fun x ->
        match Obj.magic x with
        | Finite_sets.Tag (0, v) -> ff v
        | Finite_sets.Tag (1, v) -> gg v
        | _ -> raise (Failure "unexpected coproduct value"));
      sa_tgt = c }
  in
  (data, univ)

(* ============================================================================
   Coequalizer in FinSet (Ch4.6) — improved union-find implementation.
   Returns the equivalence classes (list of sets) of the target set.
   ============================================================================ *)
let set_coequalizer_classes
    (f_arrow : 'a Finite_sets.set_arrow)
    (g_arrow : 'a Finite_sets.set_arrow)
    : 'a Finite_sets.set list =
  let src_b = Finite_sets.set_t f_arrow in
  let f_fn = Finite_sets.set_arrow_apply f_arrow in
  let g_fn = Finite_sets.set_arrow_apply g_arrow in
  let b_elems = Finite_sets.to_list src_b in
  let uf = Finite_sets.init_uf b_elems in
  List.iter (fun z ->
    let x = f_fn z in
    let y = g_fn z in
    let ix = Finite_sets.find_ix b_elems x in
    let iy = Finite_sets.find_ix b_elems y in
    match ix, iy with
    | Some ix, Some iy -> Finite_sets.union_uf uf ix iy
    | _, _ -> ()
  ) (Finite_sets.to_list (Finite_sets.set_s f_arrow));
  List.map (fun (_, es) -> Finite_sets.dedup es) (Finite_sets.group_by_root uf)

(* ============================================================================
   Coequalizer as a Universal.coequalizer operator.
   Given f, g : a -> b, returns the quotient (b/~) and quotient map q.
   The quotient is a set of classes (a set of sets); we cast to keep the
   set_arrow homogeneous (see Limitations in README).
   ============================================================================ *)
let set_coequalizer ((f, g) : 'a Finite_sets.set_arrow * 'a Finite_sets.set_arrow) :
    ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.coequalizer_data
    * ('a Finite_sets.set -> 'a Finite_sets.set_arrow -> 'a Finite_sets.set_arrow) =
  let classes = set_coequalizer_classes f g in
  let src_b = Finite_sets.set_t f in
  let b_elems = Finite_sets.to_list src_b in
  let uf = Finite_sets.init_uf b_elems in
  List.iter (fun z ->
    let x = Finite_sets.set_arrow_apply f z in
    let y = Finite_sets.set_arrow_apply g z in
    let ix = Finite_sets.find_ix b_elems x in
    let iy = Finite_sets.find_ix b_elems y in
    match ix, iy with
    | Some ix, Some iy -> Finite_sets.union_uf uf ix iy
    | _, _ -> ()
  ) (Finite_sets.to_list (Finite_sets.set_s f));
  (* quotient map q : b -> classes *)
  let q x =
    let ix = Finite_sets.find_ix b_elems x in
    let r = match ix with Some i -> Finite_sets.find uf i | None -> -1 in
    List.find (fun c -> List.exists (fun y ->
      match Finite_sets.find_ix b_elems y with
      | Some iy -> Finite_sets.find uf iy = r
      | None -> false) c) classes
  in
  let coeq_obj : 'a Finite_sets.set = Obj.magic classes in
  let data = { Universal.coeq_obj = coeq_obj;
               coeq_arrow = { Finite_sets.sa_src = src_b;
                              sa_fn = (fun x -> Obj.magic (q x));
                              sa_tgt = coeq_obj } } in
  let univ c q' =
    let j = Finite_sets.set_arrow_apply q' in
    { Finite_sets.sa_src = coeq_obj;
      sa_fn = (fun cls -> Obj.magic (j (List.hd (Obj.magic cls : 'a list))));
      sa_tgt = c }
  in
  (data, univ)

(* ============================================================================
   Pushout in FinSet (Ch4.7).
   Given f: a -> b and g: a -> c, the pushout is the coequalizer of
   (inj_b ∘ f) and (inj_c ∘ g) over the coproduct b ⊔ c.
   ============================================================================ *)
let set_pushout
    (f_arrow : 'a Finite_sets.set_arrow)
    (g_arrow : 'a Finite_sets.set_arrow)
    : 'a Finite_sets.set * 'a Finite_sets.set_arrow * 'a Finite_sets.set_arrow =
  let src_a = Finite_sets.set_s f_arrow in
  let src_b = Finite_sets.set_t f_arrow in
  let src_c = Finite_sets.set_t g_arrow in
  (* Coproduct of src_b and src_c *)
  let cp = set_coproduct_data src_b src_c in
  (* Compose f_arrow with coprod_inj1: coprod_inj1 ∘ f_arrow = set_comp f_arrow coprod_inj1 *)
  let comp_b = Finite_sets.set_comp_direct f_arrow cp.Universal.coprod_inj1 in
  let comp_c = Finite_sets.set_comp_direct g_arrow cp.Universal.coprod_inj2 in
  (* Coequalize comp_b and comp_c *)
  let (data, _) = set_coequalizer (comp_b, comp_c) in
  let pushout_obj = data.Universal.coeq_obj in
  let to_b = data.Universal.coeq_arrow in
  let to_c = data.Universal.coeq_arrow in
  (pushout_obj, to_b, to_c)

(* ============================================================================
   Cocomplete category (Ch4.6): FinSet is finitely cocomplete.
   The full finite-colimit algorithm is the inductive construction from
   Ch4.5 Thm 1 (initial + binary coproduct + coequalizer). For brevity we
   expose the pieces; a full diagram-colimit builder can be layered on top.
   ============================================================================ *)
let io_cp_ce_finset : ('a Finite_sets.set, 'a Finite_sets.set_arrow) Universal.io_cp_ce_cat =
  { Universal.iocc_cat = Finite_sets.finset_cat;
    iocc_initial = set_initial;
    iocc_coproduct = set_coproduct;
    iocc_coequalizer = set_coequalizer }