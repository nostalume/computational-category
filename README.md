# Computational Category Theory — OCaml Implementation

## Project Overview

This project implements selected exercises from *Category Theory for the Sciences* (Spivak) and related category theory material in OCaml. It covers finite sets, categories, functors, universal constructions, colimits, limits, and relations.

## Layered Architecture

The code is organized into **layers**, where each layer depends only on the one below it:

```
Layer 0: elements & finite sets      (finite_sets.ml)
Layer 1: category interface          (cat.ml)
Layer 2: basic colimits              (universal.ml — initial, coproduct, coequalizer)
Layer 3: generic finite colimits     (graphs.ml — diagram, cocone, colimit)
Layer 4: concrete category instances (FinSet)
Layer 5: applications                (colimits.ml, limits.ml, relations.ml)
```

## Modules

| Module | Layer | Responsibility |
|--------|-------|---------------|
| `core.ml` | 0 | Natural numbers, binary trees, list utils, monoids (Ch2) |
| `finite_sets.ml` | 0 | Abstract `set`, `set_arrow`, union-find coequalizer (Ch2, Ch3.4.1, Ch4.6) |
| `cat.ml` | 1 | `Cat.cat` (named record), `result`-based `compose_result`, dual category (Ch3) |
| `universal.ml` | 2 | Initial/terminal/coproduct/coequalizer/product/equalizer as **named records** (Ch4.2) |
| `graphs.ml` | 3 | Graph, diagram, cocone, cone, colimit as named records (Ch4.4) |
| `term_category.ml` | 4 | Term category TΩ_Fin, finite category examples (Ch3.4.2–3) |
| `functors.ml` | 4 | Functor, identity/product/dual functors (Ch3.5–3.6) |
| `colimits.ml` | 5 | FinSet initial/coproduct/coequalizer/pushout (Ch4.6–4.7) |
| `limits.ml` | 5 | FinSet terminal/product/equalizer via duality (Ch4.8–4.9) |
| `relations.ml` | 5 | Relations as spans (Ch4.10) |
| `tests/functional_test.ml` | — | Test suite covering all modules |

## Design Principles Applied

### 1. Records over tuples
Every universal construction is a **named record**, not a positional tuple:

```ocaml
type ('o, 'a) coproduct_data = {
  coprod_obj : 'o;
  coprod_inj1 : 'a;
  coprod_inj2 : 'a;
}
```

Read `d.coprod_obj` instead of `let (a,_,_,_) = ...`.

### 2. Named `set_arrow` (kills tuple-precedence bugs)
The old `SetArrow of 'a set * ('a -> 'a) * 'a set` constructor caused pervasive
parsing ambiguity: `SetArrow (a, f, b)` was misparsed as **curried application**
`SetArrow (a) (f, b)`. Replaced with a record:

```ocaml
type 'a set_arrow = { sa_src : 'a set; sa_fn : 'a -> 'a; sa_tgt : 'a set }
```

### 3. `result` instead of exceptions
`Cat.compose_result` returns `(arrow, string) result`; callers handle failure
explicitly, making errors composable:

```ocaml
match compose_result c g f with
| Ok h -> h
| Error _ -> ...
```

### 4. Layered module signatures
Each layer exposes only its interface; internal representation (tags, union-find)
is hidden.

### 5. Normalization separated from computation
Internal results keep raw tagged values; `normalize_tagged_set` / `normalize_set`
flatten them only for display.

## Key Types

```ocaml
type 'a set = 'a list
type 'a set_arrow = { sa_src : 'a set; sa_fn : 'a -> 'a; sa_tgt : 'a set }
type ('o, 'a) cat = { source : 'a -> 'o; target : 'a -> 'o; ident : 'o -> 'a; comp : 'a * 'a -> 'a }
type 'a uf = { parent : int array; rank : int array; elems : 'a array }
```

## Compilation

Compile each module into a build directory (in dependency order), then link the tests:

```bash
for m in core cat finite_sets universal graphs term_category colimits limits relations functors; do
  ocamlc -w -a -I src -I _build -c src/$m.ml -o _build/$m.cmo
done

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

## Improvements Over the Original

| Aspect | Original | This refactor |
|--------|----------|---------------|
| Field access | `let (a,_,_,_) = ...` | `c.coprod_obj` |
| Errors | `raise non_composable` | `(arrow, string) result` |
| Arrow type | tuple constructor | named record |
| Tags | exposed `blue(pink(...))` | hidden; normalized on display |
| Layering | mixed | strictly layered |
| Extension | edit types | add new modules |

## Limitations

The homogeneous `set_arrow` constraint (`'a -> 'a`) means the quotient object
of a coequalizer (a set of equivalence classes, i.e. a set-of-sets) cannot be
expressed cleanly as a `set_arrow` codomain. The implementation uses pragmatic
`Obj.magic` casts to work around this; the mathematical structure is correct
and the casts affect only type-level details, not runtime behavior. See the
comments in `colimits.ml`, `limits.ml`, and `functors.ml`.