# Computational Category Theory in OCaml

This library turns categorical definitions into checked executable operations. It
follows the mathematical structure of *Computational Category Theory* while
keeping runtime representations chosen for equality, sharing, and finite
computation rather than copying the book's data structures literally.

> **A category-theoretic learning library:** definitions first, executable
> representations second, and every premise visible at the API boundary.

## Contents

- [What this library provides](#what-this-library-provides)
- [Build and test](#build-and-test)
- [First API example](#first-api-example-finite-carriers-and-morphisms)
- [API principles](#api-principles)
- [Mathematical reading guides](#mathematical-reading-guides)
- [Verification and limits](#verification-and-limits)
- [License](#license)

The central idea is simple:

```text
mathematical object  ->  admitted value
mathematical arrow   ->  checked morphism
universal property   ->  chosen object + legs + mediator
law or premise       ->  explicit capability or result-valued check
```

The package is a learning implementation, not a replacement for a proof
assistant or a complete implementation of every infinite construction in the
book.

## What this library provides

| Mathematical subject | Executable capability |
| --- | --- |
| Finite sets and arrows | Equality-owned carriers and frozen morphisms |
| Categories and universals | Checked composition, products, quotients, limits, and colimits |
| Relations and graphs | Witness-preserving spans, incidence maps, and rewriting |
| Adjunctions and algebras | Units, counits, algebra squares, and bounded free constructions |
| Toposes | Finite exponentials, classifiers, quantifiers, and graph-topos examples |
| Unification | Dense-ID, union-find first-order solver derived from coequalizers |
| Specifications | Generalized closure-based presentations with abstract logic backends |

The implementation makes premises visible. Constructing a category record does
not prove its laws; constructing a universal record does not invent a missing
mediator; and finite observations do not establish arbitrary infinite claims.

## Build and test

With OCaml and Dune available:

```sh
dune build --cache=disabled --no-config
dune runtest --cache=disabled --no-config --force
```

The declared minimums are OCaml 4.14 and Dune 3.7. Verification has been run
with OCaml 5.2.1 and Dune 3.24.2. These commands build and test the package;
they do not install or publish it.

## First API example: finite carriers and morphisms

All public modules are under the wrapped namespace `Computational_category`.
A finite carrier is created with an explicit atom equality:

```ocaml
open Computational_category

module F = Instances.Finite_sets.Make (struct
  type t = int
  let equal (a : int) b = a = b
end)

let source = F.carrier_of_list [F.atom 1; F.atom 2]
let target = F.carrier_of_list [F.atom 10; F.atom 20]

let double =
  match F.morphism_result source
          (fun x ->
             match F.view x with
             | F.Atom 1 -> Ok (F.atom 10)
             | F.Atom 2 -> Ok (F.atom 20)
             | _ -> Error (Foundations.Category.Malformed_term "atom"))
          target with
  | Ok arrow -> arrow
  | Error error -> failwith "invalid morphism"

let image = F.eval double (F.atom 1)
```

`carrier_of_list` removes duplicates under the supplied equality. `carrier_to_list`
is an operational enumeration, not a mathematical ordering. Morphism admission
checks every image and freezes the callback results. `eval` returns a typed error
when its argument is outside the domain.

## API principles

### Equality and composition

- `E.equal` is the authority for atoms; it must be stable and terminating.
- Distinct equality modules produce distinct finite-set types.
- `equal_carrier` and `equal_morphism` are extensional.
- `Foundations.Category.compose c g f` and `F.compose g f` mean **g after f**.
- Callbacks and supplied category laws are caller obligations; unexpected
  exceptions are not converted into semantic errors.

### Result-valued admission

Expected invalid inputs return
`('a, Foundations.Category.error) result`. Important errors include
`Non_composable`, `Outside_domain`, `Outside_codomain`, `Malformed_diagram`,
`Malformed_term`, `Different_base`, and `Non_commuting`.

A concise example may use a local `get` helper, but application code should
match `Ok` and `Error` and decide how to recover.

### Universal constructions

Universal records expose a chosen object, its legs, and a mediator function.
For example, a product provides:

```text
product(A,B) = (P, p1, p2)
pair(X,f,g)  = the checked u : X -> P
```

The mediator must satisfy the projection equations. The finite instances use
arrays and position-aware paths internally, while retaining the equality-only
public contract.

### Functional construction APIs

Use the domain vocabulary of the operation:

```text
Finite_graphs.graph_morphism
Functor_category.finite_functor
Functor_category.natural_transformation
Algebras.algebra_morphism
Finite_slice_topos.exponential
Finite_graph_topos.classifier
```

Generic category and comma arrows remain generic because they are projections of
those abstractions. Concrete APIs do not retain compatibility aliases merely to
preserve retired names.

### Unification

`Instances.Term_unification` represents operator arguments with arrays, compiles
variables to dense IDs, and uses union-find/path compression. It provides
occurs-checking unification, frozen substitutions, and memoized generalization.
`Instances.Terms` remains an adapter for the book's list-labelled term surface.

### Generalized theory presentations

`Constructions.Presentations` is parameterized by a `LOGIC` backend. The backend
owns sentence transport, closure, entailment, signature coproducts, and
signature pushouts. The presentation layer owns theory arrows, combine, enrich,
and parameter application without assuming equations, finite models, or an
explicitly enumerated closure.

## Mathematical reading guides

- [Finite carriers and universal constructions](docs/chapter2-4.md)
- [Category constructions](docs/chapter5.md)
- [Adjunctions and algebras](docs/chapter6.md)
- [Exponentials and toposes](docs/chapter7.md)
- [Categorical unification](docs/chapter8.md)
- [Generalized theory presentations](docs/chapter9.md)

Each guide starts with the mathematical definition, derives a representation,
then explains the API, evidence, and limits.

## Verification and limits

The current test suite contains twelve executables and 52 behavioral groups,
covering foundations, universal constructions, relations, category
constructions, adjunctions, algebras, finite toposes, unification, and
presentation operations. Type-contract fixtures separately check public and
private boundaries.

The evidence is finite and bounded. It does not prove arbitrary supplied
category laws, termination of arbitrary callbacks, semantic closure for every
institution, infinite natural-transformation equality, or general infinite
universal constructions. Chapter 10 is intentionally not implemented here; it
is an extended investigation of category implementations in other languages.

## License

This project is distributed under the [MIT License](LICENSE).
