# Definition ledger: Chapters 2–7

This ledger is the first executable task of Stage 20 in
`architecture-plan.md`. It is a planning artifact, not a proof and not a claim
that every book exercise has production code. Each entry reduces a mathematical
definition to pseudocode, assigns one owner, and names the documentation and
evidence required before an implementation change.

## Ledger rules

- `Premises` are supplied laws or admitted inputs; tests do not prove them.
- `Pseudocode` is the behavioral contract, not an OCaml implementation sketch.
- `Evidence` must distinguish law checks, negative admission, exhaustive finite
  observations, source-backed proof, and benchmark measurements.
- A chosen representative is not an equality claim unless the category equality
  makes it so.
- General or infinite claims remain documentation-only unless a separate bounded
  contract is explicitly recorded.

## Chapter 2 — foundations

### C2.1 Recursive data and basic computation

**Definition.** Natural numbers, lists, trees, folds and monoid operations are
structural recursive computations over finite values.

**Premises/bounds.** Inputs are finite, recursion terminates structurally, and a
monoid operation is supplied with an identity and the required laws.

**Pseudocode.**

```text
fold(op, identity, []): identity
fold(op, identity, x::xs): op(x, fold(op, identity, xs))
map_tree(f, leaf x): leaf (f x)
map_tree(f, node xs): node (map (map_tree f) xs)
```

**Owner.** `src/exercises/basic.ml`.

**Documentation/evidence.** Foundations section; arithmetic, order-sensitive
fold, tree and monoid examples; finite law examples. **Status:** existing
exercise implementation; ledger alignment pending.

### C2.2 Equality-owned finite values and sets

**Definition.** A finite set is an extensional collection under supplied atom/value
equality; presentation order is not semantic.

**Premises.** Equality is stable, terminating and an equivalence; values are
immutable for the admitted snapshot.

**Pseudocode.**

```text
carrier_of_list(xs): retain one representative for each equality class
mem(x, S): exists y in S with equal(x,y)
equal_carrier(S,T): every member of S is equal to some member of T, and conversely
union/inter/diff/map_carrier: construct a new admitted carrier; never mutate S or T
```

**Owner.** `src/instances/finite_sets.ml`.

**Documentation/evidence.** README “Values, admission and failure”; equality
fixtures including non-structural equality and nested values; duplicate,
permutation and mutation-sensitivity checks. **Status:** implementation exists;
mathematical ledger entry complete.

### C2.3 Finite total arrows

**Definition.** An arrow is a total function from one admitted finite carrier to
another, retained as an immutable extensional snapshot.

**Pseudocode.**

```text
morphism_result(A, callback, B):
  for each distinct a in A:
    y := callback(a)
    require y in B
    retain (a,y)
eval(f,x): require x equivalent to a domain member; return retained y
compose(g,f): require codomain(f) = domain(g); map each source value through f then g
equal_morphism(f,g): same endpoints and equal outputs for every domain member
```

**Owner.** `src/instances/finite_sets.ml` and `Foundations.Category` errors.

**Documentation/evidence.** `F.morphism`, `F.eval`, composition and equality
sections; callback-once, outside-domain, bad-image, exception-propagation and
composition-law tests. **Status:** implementation exists; preserve this contract
if internal tables are later optimized.

## Chapter 3 — categories and functors

### C3.1 Checked category dictionary

**Definition.** A category supplies objects, arrows, endpoints, identities,
composition and equality satisfying identity/associativity laws.

**Premises.** The supplied dictionary is lawful; executable equality is available
for the selected finite model.

**Pseudocode.**

```text
compose(C,g,f): C.comp(g,f)          // g after f
parallel(C,f,g): equal_obj(src f,src g) and equal_obj(tgt f,tgt g)
dual(C): swap source/target and reverse composition arguments
inverse(C,h): candidate k is accepted only after both inverse equations pass
```

**Owner.** `src/foundations/category.ml`.

**Documentation/evidence.** Category API guide; identity, associativity, duality,
parallelism and inverse negative cases. **Status:** implementation exists;
supplied laws remain premises.

### C3.2 Functors and naturality

**Definition.** A functor maps objects/arrows while preserving endpoints,
identities and composition. A natural transformation supplies components whose
squares commute.

