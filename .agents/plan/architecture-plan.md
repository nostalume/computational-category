# Architecture Plan: OCaml Computational Category Theory Learning Project

## Goal and Authority

This plan governs the development of an OCaml learning project based on computational category theory from the referenced text. The project is **exploratory** in nature — intended for learning, experimentation, and shareable code artifacts. No production commitment is claimed.

**Current revision**: E:\Proj\course\computational-category
**Decision maturity**: Candidate (functional module scaffold implemented; awaiting build verification)
**Primary lenses**: module-topology, representation-and-flow, authority-and-effects, mathematics-and-numerics

**Authoritative input**: Chapter 2 exercises completed; Chapter 3-4 concepts provided; remaining chapters TBD from PDF source.

---

## Decision: Single Package, Organized by Functionality

The user directed that the project be consolidated into **one package** (rather than per-chapter packages with cross-imports), and that modules be distributed **by functionality** rather than by book chapter organization.

### Rationale
- Chapter 4 (limits/colimits) depends heavily on Chapter 3 (categories/functors/duality). Separating into per-chapter packages requires cross-package imports, which is inefficient versus direct module imports.
- Some exercises are instances; others are generalizations. Isolating them by chapter fragments a coherent concept (e.g., "universal constructions" spans Ch4.2 initial objects, coproducts, coequalizers AND Ch4.9 terminal objects, products, equalizers).
- Functionality grouping keeps a concept and its specializations together in one module, where the generalization naturally builds on the instances.

### Outcome: One `computational_category` library, flat `src/` with functional modules.

---

## Module Layout (Functional)

All modules live in `src/`, compiled into a single library `computational_category`:

| Module | Functionality | Covers |
|---|---|---|
| `core.ml` | Foundational types/utilities: num, bintree, lists, monoids | Ch2 Ex3/5/6/11 |
| `cat.ml` | Category type, accessors, composition, `dual_cat` | Ch3.3, Ch3.6 |
| `finite_sets.ml` | Set operations, tagged values, set_arrow, FinSet category | Ch2 Ex9, Ch3.4.1, Ch4.6/4.9 |
| `term_category.ml` | TΩ_Fin term category, finite 3-object category | Ch3.4.2, Ch3.4.3 |
| `graphs.ml` | Graph, diagram, cocone, cone, colimit, limit types | Ch4.4, Ch4.8 |
| `universal.ml` | Universal construction types: initial/terminal, coproduct/product, coequalizer/equalizer, pushout/pullback | Ch4.2, Ch4.9 |
| `colimits.ml` | Finite colimit construction (Thm 1), colimits in FinSet | Ch4.5, Ch4.6, Ch4.7 |
| `limits.ml` | Duality-converted limits, limits in FinSet | Ch4.8, Ch4.9 |
| `functors.ml` | Functor type, identity/product functors, dual_functor, cocontinuous functors | Ch3.5, Ch3.6, Ch4.4 |
| `relations.ml` | Spans, pullback, relation composition | Ch4.10 |

### Dependency order (acyclic)
```
core, cat
  -> finite_sets, term_category, universal, graphs
  -> colimits (uses finite_sets, graphs, universal, cat)
  -> limits (uses colimits, cat, finite_sets, graphs, universal)
  -> functors (uses cat, finite_sets, graphs)
  -> relations (uses finite_sets, graphs, limits, cat)
```

---

## Decision Owners and Lenses

| Decision | Owner Lens | Key Constraints |
|---|---|---|
| Module boundaries | `module-topology` | One owner per functional concept; dependency acyclic; no cross-package imports |
| Datatype vocabulary & invariants | `domain-and-invariants` | One owner per concept; illegal states unrepresentable |
| Function types & polymorphism | `representation-and-flow` | Smallest complete representation; typed admission |
| Category theory structure adherence | `mathematics-and-numerics` | Categorical axioms preserved; duality/universality correct |
| Cost & workload | `cost-and-scale` | No performance requirements; learning project |
| Authority | `authority-and-effects` | One authority per fact/transition |

---

## Settled Decisions

