open Foundations.Category

let factorized_coequalizer
    (cat : ('o,'a) Foundations.Category.cat)
    (pushout : ('o,'a) Universal.Limits.pushout)
    (coequalizer : ('o,'a) Universal.Limits.coequalizer)
    ~g ~factor ~other =
  if not (has_endpoints cat g (cat.source g) (cat.target g) &&
          cat.equal_obj (cat.source g) (cat.source other) &&
          cat.equal_obj (cat.target factor) (cat.target other) &&
          cat.equal_obj (cat.source factor) (cat.target g)) then
    Error (Non_composable "factorized coequalizer: endpoints")
  else
    let* _factored = compose cat factor g in
    let* po,_ = pushout (g, other) in
    let p = po.Universal.Limits.pushout_leg1
    and p' = po.Universal.Limits.pushout_leg2 in
    let* p'factor = compose cat p' factor in
    let* q,_ = coequalizer (p,p'factor) in
    compose cat q.Universal.Limits.coeq_arrow p'