**Pseudocode.**

```text
map_arrow(F,f): result arrow in codomain
check_functor(F,f): endpoints(map f) = map endpoints(f)
check_functor(F,g,f): map(g∘f) = map(g)∘map(f)
check_natural(α,f): F₂(f)∘α_src = α_tgt∘F₁(f)
compose_functor(G,F): map each object/arrow through F then G; stop on first error
```

**Owner.** `src/foundations/functor.ml`; finite snapshots remain in
`src/constructions/functor_category.ml`.

**Documentation/evidence.** Chapter 3/6 functor sections; object-failure,
short-circuit, endpoint, identity, composition and selected naturality tests.
**Status:** implementation exists; result-returning object maps are settled.

### C3.3 Finite labelled diagrams

**Definition.** A diagram is a functor from a finite labelled graph shape into a
category; cones/cocones add an apex and commuting sides.

**Pseudocode.**

```text
admit_diagram(shape, objects, arrows):
  require complete unique bindings and declared endpoints
admit_cocone(D, apex, sides):
  require side endpoints and side_t ∘ edge = side_s for every edge
map_diagram(F,D): map every admitted object and arrow, then re-admit
```

**Owner.** `src/universal/diagrams.ml`.

**Documentation/evidence.** Diagram/shape guide; malformed labels, endpoint,
commuting-square, cone/cocone and mapped-diagram tests. **Status:** implementation
exists; labels are presentation data, not object identity.

## Chapter 4 — finite universals and relations

### C4.1 Primitive universal constructions

**Definition.** Initial, terminal, product, coproduct, equalizer, coequalizer,
pullback and pushout consist of a chosen object/maps and a universal mediator.

**Pseudocode.**

```text
product(A,B): return (P, p1:P→A, p2:P→B, pair)
pair(X,f:X→A,g:X→B): require endpoints; return u:X→P with p1∘u=f and p2∘u=g
check_unique(candidate, expected): compare the required composites extensionally
```

The coproduct, equalizer, coequalizer, pushout and pullback forms reverse the
directions and equations accordingly.

**Owner.** `src/universal/limits.ml`; concrete FinSet owners in
`src/instances/finite_set_universals.ml`.

**Documentation/evidence.** Universal construction guide; structural maps,
mediator equations, selected exhaustive uniqueness, wrong-base and
non-commuting failures. **Status:** implementation exists.

### C4.2 Generic finite colimits and dual limits

**Definition.** A finite colimit is built by finite coproducts followed by
coequalizers for diagram edges; limits are obtained by duality under the
corresponding opposite-category premises.

**Pseudocode.**

```text
finite_colimit(D):
  if no edges: finite_coproduct(objects(D))
  else remove one edge e; Q := finite_colimit(rest)
       identify the two Q-legs induced by e using a coequalizer
       re-admit the resulting cocone and mediator
finite_limit(D): dual_colimit(opposite(D))
```

**Owner.** `Universal.Limits.finite_colimit`, `dual_colimit`, `dual_limit`.

**Documentation/evidence.** Finite induction derivation; empty/discrete/edge
cases, duality, pullback and mediator tests. **Status:** implementation exists;
finite only.

### C4.3 Relations and spans

**Definition.** A relation is a span with a witness carrier; composition pairs
witnesses over the shared endpoint and preserves witness multiplicity until the
resulting endpoint image is intentionally deduplicated.

**Pseudocode.**

```text
relation_span(left, right, pairs): admit each pair and endpoint
compose(next, previous): P := pullback(previous.right,next.left)
  return span formed by composing P projections with outer legs
image(span): enumerate existing witnesses; map to endpoint pairs; deduplicate only image
```

**Owner.** `src/constructions/spans.ml` and `src/instances/finite_relations.ml`.

**Documentation/evidence.** Relations section and public example; endpoint,
empty-relation, existential-image, associativity and span-isomorphism checks.
**Status:** implementation exists.

## Chapter 5 — category constructions

### C5.1 Comma, slice and coslice categories

**Definition.** A comma object is `(a, h, b)` with `h : L(a) → R(b)`; an arrow
is a commuting square. Slices/coslices are the identity/constant special cases.

**Pseudocode.**

