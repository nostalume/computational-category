# Computational Category Theory in OCaml

A learning implementation of selected material from D. E. Rydeheard and
R. M. Burstall, *Computational Category Theory*: Chapter 2 foundations,
Chapter 3 categories and functors, and Chapter 4 finite universal constructions
and relations, followed by Chapter 5 category constructions and exercise solutions.
This is not a complete implementation of the book.

[The Chapter 5 guide](docs/chapter5.md) contains all twelve exercise solutions
and separates general proofs from finite-domain, uniform-fiber and injective
rewriting restrictions. Production namespaces follow mathematics, not chapters.

## Build and test

From the repository root, with OCaml and Dune already available on your PATH:

```sh
dune build --cache=disabled --no-config
dune runtest --cache=disabled --no-config --force
```

These commands work in PowerShell as well as a POSIX shell. They create local
`_build` artifacts; they do not install or publish the package. Use the normal
development profile: no warning suppression is needed.

The manifests declare OCaml >= 4.14 and Dune >= 3.7. Verification used OCaml
5.2.1 and Dune 3.24.2 on Windows with an existing Opam/Cygwin toolchain;
the declared minimum versions and other platforms have not been verified.
The library also links OCaml's `unix` library. Toolchain installation and a
published registry distribution are outside this project's current verification.

