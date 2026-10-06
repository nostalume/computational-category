# Computational Category Theory — OCaml Learning Project

This project implements computational category theory from the book *Computational Category Theory* using OCaml, organized as a single package with modules distributed by **functionality** rather than by book chapter.

## Overview

The library implements the categorical constructions from the text in OCaml:
- **Categories** — category type, composition, duality
- **Finite sets** — set operations, tagged values, FinSet category
- **Functors** — functor type, identity/product functors, cocontinuous functors
- **Universal constructions** — initial/terminal objects, coproducts/products, coequalizers/equalizers, pushouts/pullbacks
- **Colimits & limits** — finite colimit/limit computation, duality conversion
- **Relations** — spans, relation composition via pullbacks

## Getting Started

### Prerequisites

- OCaml 5.x (via opam)
- Dune build system

### Installation

```bash
opam install . --deps-only
dune build
dune runtest
```

## Project Organization

Modules in `src/` are grouped by functional domain (not by book chapter):

| Module | Functionality |
|---|---|
| `core.ml` | Foundational types (num, bintree, lists, monoids) |
| `cat.ml` | Category type, accessors, duality |
| `finite_sets.ml` | Set operations, tagged values, FinSet category |
| `term_category.ml` | Term substitution category, finite category |
| `graphs.ml` | Graphs, diagrams, cocones, cones, colimits, limits |
| `universal.ml` | Universal construction types |
| `colimits.ml` | Finite colimit construction |
| `limits.ml` | Duality-converted limits |
| `functors.ml` | Functors and cocontinuous functors |
| `relations.ml` | Spans and relation composition |

All modules compile into a single library `computational_category`.

## Learning Progress

- **Chapter 2** (foundations): natural numbers, binary trees, list processing, monoids — in `core.ml`
- **Chapter 3** (categories): category type, FinSet/TΩ_Fin/finite categories, functors, duality — in `cat.ml`, `finite_sets.ml`, `term_category.ml`, `functors.ml`
- **Chapter 4** (limits & colimits): universal constructions, colimits, limits, relations — in `universal.ml`, `colimits.ml`, `limits.ml`, `relations.ml`, `graphs.ml`

## License

Part of the Computational Category Theory learning initiative.

## Acknowledgments

Based on exercises from *Computational Category Theory*.
Architecture planning framework from the `architecture-planning` skill.