```text
comma_object(a,h,b): require endpoints(h, L(a), R(b))
comma_arrow((a,h,b),(s,t),(a',h',b')):
  require R(t)∘h = h'∘L(s)
compose: compose left and right components, then re-check the square
```

**Owner.** `src/constructions/comma.ml`, `elementary.ml`.

**Documentation/evidence.** `docs/chapter5.md`; square equations, projections,
slice/coslice bases, duality and pushout-coproduct cases.
**Status:** implementation exists.

### C5.2 Functor categories and pointwise universals

**Definition.** For finite enumerated source `A`, objects are admitted functors
`A → B`; arrows are natural transformations; finite limits/colimits are
pointwise under the required target capabilities.

**Pseudocode.**

```text
finite_domain(objects, arrows): require identities, endpoints, closure, associativity
functor_(omap, amap): snapshot maps; check identity, endpoints and composition
natural(components): check every naturality square
pointwise_colimit(D): calculate target colimit at each source object;
  derive each source arrow by its unique universal factor
```

**Owner.** `src/constructions/functor_category.ml`.

**Documentation/evidence.** Chapter 5 pointwise section; naturality, horizontal
composition, finite-domain closure and selected exhaustive mediator tests.
**Status:** implementation exists; arbitrary infinite extensional equality is out
of scope.

### C5.3 Graphs, indexed structures and rewriting

**Definition.** A graph is `(E, incidence, N)`; graph arrows preserve incidence.
Indexed sets are slices; fixed-node paths use witness-preserving pullbacks.

**Pseudocode.**

```text
graph(E, incidence, N): incidence : E → N×N
graph_arrow(e_map,n_map): incidence_target∘e_map = (n_map×n_map)∘incidence_source
fixed_path_step(G,H): pull back target/source endpoint maps to retain composable witnesses
rewrite: admit injective interface maps and reject dangling edges
```

**Owner.** `src/instances/finite_graphs.ml`, `src/constructions/indexed.ml` and
`src/constructions/algebras.ml` only where path algebra is involved.

**Documentation/evidence.** Graph/comma and rewriting sections; incidence,
parallel-edge, fixed-node, path-bound and dangling-edge checks.
**Status:** implementation exists with bounded path/free constructions.

## Chapter 6 — adjunctions and algebras

### C6.1 Adjunctions

**Definition.** `F ⊣ G` is represented by universal arrows or unit/counit with
transpose/untranspose inverses and triangle equations.

**Pseudocode.**

```text
transpose(b,a,h:b→G(a)): unique h#:F(b)→a with G(h#)∘η_b = h
untranspose(b,a,k:F(b)→a): G(k)∘η_b
check_triangles: ε_(F b)∘F(η_b)=id and G(ε_a)∘η_(G a)=id
```

**Owner.** `src/universal/adjunction.ml`.

**Documentation/evidence.** `docs/chapter6.md`; round trips, triangles,
naturality, wrong endpoints and propagated failures. **Status:** implementation exists.

### C6.2 Preservation and derived adjunction constructions

**Definition.** Left adjoints preserve colimits and right adjoints preserve
limits, subject to the chosen universal structures and lawful functors.

**Pseudocode.**

```text
preserve_colimit(F, colimit_D): map the cocone; use adjunction factorization
  to construct the mapped universal mediator
preserve_limit(G, limit_D): obtain by duality; do not duplicate the algorithm
```

**Owner.** `src/universal/preservation.ml` and existing comma/elementary owners.

**Documentation/evidence.** Preservation proofs and finite examples; mapped
cocone/cone equations, comma compatibility and duality tests.
**Status:** implementation exists under explicit premises.

### C6.3 Algebras and terminating free constructions

**Definition.** An `F`-algebra is `(A, α:F(A)→A)`; a homomorphism commutes with
the structure maps. Free objects require an initial algebra or a bounded
terminating construction.

**Pseudocode.**

```text
admit_algebra(A,α): require endpoints
admit_hom(h): require h∘α = β∘F(h)
terminating_free(seed,bound): iterate chosen construction;
  return at first admitted invertible/stable stage; otherwise Iteration_limit
```

**Owner.** `src/constructions/algebras.ml` and `Finite_graphs.Fixed`.

