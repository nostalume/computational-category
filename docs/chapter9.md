# Generalized constraint presentations

## Context

Chapter 9 moves from individual categorical constructions to the semantics of
building specifications. A signature determines the language, constraints
determine what is asserted, and transport along signature maps explains how
theories combine. The representation below keeps that dependency visible while
making closure lazy and backend-owned.

The executable theory follows this deduction rather than inheriting the book's
closed-set representation. Its implementation boundary is stated after the
mathematical definitions so that the code can be checked against the theory.

The contract generalizes the book's theory of institutions instead of reducing
it to finite equational theories. Equational logic will be one backend; the
presentation layer does not assume a particular sentence language, model
class, or closure algorithm.

## 1. The mathematical kernel

Let `Sig` be a category of signatures. For each signature `S`, let `Sen(S)` be
its set of sentences, and for each signature arrow `u : S -> T`, let

```text
Sen(u) : Sen(S) -> Sen(T)
```

translate sentences. The implementation does not require these sets to be
enumerable. They are represented by an abstract logic backend.

Each signature has a closure operator

```text
C_S : P(Sen(S)) -> P(Sen(S))
```

with the following laws:

```text
E subset C_S(E)                         extensivity
E subset E' implies C_S(E) subset C_S(E') monotonicity
C_S(C_S(E)) = C_S(E)                   idempotence
```

Transport must respect closure. The minimum useful law is

```text
Sen(u)(C_S(E)) subset C_T(Sen(u)(E)).
```

An institution supplies this closure from models and satisfaction:

```text
C_S(E) = { p | every S-model satisfying E also satisfies p }.
```

The executable theory does not enumerate models. It consumes an entailment or
closure capability with the same mathematical contract.

## 2. Presentations and theories

A **presentation** is a pair

```text
(S, E)
```

where `S` is a signature and `E` is a finite or lazy constraint expression over
`Sen(S)`. A sentence `p` is entailed when

```text
E entails p  iff  p in C_S(E).
```

A **closed theory** is a presentation whose constraints are a fixed point:

```text
E = C_S(E).
```

The implementation stores presentations and exposes closure as a capability.
The book's closed theories are recovered by applying the closure operation at a
semantic boundary. Therefore this is not a finite-only restriction: any
institution that supplies the transport and closure laws can instantiate it.

## 3. Theory arrows

For presentations `(S,E)` and `(T,F)`, a theory arrow consists of a signature
arrow `u : S -> T` and a preservation certificate:

```text
translate(u, E) subset C_T(F).
```

For a concrete backend, the certificate may be a checked finite inclusion, a
rewrite proof, a theorem-prover result, or an abstract entailment witness. The
core category never confuses syntactic equality with entailment.

Composition is direct:

```text
(v, preserve_F) after (u, preserve_E)
  = (v o u, preserve_v o preserve_E).
```

The preservation proof follows from transport compatibility and monotonicity.

## 4. Constraint expressions

The runtime does not materialize closures or repeatedly copy sentence sets. It
uses a persistent expression language:

```text
constraints ::=
    empty
  | add(sentence)
  | union(constraints, constraints)
  | translate(signature_arrow, constraints)
  | close(constraints)
  | inverse_translate(signature_arrow, constraints)
  | data_constraint(constraints)
```

The constructors have direct mathematical meanings:

```text
close(E)                 = C(E)
translate(u,E)           = Sen(u)(E)
inverse_translate(u,F)   = { p | Sen(u)(p) is in F }
data_constraint(E)       = backend-specific initial/data obligation
```

Expressions are immutable DAG nodes. Equal subexpressions may be shared, and a
backend may normalize only when entailment or a universal property is requested.

## 5. Chapter operations

### Combine

Given presentations `(S,E)` and `(T,F)`, take a tagged coproduct of signatures:

```text
S + T
```

and define

```text
combine((S,E),(T,F))
  = (S + T, union(translate(i_S,E), translate(i_T,F))).
```

The tags prevent accidental identification of equal names from independent
signatures. The result is closed only when `close` is requested.

### Enrich

An enrichment extends a signature `S` to `T` and adds constraints `A`:

```text
enrich((S,E), T, A) = (T, union(translate(i,E), A)).
```

The inclusion arrow is the resulting theory arrow.

### Parameter application

For a requirement arrow and an actual parameter arrow, construct the signature
pushout:

```text
R --r--> P
|        |
q        q'
v        v
S --s--> S +_R P
```

