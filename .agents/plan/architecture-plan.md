# Architecture Plan: Mathematical Hierarchy for Computational Category Theory

Canonical, tracked handoff for E:/Proj/course/computational-category.
Only this file governs the current refactor. [Historical delivery evidence](evidence/pre-layout-audit.md)
retains the previous Chapter 2-5 work and its scoped proof/exercise qualifications;
it is not a second active plan. Do not untrack this file or change ignore policy.

## Mathematical-layout refactor — 2026-10-10


### Authority and status
Requested consequence: repair the mathematical module layout, in four stages.
The user's latest agreement authorizes Stage 13 integrated acceptance.
The LOC-reduction preference remains local to this development: reduce justified
duplication, never mathematical coverage or type boundaries for a count.
Clean local public-module/API migration and declared Dune minimum 3.7 are
approved design choices. Installed Dune 3.24.2 needs no upgrade.
Historical Stages 1-9 remain completed evidence. All four layout stages 10-13
are complete; no further implementation stage is proposed by this plan.

Keep one wrapped computational_category package and OCaml >=4.14. Preserve
existing mathematics, lawful capability premises, abstract admitted types,
custom equality, result errors, exception propagation, composition order,
finite source enumeration, uniform fibers and injective DPO scope.
No Chapter 6 implementation, algorithm rewrite, install, publication, commit,
worktree or independent-agent task is part of this refactor.

### Revision-scoped evaluation
HEAD remains 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c, with the delivered work
uncommitted. Source/tests/manifests/docs and their callers were inspected;
no applicable AGENTS.md was found. Stage 10 entry src had 17 implementations, 6 interfaces,
2,163 implementation lines and 97,267 implementation bytes. The Stage 10 entry
canonical plan has 123,943 bytes. Counts establish scale, not a file-size gate.

Observed ownership problems:
- Graphs combines diagram shapes/admission, chosen universal capabilities,
  the generic colimit algorithm, duality and universal-map operations. Its name
  also obscures the distinction from actual graph objects in Finite_graphs.
- Functors combines base functor capabilities, diagram mapping/preservation
  and concrete FinSet square operations; ocamldep confirms imports of both
  Graphs and Finite_sets.
- Colimits and Limits are actually FinSet instances, not generic theory.
- Relations mixes generic spans with concrete finite carriers/images.
  Term_category also contains an unrelated three-object textbook category.
- Abstract_limits and Twisted_arrows preserve useful mathematics but need not
  be independent physical files: named children of their natural owners suffice.
- functional_test and chapter5_test mix mathematical subjects; file chronology
  does not express capability ownership.
- The canonical plan is an oversized audit log, larger than all implementation
  files combined, rather than a concise active handoff.

Counter-evidence: dependencies are acyclic and universal algorithms are already
shared. Interfaces protect real admission/type boundaries, not redundant
ceremony. Seventeen modules for this scope is not itself excessive.
The defect is mixed owners and unrelated flat exposure, not simply file count.

Inspected flow: graph bindings/frozen FinSet maps -> admitted comma object ->
inherited graph product -> swapped comma duality -> shared generic colimit/
FinSet dual primitives -> checked projections and mediator. Invalid incidence
or squares return Cat.error. This flow has no required persistent runtime effect.

### Settled owner/dependency decisions
The new user-owned hierarchy objective reopens C5.3's flat physical projection
only. Its invariant ownership, shape/object distinction, sharing and no-cycle
constraints remain. General theory must not import concrete instances.

1. Foundations: category dictionaries/errors and general functor capabilities,
   identities, composition and opposites; no FinSet or diagram dependency.
2. Diagrams: shapes, diagram/cone/cocone admission and their morphisms,
   triangle checks and mapping through general functors.
3. Universal constructions: primitive universal contracts, chosen (co)limits/
   capability data, one generic finite-colimit algorithm, dual limits,
   binary specializations, induced universal maps and fixed-shape Free/Cofree.
   Move chosen-capability/algorithm operations out of Diagrams so Diagrams
   never needs to import their owner back.
4. Preservation: continuity/cocontinuity and inverse-functor transport; depends
   on the preceding owners, not on concrete FinSet.
5. Category constructions: elementary, comma, finite-domain functor categories,
   indexed categories and generic spans. Keep their distinct admission laws.
   Nest one/product/slice/coslice/twisted under one elementary owner.