**Documentation/evidence.** Chapter 6 algebra sections; homomorphism equations,
inverse checks, finite path witnesses, false-premise and exhaustion tests.
**Status:** terminating finite cases implemented; general omega claims remain
premises.

## Chapter 7 — exponentials and toposes

### C7.1 Cartesian closed structure

**Definition.** An exponential `b^a` has evaluation `a×b^a→b`; every
`f:a×c→b` has a unique curry `c→b^a` under the supplied laws.

**Pseudocode.**

```text
exponential(a,b): return (E, eval)
curry(a,b,c,f): return k:c→E
check: eval∘(id_a×k) = f
```

**Owner.** `src/universal/closed.ml` and `src/instances/finite_set_topos.ml`.

**Documentation/evidence.** `docs/chapter7.md`; finite cardinality,
evaluation/currying equations and endpoint failures. **Status:** finite-set model.

### C7.2 Classifier, power object and internal logic

**Definition.** A classifier supplies `Ω`, truth and characteristic maps for
admitted monomorphisms. Power objects and logical connectives are derived from
exponentials, products, coproducts and equalizers.

**Pseudocode.**

```text
characteristic(m): require m is supplied as monic; return χ with χ∘m = true∘!
power(a): use Ω^a and the true-evaluation subobject of a×Ω^a
forall/exists: name predicates and enumerate only in the finite instance
```

**Owner.** `src/universal/topos.ml` and `finite_set_topos.ml`.

**Documentation/evidence.** Classifier endpoints, truth tables, power membership,
quantifier tests; no arbitrary topos law is inferred from finite observations.
**Status:** finite-set implementation exists.

### C7.3 Slice, functor and graph toposes

**Definition/premise.** Slice exponentials require a dependent exponential and
relative classifier; functor toposes require a declared sieve and variance
convention; graph toposes require representables and an orientation-consistent
classifier.

**Pseudocode status.**

```text
slice: construct fibrewise products/exponentials over a fixed anchor B;
discrete functor source: construct pointwise exponentials/classifiers;
graph: construct incidence-preserving exponentials and the five-edge classifier
```

**Owner/status.** `Finite_slice_topos`, `Finite_functor_topos`, and
`Finite_graph_topos` own the bounded finite models. General non-discrete
functor categories and unrestricted presheaf claims remain exploratory.
**Evidence gate.** Source-backed contract, small finite model, variance tests and
explicit rejection of unsupported generality. **Status:** bounded implementation.

## Reconciliation checklist

Before any source refactor is selected for a ledger entry:

- the pseudocode names every public operation and precondition;
- the owner is unique and does not duplicate an existing validator;
- the documentation distinguishes theorem, premise, finite witness and test;
- positive, law, negative and exception-boundary evidence is named;
- complexity claims cite a finite workload or remain qualitative;
- representative encodings are not mistaken for mathematical equality;
- unresolved Chapter 7 and future-chapter contracts remain visibly exploratory.

## Reconciliation 20.2 — current signatures and tests

This reconciliation compares the ledger with the current `.mli` surfaces,
inferred public modules under `src/dune`, and the existing test executables. It
does not select or implement a refactor.

### Owner/signature coverage

| Ledger area | Current public owner(s) | Signature result |
|---|---|---|
| C2.1 | `Exercises.Basic` | covered by existing exercise module; no separate public `.mli` |
| C2.2–C2.3 | `Instances.Finite_sets.S` | `carrier`, `morphism`, `eval`, `compose`, equality and error results match the ledger |
| C3.1 | `Foundations.Category` | dictionary, checked composition, duality and inverse operations match; interface is inferred from `.ml` |
| C3.2 | `Foundations.Functor` | result-returning object/arrow maps and naturality checks match |
| C3.3 | `Universal.Diagrams` | graph, diagram, cone/cocone and mapping operations match |
| C4.1–C4.2 | `Universal.Limits`, `Finite_set_universals.Make` | primitive records and finite/dual builders match |
| C4.3 | `Constructions.Spans`, `Finite_relations.Make` | witness-bearing spans and endpoint-image API match |
| C5.1 | `Constructions.Comma`, `Elementary` | comma/slice/coslice builders, projections and inherited universals match |
| C5.2 | `Constructions.Functor_category` | finite-domain admission, functors, naturals and pointwise limits/colimits match |
| C5.3 | `Finite_graphs`, `Indexed`, `Algebras` | graph incidence, fixed paths, indexing and rewriting surfaces match |
| C6.1–C6.3 | `Universal.Adjunction`, `Universal.Preservation`, `Constructions.Algebras` | adjunction, preservation and terminating algebra APIs match |
| C7.1–C7.2 | `Universal.Closed`, `Universal.Topos`, `Finite_set_topos.Make` | exponential, classifier, logic, power and quantifier surfaces match |
| C7.3 | none | correctly remains exploratory in the current signatures and guide |