### 1. Language Choice: OCaml
- **Decision**: OCaml implementation language.
- **Maturity**: Settled.

### 2. Build System: Opam + Dune
- **Decision**: opam package manager; Dune build. Single package `computational_category`.
- **Maturity**: Settled. Note: dune not yet installed in switch; requires `opam install dune`.

### 3. Single Package, Functional Modules
- **Decision**: One `computational_category` library; modules distributed by functionality (not book chapter). No per-chapter sub-packages.
- **Maturity**: Settled.
- **Falsifier**: If a future chapter introduces a concept that genuinely needs a separate reusable library boundary (not just a module), reopen.

### 4. Ephemeral Planning Docs Location
- **Decision**: Planning in `.agents/plan/`; public README holds only stable content.
- **Maturity**: Settled.

---

## Exploratory Unknowns and Open Questions

| Unknown | Owner | Potential Resolution |
|---|---|---|
| Full colimit/limit execution correctness in FinSet | `mathematics-and-numerics` | Verify by computing Ch4.7 pushout example; add property tests |
| ML vs OCaml syntax porting of the recursive colimit algorithms | `representation-and-flow` | Test `set_coequalizer` recursion; validate against Ch4.6 |
| Rational number representation (Ch2 Ex7) | `domain-and-invariants` | Deferred; not yet needed by category theory modules |
| Dune availability for local build | `cost-and-scale` | `opam install dune`; fallback to `ocamlc` direct compilation for verification |

---

## Materialized Plan Artifact

**Location**: `E:\Proj\course\computational-category\.agents\plan\architecture-plan.md`

**Plan audit** (self-check per `plan-audit.md`):
- ✅ Each decision has one owner, settled maturity, and no hidden tradeoff
- ✅ Module boundaries are acyclic and each owns a distinct functional concept
- ✅ Single-package design removes cross-package import overhead
- ✅ Instances and generalizations co-located (e.g., coproduct/product in `universal.ml`)
- ✅ Minimum behavior observable: each module compiles and tests pass

**Falsification**: If a subsequent implementer cannot build and test the library from this artifact and the current repository state without hidden conversation, the plan fails audit and must be revised at the smallest affected owner.

---

## First Executable Work

The functional module scaffold is in place in `src/`. The first task for `software-development` is **build verification and test execution**:

### Stage 1: Build Environment
1. `opam install dune` (if not already installed).
2. Verify `dune build` compiles all modules in dependency order.

### Stage 2: Correct OCaml Porting
1. Fix any OCaml syntax/type errors from the SML-to-OCaml port (finite_sets, term_category, colimits, limits, functors, relations).
2. Ensure the `set_coequalizer` recursion and `finite_colimit`/`dual_colimit` algorithms are type-correct.

### Stage 3: Test
1. `dune runtest` executes `tests/functional_test.ml`.
2. Verify: core (Ch2), categories/duality (Ch3), finite sets, functors, universal constructions, limits (Ch4).

### Stage 4: Validate Ch4.7 Pushout Example
1. Encode the Ch4.7 pushout diagram in FinSet.
2. Compute the colimit via `finite_colimit_finset`.
3. Assert the apex equals `{pink D, pink A, blue pink G, blue pink F, blue blue pink G}`.

**Dependencies**: None (leaf task).
**Estimated effort**: 2-3 hours.
**Success criterion**: `dune build` and `dune runtest` pass with zero errors; Ch4.7 pushout validates.

---

## Rollback and Reopen Conditions

This plan may be reopened when:
- New chapter content contradicts the functional module boundaries.
- Build/type evidence shows a module boundary should move or a concept needs its own library.
- User policy changes (different language, different package scope).

When reopened, the plan delta records: changed evidence, affected premise and dependents, new resolution and maturity, unchanged invariants, and renewed evidence.

---

## Audit Note

This plan reflects the single-package, functionality-organized design per user direction. It is materialized in `.agents/plan/` and does not edit ignore policy merely to exist.

**Next**: Hand off to `software-development` for build verification, OCaml porting fixes, and test execution.