6. Instances: FinSet values and concrete universal operations, finite graphs,
   finite relation carriers/images, and terms/substitutions. Consolidate
   concrete colimits/limits/square operations around the same supplied F without
   duplicating its value universe or private partition scratch. Graph-specific
   Labelled/Rewriting stay named children, not extra facades or an NFA compiler.
7. Exercises: standalone Chapter 2 algorithms, not categorical infrastructure.
   Move the textbook FiniteCategory example once to shared test fixture support:
   its only inspected callers are functional_test and chapter5_test.
   Do not keep it inside terms or duplicate it in both suites.

Candidate physical projection (owners govern; exact private syntax is not frozen):

src/
  foundations/  category.ml, functor.ml
  universal/    diagrams.ml, limits.ml, preservation.ml
                # limits owns both dual families and named Free/Cofree operations
  constructions/
                elementary.ml, comma.ml, functor_category.ml, indexed.ml, spans.ml
  instances/    finite_sets.ml, finite_set_universals.ml, finite_graphs.ml,
                finite_relations.ml, terms.ml
  exercises/    basic.ml

Source namespaces follow directories, e.g.
Computational_category.Foundations.Category,
Computational_category.Universal.Diagrams,
Computational_category.Constructions.Comma,
Computational_category.Instances.Finite_graphs.
This is a dependency-aware hierarchy, not a linear ranking of mathematical
importance: graph instances use both generic comma theory and concrete FinSet.

