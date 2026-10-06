(lang dune 3.0)
(name computational-category)
(version 0.1.0)
(source "github")
(github "example/computational-category")
(authors "Learning Project")
(maintainers "Learning Project")
(license MIT)
(keywords ("category-theory" "ml" "ocaml" "education"))
(package
 (name computational-category)
 (synopsis "Computational Category Theory learning exercises in OCaml")
 (description
  "OCaml implementations of ML exercises from the Computational Category Theory book,
   covering categories, functors, natural transformations, and monoids.")
 (dependencies
  (ocaml (>= 4.14))
  (dune (>= 3.0))))