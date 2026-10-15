(* Supplied functors are lawful capabilities. Checked object/arrow maps preserve
   expected failures, while user callback exceptions are not intercepted. *)
type ('oa, 'aa, 'ob, 'ab) cat_functor = {
  f_dom : ('oa, 'aa) Category.cat;
  f_omap : 'oa -> ('ob, Category.error) result;
  f_amap : 'aa -> ('ab, Category.error) result;
  f_cod : ('ob, 'ab) Category.cat;
}

let id_functor c =
  { f_dom = c; f_omap = (fun x -> Ok x); f_amap = (fun x -> Ok x); f_cod = c }

let dual_functor f =
  { f with f_dom = Category.dual_cat f.f_dom; f_cod = Category.dual_cat f.f_cod }

let compose g f =
  { f_dom=f.f_dom; f_cod=g.f_cod;
    f_omap=(fun x -> let open Category in let* y = f.f_omap x in g.f_omap y);
    f_amap=(fun a -> let open Category in let* b = f.f_amap a in g.f_amap b) }

let constant domain codomain object_ =
  {f_dom=domain;f_cod=codomain;f_omap=(fun _ -> Ok object_);
   f_amap=(fun _ -> Ok (codomain.Category.ident object_))}

(* General natural capabilities are not frozen finite-domain transformations.
   Coherent functors and naturality are premises; these observations check a
   selected component or square without comparing arbitrary functions. *)
type ('oa,'aa,'ob,'ab) natural = {
  n_source : ('oa,'aa,'ob,'ab) cat_functor;
  n_target : ('oa,'aa,'ob,'ab) cat_functor;
  n_component : 'oa -> ('ab,Category.error) result;
}

let natural_component n o =
  let open Category in
  let* s = n.n_source.f_omap o in let* t = n.n_target.f_omap o in
  let* a = n.n_component o in
  if has_endpoints n.n_source.f_cod a s t then Ok a
  else Error (Non_composable "natural component: endpoints")

let check_naturality n a =
  let open Category in
  let* f = n.n_source.f_amap a in let* g = n.n_target.f_amap a in
  let* s = natural_component n (n.n_source.f_dom.source a) in
  let* t = natural_component n (n.n_source.f_dom.target a) in
  let* lhs = compose n.n_source.f_cod g s in
  let* rhs = compose n.n_source.f_cod t f in
  if n.n_source.f_cod.equal_arr lhs rhs then Ok ()
  else Error (Non_commuting "naturality square")

let dual_natural n =
  {n_source=dual_functor n.n_target;n_target=dual_functor n.n_source;
   n_component=n.n_component}
