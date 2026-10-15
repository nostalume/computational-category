open Foundations.Category
open Foundations.Functor

type ('oa,'aa,'ab) universal_arrow = {
  free_object : 'oa; unit_arrow : 'ab;
  factor : 'oa -> 'ab -> ('aa,error) result;
}
type ('ob,'ab,'oa,'aa) adjunction = {
  left : ('ob,'ab,'oa,'aa) cat_functor;
  right : ('oa,'aa,'ob,'ab) cat_functor;
  choose : 'ob -> (('oa,'aa,'ab) universal_arrow,error) result;
}
let left a = a.left
let right a = a.right

let checked_choice right choose b =
  let* q = choose b in let* image = right.f_omap q.free_object in
  if not (has_endpoints right.f_cod q.unit_arrow b image) then
    Error (Non_composable "universal unit: endpoints")
  else
    let factor a h =
      let* ga = right.f_omap a in
      if not (has_endpoints right.f_cod h b ga) then
        Error (Non_composable "universal factor: input")
      else
        let* u = q.factor a h in
        if not (has_endpoints right.f_dom u q.free_object a) then
          Error (Non_composable "universal factor: output")
        else
          let* gu = right.f_amap u in
          let* composite = Foundations.Category.compose right.f_cod gu q.unit_arrow in
          if right.f_cod.equal_arr composite h then Ok u
          else Error (Non_commuting "universal factor triangle") in
    Ok {q with factor}

let of_universal ~right choose =
  let choose = checked_choice right choose in
  let left = {f_dom=right.f_cod;f_cod=right.f_dom;
    f_omap=(fun b -> let* q = choose b in Ok q.free_object);
    f_amap=(fun h ->
      let* s = choose (right.f_cod.source h) in
      let* t = choose (right.f_cod.target h) in
      let* candidate = Foundations.Category.compose right.f_cod t.unit_arrow h in
      s.factor t.free_object candidate)} in
  {left;right;choose}

let of_unit_counit ~left ~right ~unit ~counit =
  let choose b =
    let* free_object = left.f_omap b in let* unit_arrow = unit b in
    let factor a h =
      let* ga = right.f_omap a in let* fga = left.f_omap ga in
      let* epsilon = counit a in
      if not (has_endpoints left.f_cod epsilon fga a) then
        Error (Non_composable "adjunction counit: endpoints")
      else let* fh = left.f_amap h in
        Foundations.Category.compose left.f_cod epsilon fh in
    Ok {free_object;unit_arrow;factor} in
  {left;right;choose=checked_choice right choose}

let universal a b = a.choose b
let unit a =
  {n_source=id_functor a.left.f_dom;n_target=Foundations.Functor.compose a.right a.left;
   n_component=(fun b -> let* q = a.choose b in Ok q.unit_arrow)}
let counit a =
  {n_source=Foundations.Functor.compose a.left a.right;n_target=id_functor a.left.f_cod;
   n_component=(fun o -> let* go = a.right.f_omap o in let* q = a.choose go in
     q.factor o (a.right.f_cod.ident go))}
let transpose a b o h = let* q = a.choose b in q.factor o h
let untranspose a b o h =
  let* q = a.choose b in let* go = a.right.f_omap o in
  if not (has_endpoints a.left.f_cod h q.free_object o) then
    Error (Non_composable "adjunction untranspose: input")
  else let* gh = a.right.f_amap h in
    let* u = Foundations.Category.compose a.right.f_cod gh q.unit_arrow in
    if has_endpoints a.right.f_cod u b go then Ok u
    else Error (Non_composable "adjunction untranspose: output")

let check_triangles a b o =
  let eta = unit a and eps = counit a in
  let* fb = a.left.f_omap b in let* gb = a.right.f_omap o in
  let* etab = natural_component eta b in let* fetab = a.left.f_amap etab in
  let* epsfb = natural_component eps fb in
  let* first = Foundations.Category.compose a.left.f_cod epsfb fetab in
  if not (a.left.f_cod.equal_arr first (a.left.f_cod.ident fb)) then
    Error (Non_commuting "adjunction left triangle")
  else
    let* epsa = natural_component eps o in let* gepsa = a.right.f_amap epsa in
    let* etaga = natural_component eta gb in
    let* second = Foundations.Category.compose a.right.f_cod gepsa etaga in
    if a.right.f_cod.equal_arr second (a.right.f_cod.ident gb) then Ok ()
    else Error (Non_commuting "adjunction right triangle")

let identity c =
  of_unit_counit ~left:(id_functor c) ~right:(id_functor c)
    ~unit:(fun o -> Ok (c.ident o)) ~counit:(fun o -> Ok (c.ident o))
let dual a =
  of_unit_counit ~left:(dual_functor a.right) ~right:(dual_functor a.left)
    ~unit:(fun o -> natural_component (counit a) o)
    ~counit:(fun o -> natural_component (unit a) o)

(* Exercise 11: if a:C->B is followed by b:B->A, compose the left functors
   b.left after a.left and the right functors a.right after b.right. *)
let compose outer inner =
  let left = Foundations.Functor.compose outer.left inner.left in
  let right = Foundations.Functor.compose inner.right outer.right in
  let unit c =
    let* first = natural_component (unit inner) c in
    let* fc = inner.left.f_omap c in
    let* second = natural_component (unit outer) fc in
    let* mapped = inner.right.f_amap second in
    Foundations.Category.compose inner.right.f_cod mapped first in
  let counit a =
    let* ga = outer.right.f_omap a in
    let* first = natural_component (counit inner) ga in
    let* mapped = outer.left.f_amap first in
    let* second = natural_component (counit outer) a in
    Foundations.Category.compose outer.left.f_cod second mapped in
  of_unit_counit ~left ~right ~unit ~counit

(* Exercise 10: the mate of a natural transformation between left adjoints. *)
let mate_left a b alpha =
  let component x =
    let* g'x = b.right.f_omap x in
    let* eta = natural_component (unit a) g'x in
    let* alpha_x = natural_component alpha g'x in
    let* galpha = a.right.f_amap alpha_x in
    let* eps = natural_component (counit b) x in
    let* geps = a.right.f_amap eps in
    let* middle = Foundations.Category.compose a.right.f_cod galpha eta in
    Foundations.Category.compose a.right.f_cod geps middle in
  { n_source = b.right; n_target = a.right; n_component = component }

(* The inverse mate construction, using the universal transpose of a. *)
let mate_right a b beta =
  let component x =
    let* f'x = b.left.f_omap x in
    let* eta = natural_component (unit b) x in
    let* beta_x = natural_component beta f'x in
    let* mapped = Foundations.Category.compose a.right.f_cod beta_x eta in
    transpose a x f'x mapped in
  { n_source = a.left; n_target = b.left; n_component = component }

let check_conjugate a b alpha beta x =
  let* f'x = b.left.f_omap x in
  let* eta_a = natural_component (unit a) x in
  let* lhs = natural_component alpha x in
  let* gl = a.right.f_amap lhs in
  let* left = Foundations.Category.compose a.right.f_cod gl eta_a in
  let* eta_b = natural_component (unit b) x in
  let* beta_f'x = natural_component beta f'x in
  let* right = Foundations.Category.compose a.right.f_cod beta_f'x eta_b in
  if a.right.f_cod.equal_arr left right then Ok ()
  else Error (Non_commuting "conjugate unit square")