### Evidence mapping

| Ledger area | Existing evidence |
|---|---|
| C2–C3 | `tests/foundations_test.ml` and finite-set fixtures |
| C4.1–C4.2 | `tests/universal_test.ml` |
| C4.3 | `tests/spans_relations_test.ml` |
| C5.1/C5.3 | `tests/constructions_test.ml` |
| C5.2 | `tests/functor_category_test.ml` |
| C5 indexed lane | `tests/indexed_test.ml` |
| C6.1 | `tests/adjunction_test.ml` |
| C6.2–C6.3 | `tests/algebras_test.ml` and adjunction/preservation cases |
| C7.1–C7.2 | `tests/topos_test.ml` |

### Reconciliation findings

**Resolved.** Every implemented ledger owner has a corresponding current
signature or inferred module and an existing test executable. The result/error
policy, extensional equality policy, finite-boundary policy and next-after-
previous span orientation agree with the source and tests.

**Resolved W1 — documentation gap.** `docs/chapter2-4.md` now provides a
reader-facing foundations/universals guide linked from `README.md`. It mirrors
the ledger pseudocode and keeps book premises separate from finite executable
evidence.

**Warning W2 — inferred interfaces.** `Foundations.Category`,
`Foundations.Functor`, `Elementary`, `Indexed`, `Finite_graphs` and
`Preservation` do not all have explicit `.mli` files. This is an API-visibility
decision, not permission to add interfaces mechanically. Any interface refactor
must first identify supported consumers and preserve the current wrapped names.

**Warning W3 — uniqueness is not generic runtime proof.** The pseudocode
`check_unique` is an evidence/test operation. The current universal records
return chosen mediators and rely on caller-supplied uniqueness laws; no generic
finite enumeration may be documented as proving the abstract theorem.

**Warning W4 — Chapter 7 premises remain unencoded.** `Topos.classifier`
accepts monicity as a mathematical premise, and `Closed.exponential` accepts
the universal laws as supplied capabilities. The current finite tests check
selected equations but do not promote these premises into type-level proofs.

**No blocker.** These warnings do not invalidate the existing ledger. The
selected carrier/morphism migration updates the concrete finite owner without
changing the generic category dictionary or its theorem premises.

### Reconciliation decision

The ledger is structurally consistent with the target API and tests. The
Chapter 2–4 documentation and source migration are complete as one synchronized
lane; the concrete finite owner now uses the carrier/morphism vocabulary and
private dense tables. Subsequent chapter changes must use the same
definition-to-pseudocode-to-source-to-evidence sequence.

## Refactor policy update

The current signatures are now treated as a baseline, not a compatibility
target. The next implementation stages may retire old module paths, names and
representations when the ledger selects a clearer mathematical contract. Local
callers, tests, examples and guides must migrate in the same stage; no shim or
parallel validator is retained solely to preserve the old surface.

## Reconciliation 27 — Chapter 5 construction vocabulary

The Chapter 5 owners now distinguish domain-specific morphisms from generic
comma/category arrows. `Finite_graphs.Make(F)` exposes `graph_morphism`; the
fixed-node subcategory exposes `Fixed.fixed_morphism`; the labelled
subcategory exposes `Labelled.labelled_morphism` and `underlying_morphism`.
`Constructions.Indexed.Make(I)` exposes `indexed_morphism`. The finite
functor-category owner exposes `finite_functor` and
`natural_transformation`, with corresponding equality/duality names.
The category-level `source`, `target`, `edge_map`, and `node_map` accessors
remain because they are direct projections. Generic `Constructions.Comma.arrow`
and algebra `arrow` remain owned by their respective abstract constructions.