Success means six executables pass all **33 behavioral groups**, with coverage
counts. See [Verification and limits](#verification-and-limits).

## Public library example

The package and Dune library name is `computational_category`; the public OCaml
wrapper is `Computational_category`. Code linked against the local library
starts with `open Computational_category`, not unwrapped module imports.

This complete example composes the book's relations (printed pp. 97–100).
Composition is **next after previous**. There are four compatible witnesses,
but only three distinct endpoint pairs.

```ocaml
open Computational_category

module F = Instances.Finite_sets.Make (struct
  type t = int
  let equal (a : int) b = a = b
end)
module L = Instances.Finite_set_universals.Make (F)
module R = Instances.Finite_relations.Make (F)

(* A short example treats unexpected admission failure as a failed assertion.
   Applications should instead match Error and handle the relevant Foundations.Category.error. *)
let get = function Ok x -> x | Error _ -> failwith "example admission failed"
let ints xs = F.of_list (List.map F.atom xs)
let pairs xs =
  F.of_list (List.map (fun (x, y) -> F.pair (F.atom x) (F.atom y)) xs)

let () =
  let a = ints [1; 2] and b = ints [3; 4; 5] and c = ints [6; 7] in
  let previous =
    get (R.relation_span ~left:a ~right:b (pairs [1,3; 2,3; 2,4])) in
  let next =
    get (R.relation_span ~left:b ~right:c (pairs [3,6; 4,6; 4,7; 5,6])) in
  let composed = get (Constructions.Spans.compose L.complete_finset next previous) in
  let image = get (R.image composed) in
  assert (F.cardinality (Constructions.Spans.span_source composed) = 4);
  assert (F.seteq image (pairs [1,6; 2,6; 2,7]));
  Printf.printf "witnesses=%d, image pairs=%d\n"
    (F.cardinality (Constructions.Spans.span_source composed)) (F.cardinality image)
```

Expected output: `witnesses=4, image pairs=3`.
The example has been compiled, linked and executed as a separate consumer of
the local wrapped library, without installation. A Dune executable in this
project can link it with `(libraries computational_category)`.

## Values, admission and failure

- `Instances.Finite_sets.Make(E)` owns abstract `value`, `set` and `arrow` types.
  Distinct equality modules have distinct types; do not mix their objects.
  `E.equal` must be a stable, terminating equivalence on immutable atoms.
- Values form a closed recursive universe: `atom`, `tag`, `pair` and
  `terminal`. Inspect them with `view`. Nested tags and pairs are retained;
  terminal is a dedicated value, independent of the atom type.
- `of_list` removes duplicates under the supplied equality; `seteq` is
  extensional, not list-order equality. `to_list` provides an enumeration,
  not a canonical ordering. Quotients use actual value representatives;
  enumeration can change representatives and presentations up to isomorphism.
  `Instances.Finite_set_universals.Make(F).set_coequalizer_classes` separately exposes immutable
  classes, not a cast class-list codomain.
- `F.arrow source callback target` checks every admitted source value's image
  for target membership. On success it samples the callback once per distinct
  source value and freezes the map. Use `arrow_result` for checked callbacks.
  `apply` outside the source returns `Error (Foundations.Category.Outside_domain ...)`.
- `Foundations.Category.compose category g f` and `F.compose g f` mean **g after f**.
  The generic operation delegates to the dictionary's checked composition and
  equality, not OCaml structural equality.
- Graphs, diagrams, cones, cocones and spans are abstract admitted values.
  Builders check finite label bindings, endpoints, and applicable commuting
  equations. Supply complete named bindings; duplicate/missing labels and
  dangling edges are rejected. `same_base` compares labelled diagrams
  extensionally under the category's object/arrow equality.
- In the checked categorical APIs, expected invalid inputs return
  `('a, Foundations.Category.error) result`: for example
  `Non_composable`, `Non_parallel`, `Outside_codomain`,
  `Malformed_graph`, `Malformed_diagram`, `Malformed_term`,
  `Malformed_relation`, `Different_base` and `Non_commuting`.
  Constructors that cannot fail on admitted inputs, such as identity, remain
  direct-returning. User callback/equality exceptions and runtime failures
  propagate unchanged; they are not disguised as semantic errors.

The retained `Exercises.Basic` exercises have their own original conventions: for example,
`Exercises.Basic.max_list []` raises `Exercises.Basic.EmptyList`, and `int_pow` assumes a nonnegative
exponent. The checked categorical API is not a blanket result conversion of Exercises.Basic.

Generic callers must supply lawful, coherent, stable category dictionaries and
universal capabilities for the same category. Category/functor laws and the
premises for universal maps are not automatically proved by record construction.
Dual limit/colimit adapters require a capability for the **opposite** category
of the input diagram. Term substitutions use finite immutable snapshots and
syntactic term equality, not alpha-equivalence.

Callbacks should be pure and terminating. Snapshotting does not make mutable
atoms safe, prove equality laws, impose timeouts or guarantee bounded memory/stack
use. An admission returning an error can stop before sampling later inputs.

## Construction and module ownership

This is a dependency graph, not a chain in which every file only uses one layer.

| Owner (source/interface) | Responsibility |
| --- | --- |
| [Foundations.Category](src/foundations/category.ml) | Equality, checked composition, errors and opposites |
| [Foundations.Functor](src/foundations/functor.ml) | General functor capabilities, identities, constants and composition |
| [Universal.Diagrams](src/universal/diagrams.mli) | Admitted shapes, cones/cocones, morphisms and functor mapping |
| [Universal.Limits](src/universal/limits.mli) | Primitive/chosen universals, one generic finite colimit and its dual; Free/Cofree |
| [Universal.Preservation](src/universal/preservation.ml) | Continuity, cocontinuity and inverse-functor transport |
| [Constructions.Elementary](src/constructions/elementary.ml) | One/product/slice/coslice categories; Twisted child |
| [Constructions.Comma](src/constructions/comma.mli) | Admitted objects/squares, projections and inherited universals |
| [Constructions.Functor_category](src/constructions/functor_category.mli) | Finite-domain functors/naturals and pointwise universals |
| [Constructions.Indexed](src/constructions/indexed.mli) | Strict uniform-fiber inheritance |
| [Constructions.Spans](src/constructions/spans.mli) | Witness-bearing composition via checked pullback |
| [Instances.Finite_sets](src/instances/finite_sets.ml) | Equality-owned recursive values, sets and frozen arrows |
| [Instances.Finite_set_universals.Make(F)](src/instances/finite_set_universals.ml) | Concrete limits/colimits and square preservation, sharing F |
| [Instances.Finite_graphs](src/instances/finite_graphs.ml) | Multigraphs and inherited universals; Labelled/Rewriting children |
| [Instances.Finite_relations.Make(F)](src/instances/finite_relations.mli) | Pair carriers and extensional images |
| [Instances.Terms](src/instances/terms.mli) | Finite terms and frozen substitutions |
| [Exercises.Basic](src/exercises/basic.ml) | Natural-number, tree, list, fold and monoid exercises |

The generic colimit follows the finite induction in the book (printed
pp. 83–88). An empty discrete diagram uses the initial object. Adding a discrete
node uses a coproduct and the universal map for the actual remaining subdiagram.
Adding an edge coequalizes the two induced maps from its source into the prior
apex. A commuting candidate cocone makes those maps equal after its induced map,
so the coequalizer factors it. Uniqueness follows from the previous universal
map and the primitive factorization's uniqueness. This is a construction
argument under the supplied laws, not a machine-checked proof.

General limits reuse this construction in the opposite category, reversing
shape endpoints and universal-arrow direction. Pushout and pullback use the
shared three-node/two-edge diagrams; there is no second generic algorithm.

Span composition preserves distinct compatible witness pairs. Identity and
associativity are compared **up to span isomorphism**, not equality of witness
encodings. `Instances.Finite_relations.Make(F).image` deduplicates endpoint pairs separately
without changing the span; an empty relation still retains its declared endpoints.

## Verification and limits

Tests are grouped by mathematical subject, not book chronology:

| Suite | Groups and selected evidence |
| --- | --- |
| [Foundations](tests/foundations_test.ml) | 5: exercises, admission, categories, terms, functors; 36 maps, 973 associativity triples |
| [Universals](tests/universal_test.ml) | 8: primitives, diagrams, duality and failures; 6,110 maps, 1,020 primitive unique mediators; 461 FinSet diagrams, 5,350 mediators, 5,529 uniqueness cases, 351 larger equation-only cases; 39 Boolean diagrams, 100 mediators; 114 pullbacks |
| [Spans and relations](tests/spans_relations_test.ml) | 7: 47 admissions, 803 pairs against an existential oracle, 15,625 associativity triples, 15,771 span isomorphisms |
| [Category constructions and graphs](tests/constructions_test.ml) | 7: diagram maps, comma/elementary categories, multigraphs, labels and rewriting; 101 law triples |
| [Functor categories](tests/functor_category_test.ml) | 4: admission, vertical/horizontal composition and pointwise universals; 551 natural admissions, 576,095 law triples, 3 selected exhaustive mediators |
| [Indexed and free/cofree structures](tests/indexed_test.ml) | 2: inherited universals and fixed-shape adapters; 1,976 law triples, 2 selected exhaustive mediators |

Private test support owns assertion helpers, the shared bounded FinSet fixture,
and one toy category. Independent universality, Boolean and relation oracles
remain in their suites; production does not depend on test support.

Additional regressions cover the book's five-class pushout (printed pp. 90–92)
and four-witness relation composition; reordered enumerations, nonstructural
atomic equality, nested values, empty objects, failed admission and propagated
exceptions. Generic behavior is also exercised outside FinSet.

These are bounded checks. Diagram fixtures use up to three nodes and two edges
over subsets of a two-atom set. FinSet mediator uniqueness enumeration is
restricted to selected apex sizes at most four; larger derived colimit/limit
apices (up to six/eight) receive equation checks, not exhaustive uniqueness
search. Span associativity enumerates a fixed family of 25 endospans with
derived witness carriers at most eight. Counts are evidence, not promised
workload limits or an exhaustive proof of arbitrary inputs.

`tests/type_contracts/*.ml.txt` are separate manual compiler fixtures, **not**
part of `dune runtest`. Both positive public consumers compile; ten negative
fixtures must fail specifically for mixed equality universes, raw arrow
records, private partition access, raw graph/span records, and raw comma,
functor, natural-transformation, twisted-arrow and indexed records.

No machine-checked proof, scalability target or production-readiness claim is made.
The scope excludes completing all Chapter 2 exercises, Chapters 6–10, unchecked
infinite-domain natural-transformation equality, a heterogeneous category library,
full graph-grammar/regex compilation and package publication.

## Local API migration

This is the uncommitted local 0.1.0 mathematical-layout cutover, not a published
compatibility release. The wrapped library name is unchanged; flat paths have
no compatibility shims. Relative to the pre-layout working tree:

| Retired owner | Current owner |
| --- | --- |
| Cat / Core | Foundations.Category / Exercises.Basic |
| Universal / Abstract_limits | Universal.Limits; Free and Cofree children |
| Graphs | Universal.Diagrams for admission/maps; Universal.Limits for chosen universals/algorithms |
| Functors | Foundations.Functor for capabilities; Diagrams for mapping; Preservation for transport; Finite_set_universals.Make(F) for square operations |
| Colimits.Make(F) / Limits.Make(F) | One Instances.Finite_set_universals.Make(F), sharing the same F |
| Category_constructions / Twisted_arrows / Comma_categories | Constructions.Elementary / Elementary.Twisted / Comma |
| Functor_categories / Indexed_categories | Constructions.Functor_category / Indexed |
| Relations | Constructions.Spans; Instances.Finite_relations.Make(F) for relation admission/image |
| Finite_sets / Finite_graphs / Term_category.TermCategory | Instances.Finite_sets / Finite_graphs / Terms |

Use the fully qualified owners in the source table (all under
Computational_category). The old Term_category.FiniteCategory toy belongs only
to private test support; it is not a replacement public category instance.
General theory must not import Instances. Supply lawful capabilities for the
same category and use admitted builders, not raw records or casts. Preserve
composition order, frozen maps, distinct equality universes and witness/image
separation. Repository tests and both complete examples use the new paths.