Use native Dune include_subdirs qualified, not handwritten re-export layers
or per-chapter packages. Official documentation confirms directory-derived
module groups:
[Dune include_subdirs](https://dune.readthedocs.io/en/stable/reference/dune/include_subdirs.html).
Installed Dune CHANGES.md records qualified OCaml support in its 3.7.0 section.
Both language declaration and manifest minimum change coherently to 3.7.
Actual nested-module compilation is an early bounded probe, not verified by
documentation alone. Running the actual Dune 3.7/OCaml 4.14 minima remains
unverified unless those toolchains are available and tested.

Clean cutover is user-approved: migrate repository callers, examples, tests,
interfaces and documentation; retire superseded module names. Do not retain
Graphs/Colimits/Limits forwarding facades solely for yesterday's layout.
No external compatibility release is promised. A newly discovered supported
external consumer reopens only this boundary.

Tests should mirror mathematical subjects and keep shared fixtures only where
multiple callers justify them. Chapter numbers remain a book/exercise index
in docs/chapter5.md, not production namespaces. Do not copy that guide into
several new theory manuals. Compact the active canonical plan during
implementation; preserve old execution evidence once in an explicitly
historical audit artifact with a distinct lifecycle. Keep the plan tracked
and leave ignore rules unchanged.

Alternatives:
- Folder-only moves with old flat/mixed modules: insufficient ownership repair.
- One giant theory file: hides distinct admission and instance boundaries.
- Per-chapter libraries/one file per theorem: adds wiring without a consumer.
- Semantic groups plus selected merges/extractions: selected. Fewer unrelated
  top-level owners, not a promised dramatic drop in total files or removal of mli.

### Stage 10 — Recoverable baseline and namespace feasibility
Consumer: implementer/reviewer. Dependency: implementation authorization.
- [x] 10.1 Preserve a recoverable snapshot of the actual dirty working tree;
  inventory current public symbols and assign each one destination owner.
  Capture baseline checks. Never reset to HEAD, which lacks delivered work.
  Keep the canonical handoff compact and preserve old audit evidence once.
- [x] 10.2 Probe qualified nested imports, sealing and wrapped public consumer
  resolution in owned temporary scope using existing tools. Confirm no
  parent-module cycle or requirement beyond the accepted Dune floor.
Exit: recovery input, API map, baseline evidence and feasible namespace mechanism.
A failed probe reopens only the tooling projection before real manifest changes.

### Stage 11 — Buildable owner and namespace cutover
Consumer: library callers. Dependency: Stage 10.
- [x] 11.1 Separate diagram/universal/functor owners, consolidate elementary/
  free/concrete FinSet operations, separate spans from finite images and place
  them in semantic groups. Migrate all source/test/example/fixture callers as
  part of the same coherent cutover; preserve type abstractions and behavior.
Exit: normal-profile build/tests and public compiler fixtures use new paths;
general theory imports no concrete instance or test fixture modules.
A partly renamed, broken repository is not a delivered stage.

### Stage 12 — Mathematical navigation and public explanation
Consumer: learners/maintainers. Dependency: Stage 11.
- [x] 12.1 Reorganize durable tests by mathematical subjects while retaining all
  33 delivered behavioral-group obligations and independent oracles. Preserve
  failure and mutation sensitivity. Keep one shared toy-category fixture;
  do not create one-case files or clone harnesses for symmetry.
- [x] 12.2 Update README owners/navigation, guide code/links and local migration
  instructions. Retain all twelve exercise solutions and general proofs with
  finite/uniform/injective qualifications; remove stale source/API references.
Exit: each capability has one code owner, discoverable tests and accurate paths;
one book exercise index, no copied manuals or old-name facades.

### Stage 13 — Integrated acceptance and topology audit
Consumer: final reviewer. Dependency: Stage 12.
- [x] 13.1 Fresh owned-scratch build/runtest, positive/expected-negative public
  consumer compilation, both documentation examples, dependency and sealing
  inspection, manifest agreement, links and actual-diff conformance.
  Record bounded evidence without copying raw logs into the active plan.
Exit: equivalent categorical results/errors, equality universes and admission;
no duplicated algorithm/type authority, cycle, cast, missing exercise,
test-fixture library dependency or stale path; local-only recoverable changes.
Preserve previous enumeration evidence where fixtures are unchanged; changing
test files/executable counts alone is not gain or loss of mathematical coverage.

### Pre-implementation audit
Self-audit found no owner/compatibility-policy blocker after the two user choices.
Namespace feasibility is verified by the bounded Stage 10 probe, not by a
product cutover or minimum-toolchain execution claim.
Every merge retains the mathematical child/invariant; each extraction removes
a concrete/general dependency or separates admission from universal construction.
No new runtime effect, resource guarantee or proof-strength claim is introduced.

Reopen only affected decisions for a qualified-module cycle, lost abstract type
identity, a supported external consumer, or a redundant facade exposed by the
actual diff. Do not rewrite algorithms to rescue a directory scheme.
Recovery uses the preserved working-tree snapshot, not broad deletion/reset.

### Completed deliveries and next handoff

[Layout evidence](evidence/layout-refactor-evidence.md) owns revision-scoped
commands, API inventory, recovery identities, bounded outcomes and limitations.
Stage 10 preserved the dirty baseline and verified qualified namespaces.
Stage 11 delivered five production groups, 16 implementations and 8 interfaces,
with 33 behavioral groups, public/type/example checks and 25 signature contracts.
The actual Dune 3.7 / OCaml 4.14 minima remain untested.

Stage 12 keeps six executables but organizes them by mathematical subjects:
foundations (5 groups), universals (8), spans/relations (7), constructions/graphs
(7), functor categories (4), indexed/free-cofree (2). One private support library
owns checks, a shared bounded FinSet fixture and the sole toy category. Independent
oracles remain local. README links code owners and suites and explains the clean
local API migration; the book guide retains all twelve proofs/qualifications.

Measured against Stage 12 entry: test source 1,868 -> 1,851 lines, test wiring
34 -> 11, reader docs 759 -> 751; production remains byte-identical (2,685 lines).
Fresh checks preserve all 33 groups/counters, both positives, ten expected type
rejections, both examples and three representative mutation sensitivities.
This is Stage 12 evidence, not completion of Stage 13's full topology acceptance.

### Stage 13 acceptance

Fresh integrated build/runtest, both public positives, ten admission/type
rejections, four extra boundary checks, both guide examples and 25 original
signature contracts passed. Dependency extraction is acyclic; generic theory
imports neither concrete instances nor test support. Local install metadata
excludes test support. All twelve exercises, scoped qualifications, native
owners, manifest floors, links and accepted input hashes were inspected.

No acceptance blocker or production/test/doc edit was needed. All four layout
stages are complete; this is local acceptance, not formal proof, minimum-version
or cross-platform validation, installation, publication or a commit.
Whole-refactor production counts: .ml 2,163 -> 2,154; .mli 419 -> 531. Explicit
sealing declarations explain the interface increase; total source LOC did not
fall. Stage 12's 40-line test/wiring and 8-line reader-doc reductions remain.

Retain recovery/evidence bundles while work remains uncommitted. Any future
restore or cleanup must account for newer changes; never reset to HEAD.