Transport both constraint expressions along `s` and `q'`, then combine them at
the pushout signature. This is the categorical meaning of applying a procedure
to a fitting theory.

### Free interpretation

Data constraints are represented explicitly rather than pretending that an
arbitrary algebra is initial. A backend may provide an `initial_model` or
`free_interpretation` capability. Without that capability, the presentation is
still valid but no initiality claim is made.

### Derive

Derivation factors a theory arrow through a smaller signature. The result keeps
the factorization certificate and only retains the selected sorts, operators,
and transported constraints. Dropped operations are not silently copied into
the derived theory.

## 6. Colimits of theories

For a finite diagram of presentations:

1. compute the signature colimit;
2. translate every constraint expression to the colimit signature;
3. form their structural union;
4. apply `close` only when a closed theory or an entailment query is required.

This construction is mathematically sound when the backend supplies the
transport/closure compatibility needed by the universal proof. The implementation
must return a capability error rather than claim a colimit when those premises
are absent.

The representation therefore separates:

```text
structural colimit construction  -- cheap, persistent, inspectable
closure/entailment               -- backend-owned, potentially expensive
universal certificate            -- checked at the requested boundary
```

## 7. Institutions as adapters

The full institution interface is recovered by an adapter:

```text
institution = {
  signature_category;
  sentence_transport;
  model_reduct;
  satisfies;
}
```

For a signature `S` and constraint expression `E`, the adapter defines
`entails(S,E,p)` by quantifying over models or delegating to a theorem prover.
The presentation layer does not know whether the backend is equational logic,
first-order logic, a rewrite system, a finite model checker, or an external
solver.

This preserves the generality of Chapter 9 while avoiding an always-materialized
`Mod`, `Sen`, satisfaction relation, and closed sentence set in every value.

## 8. Environments and based objects

An environment is a finite diagram of presentation arrows. A based object is a
cocone whose base is a subdiagram of that environment. A based arrow preserves
the cocone and embeds the base.

The executable representation should store:

```text
base_nodes   : dense node IDs
base_arrows  : dense arrow IDs
apex         : presentation
legs         : immutable indexed maps
```

Based colimits are obtained by taking the union of base diagrams, flattening the
resulting finite diagram, and applying the structural colimit procedure above.
No nested list traversal is required for ordinary lookup.

## 9. Grothendieck construction exercise

For every signature `S`, define a fiber category `Constraint(S)`:

```text
objects = constraint expressions over S
arrows  = entailment-preserving inclusions
```

For a signature arrow `u : S -> T`, reindexing is

```text
Constraint(u)(E) = close(translate(u,E)).
```

The Grothendieck construction has:

```text
objects = (S,E)
arrows  = (u : S -> T, translate(u,E) entails F).
```

This is isomorphic to the category of generalized theories defined above. The
proof is by matching object pairs and arrow preservation certificates in both
directions.

## 10. Functional implementation boundary

The eventual OCaml interfaces should name operations by their mathematical
function:

```text
module type Constraint_logic = sig
  type signature
  type arrow
  type sentence
  type model

  val map_sentence : arrow -> sentence -> (sentence, error) result
  val close : signature -> constraint_expr -> (constraint_expr, error) result
  val entails : signature -> constraint_expr -> sentence -> (bool, error) result
end

type presentation
type theory_arrow
val combine : presentation -> presentation -> (presentation, error) result
val enrich : presentation -> signature -> constraint_expr ->
  (presentation, error) result
val parameter_apply : ...
val derive : ...
val colimit : ...
```

The exact module split remains an implementation decision. The mathematical
boundary is fixed: signatures determine transport, constraints determine
composition, the logic backend determines closure/entailment, and universal
constructors determine colimit certificates.

## 11. Current implementation

The generalized presentation kernel is implemented in
`Constructions.Presentations`. Its backend contract owns signature transport,
constraint expressions, closure, entailment certificates, signature
coproducts, and signature pushouts. The kernel implements presentation
construction, closure, theory-arrow admission, combine, enrich, parameter
application, and the presentation category.

`tests/presentations_test.ml` supplies a small abstract logic backend to verify
that these operations do not depend on equational syntax or finite models.

The remaining Chapter 9 implementations—concrete institution adapters, generic theory
colimits, based environments, semantic-operation interpretation, and the full
Grothendieck construction—are subsequent implementation work. The kernel is
more general than a finite equational theory and more efficient than eagerly
storing closed sentence sets. It does not claim that closure is computable for
every institution; each backend must state its own entailment, model,
termination, and universal-construction limits.
