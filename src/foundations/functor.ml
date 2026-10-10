(* Supplied functors are lawful capabilities. Checked arrow maps preserve
   expected failures, while user callback exceptions are not intercepted. *)
type ('oa, 'aa, 'ob, 'ab) cat_functor = {
  f_dom : ('oa, 'aa) Category.cat;
  f_omap : 'oa -> 'ob;
  f_amap : 'aa -> ('ab, Category.error) result;
  f_cod : ('ob, 'ab) Category.cat;
}

let id_functor c =
  { f_dom = c; f_omap = (fun x -> x); f_amap = (fun x -> Ok x); f_cod = c }

let dual_functor f =
  { f with f_dom = Category.dual_cat f.f_dom; f_cod = Category.dual_cat f.f_cod }

let compose g f =
  { f_dom=f.f_dom; f_cod=g.f_cod; f_omap=(fun x -> g.f_omap (f.f_omap x));
    f_amap=(fun a -> let open Category in let* b = f.f_amap a in g.f_amap b) }

let constant domain codomain object_ =
  {f_dom=domain;f_cod=codomain;f_omap=(fun _ -> object_);
   f_amap=(fun _ -> Ok (codomain.Category.ident object_))}
