(lang dune 3.7)
(name computational_category)
(version 0.1.0)
(source (github nostalume/computational-category))
(authors "Learning Project")
(maintainers "Learning Project")
(license MIT)
(package
 (name computational_category)
 (synopsis "Computational Category Theory learning exercises in OCaml")
 (description
  "OCaml implementations of ML exercises from the Computational Category Theory book,
   covering selected foundations, finite universal constructions, relations, category constructions, and finite-domain natural transformations.")
 (tags (learning category-theory ml ocaml education))
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.7))))
