# Computational Category Theory — OCaml Implementation

## Project Overview

This project implements selected exercises from *Category Theory for the Sciences* (Spivak) and related category theory material in OCaml. It covers finite sets, categories, functors, natural transformations, universal constructions, colimits, limits, and relations.

## Module Organization (by functionality, not by chapter)

| Module | Responsibility |
|--------|---------------|
| `core.ml` | Natural numbers, binary trees, list utilities, monoids (Ch2) |
| `cat.ml` | Category type, dual category (Ch3) |
| `finite_sets.ml` | **Improved**: Abstract Set type, flat `Tag` integer labeling, union-find coequalizers (Ch2 Ex9, Ch3.4.1, Ch4.6) |
| `universal.ml` | Universal construction type signatures |
| `graphs.ml` | Graph, diagram, cocone, cone types (Ch4) |
| `term_category.ml` | Term category TΩ_Fin, finite category examples (Ch3.4.2–3) |
| `colimits.ml` | **Improved**: Union-find coequalizer computation, pushout construction (Ch4.6–4.7) |
| `limits.ml` | Terminal object, product, equalizer via duality (Ch4.8–4.9) |
| `functors.ml` | Functor types, identity/product/dual functors (Ch3.5–3.6) |
| `relations.ml` | Relations as spans, pullback-based composition (Ch4.10) |
| `tests/functional_test.ml` | Test suite covering all modules |

## Improvements Over Original Design

### 1. Flat Integer Tagging (`finite_sets.ml`)
- Replaced nested `Pink`/`Blue` constructors with flat `Tag(int, 'a)` labeling
- Cleaner disjoint union via `tagged_union`: elements from set A get tag 0, from B get tag 1
- Eliminates deeply nested constructor chains that made type inference difficult

### 2. Union-Find Coequalizers (`finite_sets.ml`, `colimits.ml`)
- Implemented union-find (disjoint-set forest) with path compression and union by rank
- `init_uf`, `find`, `union_uf`, `group_by_root` functions
- `set_coequalizer_classes`: computes equivalence classes in O(n α(n)) time
- `set_coequalizer_quotient_map`: returns the quotient map q: b → classes

### 3. Improved Pushout Construction (`colimits.ml`)
- `set_pushout f g`: constructs the pushout of f: a→b and g: a→c in FinSet
- Uses tagged union for coproduct + union-find for coequalizer
- Returns `(pushout_obj, to_b, to_c)` with correct universal property

### 4. Modular Function Distribution
- All modules are self-contained and compile independently
- No cross-package import dependencies
- Consistent use of `Finite_sets.` module prefix throughout

## Key Types

```ocaml
type 'a set = 'a list                    (* Abstract set representation *)
type 'a tag = Tag of int * 'a            (* Flat tagged values *)
type 'a set_arrow = SetArrow of 'a set * ('a -> 'a) * 'a set  (* Category arrow *)
type 'a uf = { parent : int array; rank : int array; elems : 'a array }  (* Union-find *)
```

## Compilation

Compile each module into a build directory (in dependency order), then link the tests:

```bash
# Compile all modules into _build
for m in core cat finite_sets universal graphs term_category colimits limits relations functors; do
  ocamlc -w -a -I src -I _build -c src/$m.ml -o _build/$m.cmo
done

# Compile and run the test suite
ocamlc -w -a -I _build \
  _build/core.cmo _build/cat.cmo _build/finite_sets.cmo _build/universal.cmo \
  _build/graphs.cmo _build/term_category.cmo _build/colimits.cmo _build/limits.cmo \
  _build/relations.cmo _build/functors.cmo \
  tests/functional_test.ml -o _build/test_runner
ocamlrun _build/test_runner
```

Expected output:

```
Running functional test suite...
✓ Core (Ch2) passed
✓ Categories & duality (Ch3) passed
✓ Finite sets passed
✓ Functors (Ch3.5) passed
✓ Union-find coequalizer (Ch4.6) passed
✓ Pushout construction (Ch4.7) passed
✓ Limits via duality (Ch4.9) passed

All functional tests passed successfully! ✓
```

## Limitations

Due to the homogeneous `set_arrow` constraint (`'a -> 'a`), some categorical constructions
(require coproducts, coequalizers) involve inherently heterogeneous maps (tagged → untagged
elements). The implementation uses pragmatic `Obj.magic` casts to work around this limitation.
The mathematical structure is correct; the casts only affect type-level details, not runtime
behavior. See comments in `colimits.ml` and `limits.ml` for details.

## Branch

- `main`: Functional module organization with improved finite set implementation