The rename is accompanied by caller/test/type-contract migration and the
Chapter 5 prose now names graph morphisms, indexed morphisms, finite functors,
and natural transformations explicitly. No representation or equality law
changed; graph incidence, endpoint admission, label preservation, fixed-node
constraints, indexed transport, naturality, and inherited universal
capabilities remain the same. Efficiency was preserved by retaining the
existing finite-set position-aware kernel; this API stage did not add a
separate workload benchmark.

## Reconciliation 28 — Chapter 6 adjunction and algebra vocabulary

The Chapter 6 owners now expose direct domain names for their abstract
records. `Universal.Adjunction.adjunction` replaces the opaque `t` record
name, while `universal_arrow` remains because it is the book's chosen
universal-arrow object. `Constructions.Algebras.algebra_morphism` replaces
the ambiguous `arrow` name; its `source`, `target`, and `underlying`
projections remain direct homomorphism projections.

The endpoint and square checks are unchanged: an algebra morphism `h` is
admitted only when `h ∘ α = β ∘ F(h)`, and adjunction constructors still check
the selected unit/factor triangles without claiming global laws. All Chapter
6 callers, tests, type-contract fixtures, and guide prose were migrated in
parallel. No compatibility aliases or second record representations were
introduced. Existing finite-set position-aware paths remain the only
efficiency mechanism; this refactor did not create a separate benchmark lane.

## Reconciliation 29 — Chapter 7 closed and topos vocabulary

The Chapter 7 owners now expose direct capability names. `Universal.Topos.t`
is now `Universal.Topos.topos`; `Universal.Closed.exp_obj` is now
`exponential_object`. The finite-set owner exposes
`evaluation_morphism`, `currying_morphism`, `power_object`, and `exists`.
The classifier, truth-value, logical, and quantifier names remain because they
already express their mathematical operations directly.

Function-space values remain tagged finite graphs, and the classifier still
accepts monicity as a caller premise. No claim was added for slice, presheaf,
or graph toposes. The Chapter 7 guide, README, tests, and public signatures
were migrated together without aliases; finite enumeration and equality
semantics are unchanged.

## Reconciliation 30 — integrated Chapters 2–7 contract

The integrated review found no stale public owner vocabulary: remaining generic
`arrow` names are intentionally owned by category/comma/diagram abstractions,
while concrete chapter owners use carrier/morphism, graph/indexed,
adjunction/algebra, and closed/topos names. Ownership is non-duplicated across
the finite representation, generic universal layer, construction owners, and
finite instances.

The pseudocode ledger maps all implemented operations to their endpoint,
commutation, naturality, triangle, classifier, and finite-enumeration checks.
The finite slice, discrete-functor, and directed-graph topos exercise owners
now have explicit bounded implementations; general non-discrete functor
toposes and unrestricted presheaf claims remain exploratory. README and
documentation links resolve. The positive type fixtures compile and the
negative fixtures fail at intended boundaries. The complete Dune build/test
evidence remains green.

## Finite topos exercise completion — functional ownership

`Instances.Finite_slice_topos.Make(F)` owns checked projections `X -> B`,
fibre products, fibrewise exponentials, evaluation/currying, and the relative
classifier `B x Omega -> B`. `Instances.Finite_functor_topos.Make(F)` owns the
pointwise exponential and classifier only after `ensure_discrete` establishes
that the finite source has identities and no non-identity arrows.
`Instances.Finite_graph_topos.Make(F)` owns graph exponentials under the
repository's `E -> V x V` incidence orientation and the five-edge classifier.
All three modules use result-valued admission and existing finite-set equality;
none changes the generic `Universal.Topos` record or claims arbitrary infinite
or presheaf-level completeness.

## Finite first-order unification — functional ownership

`Instances.Term_unification` owns dense variable indexing, array-backed
operator arguments, union-find aliasing, occurs checking, frozen substitutions,
and memoized greatest-common-instance construction. `Instances.Terms` is the
reader-facing tree/substitution adapter. `Constructions.Coequalizer_reduction`
owns the generic pushout/coequalizer factorization from the first Chapter 8
exercise. The efficiency decision is representation-local: it preserves the
book's term and coequalizer equations while avoiding repeated list lookup and
whole-substitution rebuilding during the solver's inner loop.

