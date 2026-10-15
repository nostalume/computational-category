# Chapters 2–4: finite carriers, categories, and universal constructions

## Context

These definitions are the executable foundation for every later construction.
The book begins with sets and arrows, but a program must also decide which
values are equal, when a callback is admissible, and how a universal mediator
is obtained. This guide makes those decisions explicit before introducing
more elaborate categorical objects.

This guide describes the **current target API** implemented by
`Instances.Finite_sets.Make`. The names follow the mathematical reduction used
in the book; the source, tests, and examples use the same vocabulary. The
book supplies the definitions, while the package supplies a finite,
equality-driven execution of them.

## First path

```ocaml
open Computational_category

module F = Instances.Finite_sets.Make (struct
  type t = int
  let equal (a : int) b = a = b
end)

let values = F.carrier_of_list [F.atom 1; F.atom 2; F.atom 1]
let () = assert (F.cardinality values = 2)
```

`carrier_of_list` keeps one representative from each supplied equality class.
The representation is immutable to callers; implementation arrays are only an
internal storage choice.

## Chapter 2 — values and finite carriers

The finite-set owner exposes:

```text
carrier_of_list(xs)  = admit one representative per equality class
carrier_to_list(S)   = enumerate the admitted representatives
mem(x,S)             = ∃ y∈S. equal(x,y)
equal_carrier(S,T)   = mutual membership
map_carrier(f,S)     = carrier_of_list(map f (carrier_to_list S))
```

Values are atoms, tagged values, pairs, or the terminal value. `ATOM.equal`
must be stable and terminating; no hash, order, or host-language structural
equality is assumed. Set operations (`union`, `inter`, `diff`, products,
disjoint unions, powersets, and splits) always re-admit their result.

The recursive reduction for the Chapter 2 exercises remains direct:

```text
fold(op,e,[])     = e
fold(op,e,x::xs)  = op(x, fold(op,e,xs))
```

## Chapter 3 — morphisms and categories

A finite morphism is a checked total function between carriers. Construction
freezes one callback result per domain representative:

```text
morphism_result(A, f, B):
  for i = 0 … cardinality(A)-1:
    y := f(A[i])
    require mem(y,B)
    table[i] := y
  return { dom=A; cod=B; table }
```

`morphism A f B` is the exception-free specialization. The public operations
are `domain`, `codomain`, `eval`, `identity`, `compose`, and
`equal_morphism`. `eval` accepts any value equal to a domain representative and
returns the frozen table entry; an outside value is a typed
`Outside_domain` error. A non-member image is `Outside_codomain`.

Composition checks `equal_carrier (codomain f) (domain g)` and then builds a
new frozen table by evaluating `f` followed by `g`. Equality compares
endpoint carriers and all domain images. Since the atom contract provides
equality but not hashing, external lookup is equality-driven; composition and
equality iterate the admitted domain table directly.

### Complexity boundary

With equality-only atoms, `mem` and arbitrary `eval` are linear in the admitted
carrier. Admission and extensional carrier comparison remain quadratic in the
worst case. The implementation avoids redundant list/array conversions and
reuses the indexed first morphism table during composition, but it does not
claim constant-time lookup or subquadratic equality reconciliation. Powersets
and finite function spaces retain their inherent finite-output growth.

`carrier_to_list` is deliberately an operational mediation, not a mathematical
operation: it exposes the finite representatives to list-oriented host code.
It should occur at algorithm or test boundaries, not in the definition of a
carrier or morphism. The remaining bounds are not merely an implementation
oversight. In the equality-query model, certifying that `n` supplied values
are pairwise distinct can require comparing every pair (Ω(n²)); locating an
arbitrary value in an `n`-element carrier likewise has a linear worst case.
Thus `carrier_of_list`, extensional carrier equality, and deduplicating union
cannot all become subquadratic without adding a compatible hash/order law or
changing the representation contract. Safe further reductions are local:
reuse known source positions (as composition already does), add cheap length
guards, and cache a transaction-local reconciliation when many queries reuse
the same carriers. None of these changes the mathematical equality contract.

Universal-construction owners may use the finite instance's namespaced
`Private` position hooks when they already possess indices from the same
carrier. Product projections therefore materialize their `n*m` table once
instead of rechecking each projection by target membership; coequalizer
partitioning and quotient maps reuse the positions computed during admission.
The equality-driven fallback remains in place when endpoint representations are only
extensionally equal rather than physically shared.

The abstract category dictionary remains the executable record
`(source,target,ident,comp,equal_obj,equal_arr)`. The finite instance adapts
`domain`, `codomain`, `identity`, and `equal_morphism` to that dictionary.
The record is a supplied capability: constructing it does not prove the
category laws.

Functor and diagram pseudocode follows the same result-valued boundary:

```text
map_object(F,A) = result object
map_arrow(F,f)  = result morphism
admit_diagram(shape, objects, arrows) = endpoint-checked assignment
admit_cocone(D, apex, sides) = diagram + commuting equations
```

## Chapter 4 — chosen universals and relations

Universal records store a chosen object, legs, and a mediator operation. For a
product:

```text
product(A,B) = (P, p1:P→A, p2:P→B, pair)
pair(X,f,g)  = u:X→P
require p1∘u=f and p2∘u=g
```

The package implements the corresponding coproduct, equalizer, coequalizer,
pushout, pullback, and finite (co)limit owners. Uniqueness is checked only for
the finite candidates enumerated by tests; it is not a generic runtime proof.

Relations retain witnesses as spans. Composition pulls back matching
endpoints, and `image` maps witnesses to endpoint pairs before re-admitting the
result carrier. Empty relations retain their declared endpoint carriers.

## Ownership and evidence

| Role | Owner |
|---|---|
| values, carriers, finite morphisms | `src/instances/finite_sets.ml` |
| category dictionary and errors | `src/foundations/category.ml` |
| diagrams and universal records | `src/universal/` |
| witness-bearing spans and relations | `src/constructions/spans.ml`, `src/instances/finite_relations.ml` |

The focused evidence is in `tests/foundations_test.ml`,
`tests/universal_test.ml`, `tests/constructions_test.ml`, and
`tests/spans_relations_test.ml`. It exercises representative equality,
endpoint failures, frozen callback evaluation, composition, and universal
equations. It cannot prove arbitrary supplied category laws, equality
termination, or universal uniqueness outside the enumerated finite cases.
