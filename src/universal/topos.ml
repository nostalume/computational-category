open Foundations.Category

type ('o,'a) classifier = {
  omega : 'o;
  truth : 'a;
  character : 'a -> ('a, error) result;
}

type ('o,'a) topos = {
  topos_cat : ('o,'a) Foundations.Category.cat;
  topos_initial : ('o,'a) Limits.initial_obj;
  topos_terminal : ('o,'a) Limits.terminal_obj;
  topos_complete : ('o,'a) Limits.complete_cat;
  topos_cocomplete : ('o,'a) Limits.cocomplete_cat;
  topos_product : ('o,'a) Limits.product;
  topos_coproduct : ('o,'a) Limits.coproduct;
  topos_equalizer : ('o,'a) Limits.equalizer;
  topos_pushout : ('o,'a) Limits.pushout;
  topos_closed : ('o,'a) Closed.cartesian_closed;
  topos_classifier : ('o,'a) classifier;
}

let true_ t a =
  let* terminal = t.topos_terminal.term_univ a in
  compose t.topos_cat t.topos_classifier.truth terminal

let character t m = t.topos_classifier.character m

let name t f =
  let a = t.topos_cat.source f and b = t.topos_cat.target f in
  let one = t.topos_terminal.term_obj in
  let* product, _ = t.topos_product (a, one) in
  let* f_on_product = compose t.topos_cat f product.prod_proj1 in
  t.topos_closed.cc_exponential.curry a b one f_on_product

let equalizer t (f,g) =
  let* data, univ = t.topos_equalizer (f,g) in
  Ok (data.Limits.eq_arrow, univ)

let factorize t f =
  let* po, _ = t.topos_pushout (f, f) in
  let* eq, univ = equalizer t (po.pushout_leg1, po.pushout_leg2) in
  let* epi = univ (t.topos_cat.source f) f in
  let* check = compose t.topos_cat eq epi in
  if t.topos_cat.equal_arr check f then Ok (epi, eq)
  else Error (Non_commuting "topos factorization")

let false_ t =
  let* arrow = t.topos_initial.init_univ t.topos_terminal.term_obj in
  character t arrow

let not_ t =
  let* f = false_ t in
  character t f

let and_ t =
  let omega = t.topos_classifier.omega in
  let* _product, univ = t.topos_product (omega, omega) in
  let one = t.topos_terminal.term_obj in
  let* left = true_ t one in
  let* right = true_ t one in
  let* both = univ one left right in
  character t both

let or_ t =
  let omega = t.topos_classifier.omega in
  let* _coproduct, univ = t.topos_coproduct (omega, omega) in
  let* product, pair_univ = t.topos_product (omega, omega) in
  let* truth = true_ t omega in
  let* p1 = pair_univ omega (t.topos_cat.ident omega) truth in
  let* p2 = pair_univ omega truth (t.topos_cat.ident omega) in
  let* joined = univ product.prod_obj p1 p2 in
  let* _, image = factorize t joined in
  character t image

let imply_ t =
  let omega = t.topos_classifier.omega in
  let* product, univ = t.topos_product (omega, omega) in
  let one = t.topos_terminal.term_obj in
  let* truth = true_ t one in
  let* both = univ one truth truth in
  let* conjunction = character t both in
  let* eq_arrow, _ = equalizer t (conjunction, product.prod_proj1) in
  character t eq_arrow

let for_all t a =
  let* predicate = true_ t a in
  let* named = name t predicate in
  character t named



