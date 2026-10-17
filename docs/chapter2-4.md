# Finite carriers, categories, and universal constructions

## Foreword

The first categorical programs need more than a collection type. They need a
stable notion of equality, total arrows between admitted objects, and a way to
turn a universal definition into a terminating operation. These choices control
all later constructions: a product, graph, relation, adjunction, or topos can
only be as reliable as its objects and arrows.

This guide derives the executable representation from the mathematics in three
steps: define the object or arrow, reduce its laws to finite checks, then expose
the smallest API that preserves those laws. The implementation is finite and
'equality-driven'; it does not add a hash or ordering assumption that the
mathematics did not provide.

## A. Values and carriers

A finite carrier is an extensional finite collection of values. With an atom
equality `≈`, the mathematical membership and equality relations are

```text
x ∈ A       iff  ∃a∈A. x ≈ a
A = B       iff  (∀x. x∈A ⇔ x∈B)
```

A program must retain one representative for each equality class. Therefore the
representation is an immutable admitted snapshot, not the input list itself:

```text
admit(xs)          = one representative per ≈-class
enumerate(A)       = the admitted representatives
map(f,A)           = admit(f(x) for x in enumerate(A))
```

Values form a closed recursive universe of atoms, tags, pairs, and a terminal
value. The equality supplied for atoms must be stable and terminating. No
structural equality, hash, or ordering is inferred.

The API follows directly:

```ocaml
open Computational_category

module F = Instances.Finite_sets.Make (struct
  type t = int
  let equal (a : int) b = a = b
end)

let values = F.carrier_of_list [F.atom 1; F.atom 2; F.atom 1]
let () = assert (F.cardinality values = 2)
```

`carrier_to_list` is an operational mediation for algorithms that need a finite
iteration. It is not a mathematical operation or a canonical ordering.

### Representation and cost

Equality-only membership and arbitrary evaluation are linear in the admitted
carrier. Admission and extensional reconciliation can be quadratic in the
worst case because certifying pairwise distinctness may require every pairwise
comparison. Subquadratic behavior would require a compatible hash/order law or
a different equality contract. The implementation therefore reuses positions
only when they are already known and keeps the equality-driven fallback.

## B. Arrows and categories

A finite arrow `f : A → B` is a total function whose image is contained in `B`.
The admission rule is

```text
for every x∈A:
  y := f(x)
  require y∈B
```

The callback is sampled once per admitted source representative and the result
is frozen. This deduction yields a dense table indexed by the source carrier:

```text
morphism_result(A,f,B) = { domain=A; codomain=B; table[i]=f(A[i]) }
```

`domain`, `codomain`, `eval`, `identity`, `compose`, and `equal_morphism` are
therefore the direct API. `eval` accepts a value equal to an admitted domain
representative and returns its frozen image; an outside value returns
`Outside_domain`.

Composition is ordinary categorical composition:

```text
compose(g,f)(x) = g(f(x))
```

It first checks that the codomain of `f` and domain of `g` are extensionally
equal, then reuses the first table's positions while constructing the result.
The generic category record supplies `source`, `target`, `ident`, `comp`, and
the two equality operations; constructing that record does not prove its laws.

## C. Universal constructions

A universal object is not just a value. It is a chosen object, its structural
legs, and a mediator operation whose equations are checked at admission. For a
product:

```text
product(A,B) = (P, p1:P→A, p2:P→B)
pair(X,f,g)  = u:X→P
require p1∘u=f and p2∘u=g
```

The same reduction gives coproducts, equalizers, coequalizers, pushouts,
pullbacks, and finite diagram limits/colimits. The finite implementation uses
indexed product tables and quotient representatives where that reduces repeated
membership work, while preserving the public equality contract.

A universal property supplies uniqueness mathematically. Tests enumerate finite
candidate mediators to falsify an incorrect implementation; they do not turn a
finite enumeration into a proof for every category supplied by a caller.

## D. Relations and spans

A relation from `A` to `B` is represented by a span

```text
A <- W -> B
```

because `W` retains witness multiplicity. Composition forms a pullback over the
matching endpoint and keeps every compatible witness pair. The extensional
relation image is a separate operation that maps witnesses to endpoint pairs
and re-admits the result carrier. Empty relations still retain their declared
endpoints.

## E. Mathematical-to-code summary

```text
extensional finite set  -> admitted carrier snapshot
function A→B            -> frozen checked morphism table
category law            -> supplied dictionary + checked composition
universal definition    -> chosen object + legs + result-valued mediator
relation                -> witness-bearing span
```

The focused tests exercise equality, failed admission, frozen callbacks,
composition, universal equations, and witness-preserving relation composition.
They establish bounded executable evidence, not arbitrary category laws,
equality termination, or unrestricted universal uniqueness.
