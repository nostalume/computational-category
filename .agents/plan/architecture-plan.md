# Architecture Plan: Book-aligned definition-to-code program

Canonical, tracked handoff for E:/Proj/course/computational-category.
Earlier Chapter 6/7 sections record completed or bounded deliveries; Stage 20 is
the current active planning scope. The completed layout section below is historical. [Historical delivery evidence](evidence/pre-layout-audit.md)
retains the previous Chapter 2-5 work and its scoped proof/exercise qualifications;
it is not a second active plan. Do not untrack this file or change ignore policy.

## Chapter 6 — active handoff, 2026-10-10

### Authority, baseline and intended consequence
User authorizes continuing locally while push is blocked and explicitly approves
one coherent local API migration to checked general functor object maps.
External complexity reduction means fewer independent concepts, representations,
translations and public obligations, not a LOC limit. Retain justified admission
boundaries and mathematical coverage; no code golf or count-driven deletion.

Baseline commit: 25d4c5c1e295b819ae4fb03e27666627d3d82e3f; working tree clean
at inspection. Normal non-forced push outside the sandbox also failed to reach
GitHub:443; remote publication remains unverified. Do not diagnose sandboxing
from connectivity failure or change host network settings. No automatic commit,
push retry, dependency installation, release or new independent agent is included
in the Chapter 6 stages. Existing minimum-toolchain/platform limitations remain.

Authoritative material: supplied H:/Storage/LibDb/Math/Computational Category
Theory.pdf, SHA256 17f3ba03c0a496a0da3cb8fc8845c349d6d05ff342eeb7d40341e1238d3f94c8.
Chapter 6 is printed pp.127-154, PDF pages 140-167 (one-based), with exercises
1-16 distributed through the chapter; 13-16 are starred investigations. Native
text was inspected using pypdf 6.10.0; rendered pages 133,145,151,154 checked
ambiguous graph convention, termination, pushout and extension diagrams.
No whole-book extraction or formula-transcription fidelity claim is made.

### Evaluation and settled constraints
Observed: general Foundations.Functor has checked arrow maps but total object
maps. Universal choices in Limits.Free/Cofree, coequalizers, pullbacks and
finite functor builders return result. A conversion that merely unwraps these
would disguise legitimate construction failure as an exception.
Settled: migrate f_omap to result in its existing owner and all current callers.
Composition short-circuits at the first error and preserves the exact error;
callback exceptions propagate. Successful pure maps return Ok. Keep one general
functor representation, the same category dictionaries and wrapper/package.
The abstract finite-domain functor/natural values retain their distinct frozen
admission responsibility; they are not replacement general functor models.

Existing reusable owners: Foundations.Category/Functor; Universal.Diagrams,
Limits and Preservation; Constructions.Comma/Elementary/Spans; finite set,
finite graph and term instances. Generic theory must not import Instances.
Candidate adjunction owner is Universal.Adjunction: universal arrows, unit/
counit conversion, transpose/untranspose, duality and composition are one
semantic capability, not per-exercise files. General natural-transformation
capabilities belong with general functors; finite equality/admission stays in
Functor_category. Stage 15 must settle their concrete contract before coding.
Algebra structure and commuting homomorphisms merit Constructions.Algebras;
iteration/free-algebra generation must depend on those owners and supplied
universal/isomorphism capabilities, not on a duplicate colimit algorithm.
Exact private representation stays open until its owning stage's audit.

Rejected alternatives: a parallel checked-functor hierarchy increases caller
choices and adapters; exception unwrapping hides failure; a global Chapter6
module or one file per exercise hides mathematical ownership. No compatibility
facades without a discovered supported external consumer.

Preserve next-after-previous composition, custom extensional equality, distinct
FinSet universes, abstract admitted records, frozen finite maps and checked
endpoints/equations. General laws remain supplied premises, not established by
record construction or arbitrary finite samples.

Source-sensitive distinctions:
- The book's D(S)=(S,S,id,id) has exactly one loop per vertex. Name that
  convention explicitly, not the usual edge-empty discrete multigraph.
- Components are a source/target coequalizer; reuse the existing quotient.
- Path accumulation preserves distinct edge sequences. Endpoint reachability
  is a separate quotient/result, not the same free path algebra.
- Finite cyclic graphs can have infinitely many paths. Eventual initial
  iterates and eventually invertible chain arrows are different hypotheses.
  No finite-prefix stabilization or fuel exhaustion certifies an omega-colimit.
- Theorem 5 needs countable coproduct preservation; the executable finite
  reduction uses eventual initial iterates. Theorems 6/7 need omega-colimits
  and preservation (and Theorem 7 finite colimits). Never assert those
  capabilities for arbitrary FinSet, or copy a general complexity bound to
  witness-preserving path enumeration.
- Exercise 16 needs explicit colimit presentations, universal seed objects,
  coherent arrow action and terminating decomposition; extend canonically up
  to isomorphism, not unproved literal equality of chosen representations.

### Stage 14 — Checked functor foundation and source contract
Consumer: current library callers and subsequent adjunction constructions.
- [x] 14.1 Inspect the chapter/exercise scope and current owner flow; settle
  the user-owned compatibility and complexity choices recorded above.
- [x] 14.2 Migrate the sole general f_omap and all repository callers; preserve
  successful results and existing admission, errors, laws and abstract types.
  Add focused object-failure/exception/short-circuit regressions at composition,
  diagram/cone/cocone mapping, comma and indexed boundaries. Update current
  reader documentation for the changed public contract, not future capability.
Exit: normal-profile build/runtest, public positive and intended-negative
fixtures, existing examples and failure-sensitive checks pass. No new functor
facade, unwrap or dependency cycle. Revert only this scoped diff to baseline
if the changed result contract is invalidated; never reset unrelated work.

### Stage 15 — Adjunctions and universal examples
Dependency: Stage 14. Consumer: learners and generic universal callers.
- [x] 15.1 Settle/audit the general natural-transformation and adjunction
  capability contracts, including checked object choice, unit/counit endpoints,
  transpose inverses, triangle/naturality premises and dual/composite direction.
  Implement the smallest coherent core without infinite extensional equality.
- [x] 15.2 Connect existing comma and fixed-shape free/cofree universals;
  implement components and floor/ceiling examples with explicit number-domain
  restrictions (do not claim IEEE floats represent all reals).
  Derive/code exercises 1-6: comma isomorphism, floor/ceiling, colimit-to-cocone
  adjunction, slice postcomposition/pullback and carrier/product adjunction.
  Construct left-adjoint colimit preservation; obtain the right-adjoint limit
  case by duality through Preservation, not another universal algorithm.
Exit: round trips, triangles, naturality and unique factors checked on bounded
independent examples, plus wrong endpoints/bases and propagated failures;
proofs explicitly state general premises separately from executable domains.

### Stage 15 contract settlement — delivered locally
User's latest agreement authorizes Stage 15, not the later starred research.
Core orientation is F:B->A left, G:A->B right. Transpose takes b->G(a)
to F(b)->a; untranspose reverses it. Stable lawful dictionaries, functors,
universal uniqueness and naturality are premises. Checked observations verify
unit/factor/component endpoints, factor triangles and selected naturality and
adjunction triangles; no constructor or finite test proves all those laws.

Select one abstract Universal.Adjunction capability with universal-choice and
unit/counit constructors. Unit/counit form translates to the same factorization
mechanism; no parallel adjunction model or infinite function equality. General
natural capabilities stay in Foundations.Functor with component and square
checks, distinct from frozen finite-domain admission. Error identity and supplier
exceptions propagate; builders never unwrap result into a supposedly total map.

Topology settlement: Adjunction depends only on Foundations. Preservation owns
adjoint-derived (co)continuity and depends on Adjunction, Diagrams and Limits.
Limits.Free/Cofree owns its adapters; Comma owns the projection-preserving
comma isomorphism; Elementary owns slice postcomposition/pullback and carrier/
product adjunctions. Keeping comma/preservation operations in the core would
create a reciprocal import (Comma already uses Preservation); reject that option.
No new adapter files or per-exercise namespaces. Components/one-loop-per-vertex
functor stay in Finite_graphs.Make(F), reusing its existing coequalizer instance.

Floor/ceiling executable examples use a finite, exact half-integer chain with
integer endpoints in tests and the learner guide; the proof is about all real
numbers. No production numeric package, floating-point real-category claim,
unbounded integer arithmetic, or new dependency is needed. Selected small finite
hom-set enumerations, a non-thin FinSet factorization, graph components, independent
mediator oracles and failure injection will falsify the actual operations.
A partial guide may be delivered now with explicit pending exercises 7-16;
Stage 18 closes the complete guide rather than duplicating it.

### Stage 16 — Algebras and terminating constructions
Dependency: Stage 15. Consumer: reusable algebra/graph constructions.
- [x] 16.1 Settle/audit admitted F-algebras, homomorphisms and inherited finite
  limits (exercise 12); provide the forgetful capability using existing maps.
- [x] 16.2 Derive Theorems 5-7 and implement their declared terminating cases,
  covering exercises 7-9, using one isomorphism/iteration responsibility with
  explicit work bounds and no false success at exhaustion. A bound limits
  owned iteration, not arbitrary user callback time or total memory.
  Distinguish convergence witnesses from finite-prefix observations; caller
  eventual-tail premises must be explicit. Build fixed-node path accumulation
  through existing pullbacks/coproducts, with path witnesses, an acyclic case,
  a cyclic refusal/incomplete case and independent path enumeration.
Exit: units/folds and homomorphism uniqueness in admitted finite cases,
empty/initial cases, orientation, false stabilization and exhaustion checked;
infinite theorem proofs never masquerade as arbitrary finite implementations.

### Stage 16 contract settlement — delivered locally
Latest user proceeds with Stage 16. Constructions.Algebras owns abstract admitted
algebras/homomorphisms, their forgetful functor and inherited limits, plus a Free
child for terminating constructions. No per-theorem module or second universal
algorithm. An algebra has structure F(a)->a; a homomorphism h satisfies
h structure=structure' F(h). Coherent endofunctor/category laws remain premises.
Inherited limits use the underlying limit's universal property to construct the
structure, then re-admit the legs/mediators; F need not preserve limits.

Executable scope is finite termination, not countable completeness of FinSet.
Theorem 5 uses eventual initial iterates and checked finite-coproduct preservation;
Theorems 6/7 use an invertible chain arrow whose future invertibility follows from
functoriality (and pushouts in 7). Generic terminating-chain suppliers must promise
an invertible tail; a finite observation alone cannot establish it. Recognition
returns a checked inverse or non-isomorphism, never cardinality-only equality.
Owned iteration takes an explicit nonnegative work bound, and exhaustion is an
explicit error, not success. This does not bound arbitrary callbacks or memory.

The free-choice result reuses Adjunction.universal_arrow over the admitted algebra
category; its unit is the generator map and its factor is a checked homomorphism.
Graph paths remain fixed-node graphs with witness-bearing pullback composition,
not endpoint relation images. The book's polynomial complexity sentence is not
transferred to path-witness enumeration. Proofs and pending subquestions remain
visible in the single Chapter 6 guide. F-algebra finite limits (exercise 12) are
delivered with the terminating constructions. Category owns iso_cat and checks both
inverse equations. Limits.Chain owns bounded terminating-chain presentations;
Preservation.by_comparison owns recomputation/comparison, not a second colimit
algorithm. Fixed-node paths stay in Finite_graphs.Make(F).Fixed using Spans and
existing pullbacks. Iteration_limit bound distinguishes exhaustion from semantic
success. No compatibility facade or per-exercise namespace was introduced.

### Stage 17 — Remaining exercise scope and constructions
Dependencies: Stage 15 for 10-11; Stage 16 for algebra/iteration consequences.
Consumer: complete Chapter 6 exercise index, not a new application framework.
- [x] 17.1 Derive/code conjugate natural pairs and composed adjunctions
  (10-11), using the core representation and correct opposite variance.
- [ ] 17.2 Adjudicate the exact models for starred exercises 13-16 before
  implementation: automaton/behaviour morphisms and minimality; induced monads
  and selected tree operations; r.e. sets versus decidable membership/function
  equality and fair stream enumeration; coherent colimit-based extension and
  endpoint reachability versus path witnesses in the Warshall comparison.
  Read the referenced literature where needed. Produce a proof/construction,
  explicit counterexample or scoped executable result for each subquestion;
  report open obligations. No starred exercise is silently omitted, replaced
  by a nearby algorithm, or declared solved from an unspecified category.
Exit: each exercise has source locator, assumptions, supported disposition,
code/test link where applicable and honest remaining boundary. Stage 17.2 is
bounded research, not ready production work until those model decisions close.

### Stage 18 — Reader guide and integrated acceptance
Dependency: Stages 14-17. Consumer: learner/reviewer of Chapter 6 coverage.
- [x] 18.1 Maintain one docs/chapter6.md exercise/proof guide, README navigation
  and subject-owned tests; do not clone fixtures or export test support. Fresh
  build/tests, public/type consumers, complete guide examples and actual diff/
  dependency/abstract-type audit after the final edit. Account for all 16
  exercises and subquestions, with any research limits/open obligations visible.
Exit: reported evidence supports the actual scoped outcome; no formal-proof,
countable-completeness, general convergence or cost claim from bounded tests.
No stage-count or LOC metric substitutes for that acceptance.

### Stage 18 receipt — completed locally
The Chapter 6 guide and README now describe exercises 1–12, link the implemented
10–11 capabilities, and state the bounded research boundaries for 13–16. A fresh
normal-profile build/runtest passed all 43 behavioral groups; public consumers
passed 2 positives, rejected 14 negative fixtures, and ran 3 complete examples.
`git diff --check` is clean apart from expected line-ending warnings, and the
dependency audit keeps the adjunction owner on Foundations only.

### Plan audit and first ready task
Source/model coverage and current paths were rechecked against the clean baseline.
Stages 14–16 and 17.1 are delivered; 17.2 is the next bounded contract-settlement task. Later
model-sensitive tasks have their own settlement gates and are not implicitly
production-ready. A failed capability, new supported external consumer, or
contrary mathematical example reopens only the affected decision. Historical
layout evidence keeps its original revision/byte-hash scope; the Chapter 6 API
migration will invalidate old signature contracts rather than rewrite history.

### Stage 17.1 receipt — completed locally
`Universal.Adjunction` now owns `compose`, `mate_left`, `mate_right` and
`check_conjugate`; no parallel functor or adjunction representation was added.
The focused adjunction executable exercises both conjugate directions and the
composite unit/counit, reporting 506 hom round trips and 11 selected exhaustive
mediators. The integrated suite remains 43 behavioral groups. Public checks pass
2 positive consumers, reject 14 negative fixtures, and compile/run the three
complete guide examples. Starred exercises 13–16 have bounded dispositions in
`docs/chapter6.md` but remain research-only and are not marked solved.

### Stage 16 receipt — completed locally
Constructions.Algebras is the sole new production owner (ML/MLI): abstract admitted
algebras/homomorphisms, the forgetful functor, created finite limits (exercise 12),
and its Free child. Terminating coproduct, initial-chain/a+F, and iterated-pushout
constructions reuse existing universals and the universal-arrow result. Exercise 7
uses a bounded terminating-chain presentation with an explicit invertible-tail
premise, checked requested inverses and candidate prefix equations. Generated chains
in 8/9 propagate invertibility by functoriality/pushouts. General omega-completeness
or convergence of arbitrary FinSet is not asserted.

Fixed-node graph colimits use the edge colimit and induced incidence; path prepend
uses witness-bearing span pullback composition, not endpoint images. Independent
word-algebra folds are bijective on finite DAG fixtures with parallel edges; cycles
and insufficient bounds return Iteration_limit, not partial success. Initial/empty
cases, product creation without F preserving it, exact error identity, callback
exceptions, false inverses/tail premises and fixed-node admission are covered.
The guide derives Theorems 5–7 and exercises 7–9/12, separates terminating executable
domains from infinite hypotheses, qualifies the p.143 F'(x)=x+F(x) claim with an
explicit counterexample, and rejects transferring the p.149 polynomial bound to
path witnesses (complete DAGs have exponentially many paths).

Final normal-profile build/runtest: exit 0, eight executables / 43 groups. New algebra
suite: 2,827 law triples and 34 independently enumerated selected unique factors.
Both public positives and three complete guide examples compile/run; fourteen
intended-negative fixtures fail at their intended compiler boundaries (exit 2).
Two scratch-only mutations compile (exit 0) and are caught (exit 2): bypassed inverse
equations and swapped iterated-pushout arrows. Sources remain unchanged. Dependency
observations, generic instance-import/cast inspection, local document links and git
diff --check pass. No conformance blocker remains; independent agent review was not
authorized and no formal proof or scalability guarantee is claimed.

Final 62 product input files aggregate SHA256:
279bf71b7af6151d754aa2e5c6bf0df431edf12e98151c0aa0568b1c1e15ea3a.
Same sorted path/tab/file-SHA256/newline convention as Stage 15. Existing ignored
cache chapter6-stage3-2bfe49c5-1648-40d9-844e-856df9d11c54 retains recovery/final
ZIPs, input manifest, actual consumer/mutation scripts and logs, canonical commands
and receipt.json. Recovery input is the accepted Stage 15 product ZIP, SHA256
6679e9941a1a2a823150ecb7c7bb62eb4c7cd0a8b19d468942154e14ad5febde.
Changes remain uncommitted on the original baseline. No push retry, installation,
release or host configuration change occurred. Minimum versions/other platforms
and remote publication remain unverified. Exercises 10–11 and 13–16 are pending.

### Stage 15 receipt — completed locally
One new production owner, Universal.Adjunction (ML/MLI), depends only on
Foundations. General natural capabilities, comma equivalence, fixed-shape
Free/Cofree adapters, initial/slice adjunctions and graph components remain with
their existing mathematical owners. Components reuse the existing coequalizer;
adjoint preservation and its dual reuse Diagrams/Limits without a new algorithm,
relay file, numeric dependency, category error variant or manifest migration.
The partial docs/chapter6.md proves/programs exercises 1–6 and explicitly leaves
7–16 pending. Floor/ceiling executables use exact finite half-integer chains;
general laws and universal uniqueness remain supplied premises.

Fresh normal-profile build/runtest: exit 0, seven executables / 39 groups, including
470 hom round trips and 11 independently enumerated selected mediators. Nonidentity
comma arrows, non-thin unit/counit, duality, components, noninjective slice fibers,
wrong endpoints/bases, errors, short-circuiting and supplier exceptions are checked.
Two wrapped public positives and all three complete guide examples compile/run;
twelve intended-negative fixtures fail with compiler exit 2, including raw
adjunction records. A scratch-only omitted-unit mutation compiles (exit 0) and
fails the intended transpose/untranspose assertion (exit 2); repository inputs
are unchanged. Dependency observations, source cast/instance-import inspection,
local document targets and git diff --check pass. No conformance blocker remains.

Scope: uncommitted changes on 25d4c5c1e295b819ae4fb03e27666627d3d82e3f, including
Stage 14. Final 57 product input files aggregate SHA256 (sorted path, tab, file
SHA256, newline): ca63929094bff5b989fec9fb9922fc1942f154342b2d1ea1d2491da597fcab91.
Existing ignored cache chapter6-stage2-b9ed6401-543d-44c0-b961-dd3159dafc0b retains
the entry/final source ZIPs, manifest, actual consumer/mutation command sources,
canonical commands, outputs and receipt.json. Entry ZIP hash is
4484f5a1b469703212d4ad11dd248dd2338566f16c516c17fece2e47031b2ceb.
No commit, push retry, installation or release occurred; remote publication and
minimum-toolchain/other-platform behavior remain unverified.

### Stage 14 receipt — completed locally
General f_omap now returns result and every current repository caller has been
migrated. Eight existing production files changed; no new production module,
functor representation, compatibility facade, category error variant, dependency
or manifest floor was added. Finite-domain admitted types and universal algorithms
remain unchanged. Successful mathematical outputs/counters are preserved.

Fresh normal-profile build/runtest used OCaml 5.2.1 / Dune 3.24.2 in owned temporary
scope outside the sandbox; all six executables / 33 behavioral groups passed.
Focused failures cover composition, duality, diagram/cone/cocone object/apex maps,
comma construction, indexed arrows/transposition and inherited (co)limits.
Error identity, downstream non-execution and callback exception propagation are
checked. A scratch-only error-masking mutation compiled and failed the intended
regression (exit 2, composed object error unchanged); repository source was untouched.
Both wrapped public positives compile/link/run; eleven negatives fail at their
intended boundaries, including the retired total object callback. README and
Chapter 5 complete examples produced witnesses=4/image pairs=3 and graph
product=4 nodes/2 edges. Current local document destinations, sole functor owner,
generic dependency boundaries and git diff --check passed.

Final 52 product input files (source/tests/docs/manifests, excluding compiled
artifacts) aggregate SHA256:
40711375b9dc8c6ef06f040d982f81eb7ed675466a29c03080ac655cb1831a48.
This binds this receipt, not the historical layout hash/signature checks.
Minima, other platforms, scalability and formal proofs remain unverified.
Chapter 6 adjunction/exercise code is not yet delivered. This stage is uncommitted;
previous commit 25d4c5c remains local with its push blocked by GitHub connectivity.
Owned inspection/build/mutation/consumer scratch is disposable and removed after
acceptance; no historical recovery bundle or user file is removed.

## Completed mathematical-layout refactor — historical, 2026-10-10


### Authority and status
Requested consequence: repair the mathematical module layout, in four stages.
The user's latest agreement authorizes Stage 13 integrated acceptance.
The then-reported LOC preference motivated justified consolidation, not lost
coverage. The active Chapter 6 section above records its clarified meaning.
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
### Stage 19 — Chapter 7: cartesian closed categories and toposes
Source: supplied `Computational Category Theory.pdf`, printed pp.155–172,
PDF pages 168–185. The chapter introduces exponentials, subobject classifiers,
power objects and internal logic, then asks for quantifiers, slice toposes,
functor toposes and the finite-graph topos.

The existing repository has finite products, pullbacks, finite (co)limits,
comma/slice categories, finite functor categories and graphs, but no exponential
or subobject-classifier owner. Keep those concepts together in one universal
topos capability; do not add a per-exercise module or silently treat arbitrary
finite categories as toposes.

- [x] 19.1 Add the smallest checked exponential/cartesian-closed and topos
  records, with finite-set exponentials, subobject classification, power-object
  construction and internal connectives/quantifiers. Function values use a
  collision-safe library-owned encoding and remain finite-only.
- [ ] 19.2 Construct the finite slice topos over an admitted finite anchor,
  including its inherited limits/colimits, dependent exponential and
  slice-relative classifier. Check Exercise 2 on small fibers and reject maps
  with wrong bases or non-monic classifier inputs.
- [ ] 19.3 Investigate Exercises 3–4. The general sieve construction for
  `FinSet^B` needs an explicit finite source-category contract and a presheaf
  variance choice. Implement the two-object parallel-arrow graph classifier only
  if that contract can be made coherent; otherwise retain a source-backed
  bounded disposition rather than claim a general functor topos.
- [x] 19.4 Add `docs/chapter7.md`, README navigation, focused tests and public
  type-contract examples. Evidence must distinguish finite enumerations from
  topos laws supplied as premises; no Set-sized, infinite, or arbitrary
  functor-category completeness claim is allowed.

Exit: Chapter 7 definitions and exercise status are documented; implemented
finite capabilities have endpoint, pullback, exponential, classifier and logic
checks; unresolved sieve/variance or infinite-model obligations remain visible.

### Stage 19.1/19.4 receipt — completed locally
`Universal.Closed` and `Universal.Topos` own the new capabilities. The concrete
finite-set instance enumerates tagged function graphs, evaluation/currying,
two-valued classification, power objects, connectives and quantifiers. The
focused suite has three groups; Exercises 2–4 are documented as bounded model
decisions rather than silently implemented. Chapter 7 navigation and guide are
present. Fresh integrated verification passes 46 behavioral groups and the new
public finite-set consumer; Exercises 2–4 remain the next model decisions.

### Stage 20 — first-principles definition-to-code reduction (new active plan)

Source: the supplied *Computational Category Theory* PDF and the repository's
revision-scoped contracts. The user requests a book-aligned reduction rather
than a list of independent optimization ideas: every mathematical definition
must reduce to inspectable pseudocode, then to a named implementation owner,
documentation section and verification evidence. This stage is planning only;
it authorizes neither source edits nor exercise implementation.

#### 20.1 Governing method and invariants

Use one definition ledger entry per mathematical concept or exercise:

```text
ID -> definition -> premises -> data -> operations -> equations/uniqueness
   -> failure/bound -> pseudocode -> code owner -> documentation anchor
   -> positive/law/negative evidence -> scope qualification
```

The following distinctions are mandatory:

- book theorem/premise versus executable finite witness;
- extensional mathematical equality versus presentation/representative equality;
- admitted input versus computation on an admitted value;
- construction failure versus callback exception;
- universal existence/uniqueness premise versus a finite test that only falsifies
  a bad implementation;
- documentation claim versus verified code behavior.

Every chapter uses the same reduction order:

1. **Source extraction:** record page/section, symbols, variance and premises;
2. **Mathematical normal form:** state objects, arrows, equations and uniqueness;
3. **Pseudocode:** give typed data and total/partial operations with explicit
   error and termination conditions;
4. **Contract settlement:** choose the owner and preserve existing equality,
   result/error and finite-boundary policies;
5. **Parallel delivery:** documentation and code/refactor lanes proceed from the
   same settled ledger entry;
6. **Reconciliation:** compare pseudocode, public signatures, examples, tests and
   reader prose; unresolved differences reopen only the affected entry.

Documentation and code are therefore parallel *after* the mathematical contract
is settled, not competing sources of meaning.

#### 20.2 Canonical pseudocode kernels

These kernels are the reduction targets; exact OCaml representation remains open
until the owning chapter audit.

**Category**

```text
category = (Obj, Arr, source, target, identity, compose, equal_obj, equal_arr)
admit_arrow(f, a, b): require source(f)=a and target(f)=b
compose(g, f): require target(f)=source(g); return g after f or typed failure
```

**Functor**

```text
map_object(a): result ObjB
map_arrow(f): result ArrB
check_arrow(f): endpoints(map_arrow(f)) = map_object(endpoints(f))
check_composition(g,f): map(g∘f) = map(g)∘map(f)
```

**Finite carrier and total function**

```text
admit_set(values): deduplicate using the supplied extensional equality
admit_function(A, callback, B): evaluate callback once per admitted a∈A;
  reject any image outside B; retain one image for every a
apply(f,a): require a∈source(f); return the retained image
compose(g,f): require matching middle carriers; evaluate pointwise
```

**Universal construction**

```text
construct(diagram): return (candidate, structure_maps, mediator)
mediate(candidate, other): require same base and equations; return unique map
check_universal(candidate): check structure equations and mediator equations
```

**Adjunction**

```text
transpose(h : b -> G(a)): F(b) -> a
untranspose(k : F(b) -> a): b -> G(a)
check_triangles(): both triangle composites equal identities
```

**Cartesian closed/topos structure**

```text
exponential(a,b): (b^a, eval, curry)
classifier(m): characteristic arrow, with monicity an admitted premise
power(a): (P(a), membership)
```

Each pseudocode kernel must state the mathematical law it is reducing; a helper
that merely makes a current implementation shorter is not a ledger entry.

#### 20.3 Chapter/part delivery matrix

| Part/chapter | Mathematical reduction | Code/refactor lane | Documentation lane | Evidence gate |
|---|---|---|---|---|
| Ch. 2 foundations | recursive data, finite values/sets, equality and total maps | `Exercises.Basic`, `Instances.Finite_sets`, `Instances.Terms`; isolate admission from computation | foundations guide: definitions, equality law, finite envelope | constructor laws, extensional equality, negative admissions |
| Ch. 3 categories/functors | category laws, functor laws, naturality, diagram maps | `Foundations.Category`, `Foundations.Functor`, `Universal.Diagrams`; preserve checked `result` flow | category/functor guide with equations and callback-failure policy | identities, associativity, naturality, propagated errors |
| Ch. 4 finite universals/relations | products, coproducts, (co)equalizers, relations and universal mediators | `Universal.Limits`, `Instances.Finite_set_universals`, `Instances.Finite_relations`, `Constructions.Spans`; keep chosen witnesses explicit | universal-construction guide with mediator derivations | universal equations and selected exhaustive uniqueness |
| Ch. 5 constructions | comma objects, slices/coslices, products, twisted arrows, functor categories, graphs | `Constructions.Comma`, `Elementary`, `Functor_category`, `Indexed`, `Instances.Finite_graphs` | existing `docs/chapter5.md` becomes ledger-backed; general premises separated from finite adapters | square/triangle equations, duality, pointwise laws, graph incidence |
| Ch. 6 adjunctions/algebras | unit/counit, transpose, preservation, initial/free constructions and termination premises | `Universal.Adjunction`, `Universal.Preservation`, `Constructions.Algebras`; no second universal algorithm | existing `docs/chapter6.md` gains per-definition pseudocode blocks | round trips, triangles, naturality, bounded termination/error evidence |
| Ch. 7 exponentials/toposes | evaluation/currying, classifier, power object and internal logic; slice/sieve variance gates | `Universal.Closed`, `Universal.Topos`, `Instances.Finite_set_topos`; isolate function encoding and capability ownership | existing `docs/chapter7.md` gains definition-to-API ledger and explicit unresolved exercises | finite exponential equations, classifier/logic checks, no arbitrary topos claim |
| Chs. 8–10 | **source-extraction gate first**; do not invent chapter subjects or owners | no production refactor until definitions, premises and workload are extracted from the PDF | create one guide per chapter only after ledger settlement | source pages, pseudocode, scope decision, then implementation evidence |

The Chapter 8–10 row is deliberate: the repository currently excludes those
chapters, so their mathematical subjects are an unresolved source fact rather
than permission to infer modules from names or conventional category-theory
architectures.

#### 20.4 Parallel sequence within each chapter

After 20.1–20.3 settle a chapter ledger entry, run these synchronized lanes:

**Math/pseudocode lane**

- transcribe the definition and premises;
- reduce it to the smallest pseudocode kernel;
- list equations, uniqueness obligations, failure and termination bounds;
- identify the falsifier for every claimed law.

**Code/refactor lane**

- assign one existing or newly justified owner;
- preserve abstract types and error semantics;
- refactor only the representation required by the kernel;
- add positive, law, negative and exception-boundary tests;
- record complexity only for a named finite workload.

**Documentation lane**

- mirror the same ledger ID and pseudocode;
- explain the general theorem separately from the executable restriction;
- provide one complete consumer example;
- state chosen representatives, bounds and unresolved premises.

**Reconciliation gate**

- every public operation appears in pseudocode and prose;
- every pseudocode precondition has an admission check or an explicit caller
  premise;
- every documented equation has executable evidence or is labelled a theorem
  premise;
- no code owner is duplicated across chapters;
- no optimization changes extensional equality without a renewed contract.

#### 20.5 Representation decisions carried forward

The current list-backed FinSet remains the reference presentation. An internal
indexed arrow table is a **candidate**, not a settled replacement: supplied atom
equality has no hash/order contract, so arbitrary-value lookup cannot be promised
constant time without changing the public premise. Any optimization must first
separate source-position iteration from arbitrary-value lookup.

Likewise, tagged function graphs in Chapter 7 remain an admitted finite encoding
until a ledger entry settles an opaque finite-function owner. Capability fields in
`Universal.Topos` remain a coherence decision; a constructor or derived-owner
policy must be selected before Chapters 8–10 add dependent capabilities.

#### 20.6 Acceptance, unknowns and first executable task

Stage 20 is complete only when Chapters 2–7 each have an audited ledger, matching
pseudocode, documentation anchors, owner assignments and evidence references;
Chapters 8–10 have source-extraction entries; and no general theorem is presented
as a finite test result. This does not claim a formal proof or minimum-toolchain
portability.

Material unknowns are the exact Chapter 8–10 subjects, future workload size, and
whether any external consumer requires compatibility beyond the current local API.
Those unknowns block only the affected chapter/refactor, not the completed ledger
for Chapters 2–7.

#### Stage 20.1 receipt — ledger created

The first executable planning task is complete in
`E:/Proj/course/computational-category/.agents/plan/definition-ledger.md`.
It records Chapter 2–7 definitions, premises, pseudocode reductions, unique
owners, documentation anchors, evidence gates and unresolved Chapter 7
contracts. No production source or reader documentation was changed. The next
task is ledger reconciliation against the current public signatures and tests;
only after that review may a code/documentation pair be selected for refactoring.

#### Stage 20.2 receipt — signature/test reconciliation

The ledger was reconciled against all current `.mli` files, inferred public
modules under `src/dune`, and the existing foundation, universal, span/relation,
construction, indexed, adjunction, algebra and topos test executables. The
results are recorded in the ledger's reconciliation section. No owner/signature
mismatch or mathematical blocker was found. Four warnings remain explicit:
Chapters 2–4 lack a dedicated reader guide; several foundations/construction
owners expose inferred rather than explicit interfaces; generic universal records
do not prove uniqueness; and Chapter 7 monicity/universal laws remain premises.

No code refactor is selected yet. The next candidate is a documentation-only
Chapter 2–4 guide, after which a source change may be paired with a completed
ledger/documentation/evidence entry.

#### Stage 20.3 receipt — Chapter 2–4 documentation

Created `E:/Proj/course/computational-category/docs/chapter2-4.md` and linked it
from `README.md`. The guide mirrors the reconciled ledger: finite foundations,
checked categories/functors, labelled diagrams, primitive and generic finite
universals, spans and relations, with pseudocode, current owners, examples,
evidence links and explicit finite/premise boundaries. This delivery changed
documentation only; no source API or implementation was refactored.

### Stage 21 — synchronized target-API refactor (new active direction)

The user has clarified that the current-API guide is only a baseline: the target
is a math-first, more efficient and ergonomic package, and the old API must not
be preserved through compatibility facades or surrounding adapters. This is a
clean local migration. Documentation, source, examples and tests must move as
one chapter delivery; a documentation-only chapter is no longer considered a
complete delivery.

#### 21.1 Contract and scope

- The book's definitions and equations remain authoritative for semantics.
- Existing equality, result/error, admission and finite-boundary decisions remain
  invariants unless a ledger entry explicitly replaces one.
- Public names, module paths and representations may change when the new shape
  removes a documented mismatch or duplicated owner.
- No relay compatibility layer, deprecated alias, or parallel validator is to be
  retained merely to avoid updating local callers.
- Refactor only the named chapter owners and their direct tests/examples; do not
  perform unrelated cleanup or a speculative Chapters 8–10 redesign.

#### 21.2 Synchronized chapter sequence

For each chapter, the dependency order is:

1. settle the target mathematical/API contract in the definition ledger;
2. refactor the owning source modules and signatures;
3. migrate direct callers, tests and examples in the same change;
4. rewrite the chapter guide against the new API and pseudocode;
5. run the chapter evidence gate plus the integrated suite;
6. retire the old API paths rather than documenting them as supported.

The first target batch is Chapters 2–4, because they establish the data and
category contracts consumed by Chapters 5–7. The current
`docs/chapter2-4.md` therefore becomes a provisional baseline and must be
rewritten after the target API lands; it is not the final reader contract.

#### 21.3 Target decisions to settle before source edits

- **Finite objects/arrows:** expose math-facing object/morphism operations and
  retain immutable snapshots; separate arbitrary-value lookup from indexed
  iteration so efficiency claims are honest under custom equality.
- **Category/functor boundary:** one checked category/functor vocabulary, with
  result-returning partial operations and no duplicate general/finite façade.
- **Universals:** one chosen-witness vocabulary for structural maps and
  mediators; uniqueness remains a supplied law and a finite evidence check.
- **Documentation contract:** every public operation shown in pseudocode and in
  one runnable consumer example; finite observations and theorem premises remain
  visibly distinct.

The exact names and private representation remain candidate decisions until the
Chapter 2–4 contract review closes them. The implementation handoff must include
the old-to-new caller migration map and an explicit retirement list.

#### 21.3a Initial target selection for Chapters 2–4

The first comparison selects a clean local migration rather than a compatibility
overlay:

| Option | Consequence | Decision |
|---|---|---|
| Preserve current FinSet names and add faster internals | Lowest caller churn, but leaves `set`/`arrow`/`apply` vocabulary and duplicated presentation/computation concepts in place | Reject for the stated ergonomics goal |
| Add a second math-facing façade over the current API | Duplicates ownership and leaves two public vocabularies | Reject |
| Migrate one math-facing finite carrier/morphism vocabulary and compile admitted values for computation | Requires updating all local callers, but removes the old surface and separates extensional equality from indexed iteration | **Selected candidate** |

The selected candidate keeps the generic category dictionary where its
`source`/`target`/`ident`/`comp` vocabulary is already direct, while migrating
the concrete finite instance to a carrier/morphism vocabulary with explicit
domain/codomain evaluation. Its private admitted representation may use dense
arrays for source-position iteration; arbitrary lookup remains equality-driven
unless the atom contract is deliberately strengthened. No old FinSet aliases or
parallel façade are retained after migration.

This selection is local to the Chapters 2–4 contract. It is not permission to
redesign all future chapters before their own ledger entries are settled.

#### 21.4 Exit

Stage 21 is complete only when Chapters 2–7 have synchronized source/docs/tests,
old local API paths are retired, and the integrated evidence still covers the
mathematical ledger. A failed efficiency or ergonomics hypothesis reopens only
the affected target contract; it does not justify restoring compatibility shims.

#### Stage 22 receipt — Chapters 2–4 carrier/morphism migration

Implemented the selected first batch. `Instances.Finite_sets.S` now exposes
`carrier`/`morphism`, `carrier_of_list`, `carrier_to_list`, `mem`,
`equal_carrier`, `morphism_result`, `domain`, `codomain`, `eval`, `identity`,
and `equal_morphism`; the former concrete `set`/`arrow`/`apply` vocabulary is
retired rather than aliased. Admitted carriers and morphism tables use private
dense arrays, while equality-driven external lookup remains explicit because
the atom contract supplies no hash law.

Direct finite-set callers, signatures, tests, and type-contract fixtures were
migrated in the same batch. `docs/chapter2-4.md` and `README.md` now describe
the target API, pseudocode reduction, ownership, and finite evidence boundaries.
The migration intentionally leaves abstract category dictionaries' generic
`source`/`target`/`ident` field names unchanged; only concrete FinSet owners
were renamed.

Static retirement check: no concrete `F/I/S/Ch/Abs/E` FinSet references to the
old names remain in `src` or `tests`; remaining `A.arrow` occurrences belong to
`Constructions.Algebras`, not the finite-set owner. Using the existing
process-local Opam toolchain (OCaml 5.2.1, Dune 3.24.2), `dune build
--cache=disabled --no-config` and forced `dune runtest --cache=disabled
--no-config --force` both exited 0. The suite reported all foundation,
universal, relation, construction, indexed, adjunction, algebra, topos, and
functor-category groups passing. `git diff --check` also passes (only Git's
LF/CRLF normalization warnings remain).

The public README relation example was extracted, compiled against the rebuilt
wrapped library, and ran with `witnesses=4, image pairs=3`. The migrated positive
type-contract fixture compiled; representative retired-surface and mixed-equality
fixtures failed at their intended type boundaries (`entries` is private and
independent carriers cannot be compared).

### Stage 23 — kernel allocation and table reuse (complete)

#### 23.1 equality-only atom contract

The atom contract remains equality-only: `ATOM.equal` is stable, terminating,
and an equivalence, but no hash or ordering law is introduced. The optimization
must preserve equality-driven admission and arbitrary-value lookup. No
asymptotic constant-time lookup claim is authorized. The accepted workload
evidence is a transient OCaml 5.2.1 bytecode benchmark over carriers of 64, 256,
and 512 values, with five timed repetitions after one warmup; it distinguishes
avoidable conversion/table work from inherent equality-only scans.

#### 23.2 direct table and conversion scope

First remove avoidable array/list conversions and repeated scans without changing
the public API, equality semantics, callback count, error propagation, or
representative ordering. Composition/equality may use indexed table data only
where extensional endpoint correspondence has already been established; any
remaining equality reconciliation cost must stay explicit. Repeat the benchmark
after the final source edit, then run the complete Dune build/test gate and
mutation-sensitive API checks.

#### 23.3 First kernel slice receipt

`src/instances/finite_sets.ml` now constructs admitted carriers and morphism
tables directly in arrays, filters without a two-pass predicate, builds products
and disjoint unions without list materialization, generates splits/powersets
without repeated carrier-to-list conversion, and composes using the already
indexed first morphism table rather than re-evaluating it. Equality-only target
membership and arbitrary-value `eval` remain unchanged. No public signature or
atom contract was changed.

The same transient benchmark was run before and after the slice on OCaml 5.2.1
bytecode, five timed repetitions after warmup, with carriers of 64, 256, and 512:

```text
baseline n=512: morphism=.006505 eval_all=.005476 compose=.031036 union=.012522 map=.005920
after    n=512: morphism=.006133 eval_all=.005537 compose=.005503 union=.012076 map=.006009
```

The composition path improved by approximately 82% in this run; morphism,
union, and map remain equality-scan bound, so no unsupported asymptotic claim is
made. Fresh `dune build --cache=disabled --no-config` and forced `dune runtest
--cache=disabled --no-config --force` both exit 0, with the complete suite still
passing. Further caller-level conversion removal requires a separate iterator
API decision and is not included in this slice.

### Stage 24 — Finite-universal vocabulary migration (complete)

The concrete finite universal-construction owner now names its operations by
the mathematical construction itself: `initial`, `terminal`, `product`,
`coproduct`, `equalizer`, `coequalizer`, `coequalizer_classes`, `pushout`,
`pullback`, `limit`, and `colimit`. The former `set_*` names were removed
rather than retained as aliases. This keeps the construction vocabulary
orthogonal to the carrier representation and makes module-qualified use read
as the corresponding definition in the book.

The signature and implementation in
`src/instances/finite_set_universals.ml`, all finite graph/topos callers,
universal/construction/adjunction/indexed/algebra/topos tests, README and
Chapter 6 examples, and positive type-contract fixtures were migrated in one
local API change. The generic `Universal.Limits` vocabulary was not changed;
only the concrete finite-set owner was renamed. A repository-wide search over
`src`, `tests`, `docs`, and `README.md` reports no residual `set_*` universal
operation names.

Validation receipt: with the process-local OCaml 5.2.1 / Dune 3.24.2
toolchain, `dune build --cache=disabled --no-config` and forced
`dune runtest --cache=disabled --no-config --force` both exit 0. All existing
foundation, universal, relation, construction, indexed, adjunction, algebra,
topos, and functor-category groups pass. The equality-only contract and the
Stage 23 kernel benchmark are unchanged. Caller-level list conversion remains
deferred until an iterator API is separately specified and benchmarked.

### Stage 25 — equality-only complexity audit and safe guard (complete)

`carrier_to_list` is classified as an operational mediation, not a
mathematical constructor. It remains available at list-oriented algorithm and
test boundaries, while the mathematical definitions use carriers, membership,
and morphism evaluation directly.

The remaining asymptotic bounds were derived from the actual contract rather
than treated as accidental code shape. With only a stable terminating
equality predicate, arbitrary membership/evaluation is O(n); certifying
pairwise distinctness or extensional equality has an Ω(n²) equality-query
worst case; and deduplicating admission/union inherits that bound. Cartesian
products and powersets additionally have output-size lower bounds. A
subquadratic general solution requires a compatible hash/order law or a
different representation contract, neither of which is currently owned by
the atom interface.

The safe implementation improvement is a cardinality guard in
`src/instances/finite_sets.ml`: extensional carrier equality now rejects
different-length carriers before membership scans. This improves common
unequal-cardinality cases without changing equality, representative order,
or public types. Known-position reuse remains the preferred internal path;
transaction-local reconciliation caches and stronger hash/order contracts are
deferred until a workload benchmark justifies their added surface or contract
cost.

Validation receipt: `dune build --cache=disabled --no-config` and forced
`dune runtest --cache=disabled --no-config --force` both exit 0, with the full
foundation, universal, relation, construction, indexed, adjunction, algebra,
topos, and functor-category suites passing. `docs/chapter2-4.md` records the
complexity derivation and the operational status of `carrier_to_list`.

### Stage 26 — position-preserving universal construction (complete)

The transient OCaml 5.2.1 bytecode benchmark measured three workloads at
multiple sizes: repeated equality membership, repeated finite products, and
repeated identity coequalizers. Membership retained its expected quadratic
batch slope (`2n` arbitrary queries against an `n`-element carrier); no
equality-only index can make arbitrary queries sublinear without a hash/order
law, so no membership cache was added.

Two universal-construction paths did have avoidable position work. The finite
product projections previously constructed `n*m` values and revalidated each
projection by scanning its target carrier, giving a cubic target-membership
term. Coequalizer partitioning repeatedly evaluated two morphisms and then
rescanned the same target; quotient construction also re-deduplicated known
representatives. The finite-set owner now supplies a namespaced `Private`
position capability: indexed Cartesian products, trusted carrier subsets, and
validated morphism tables from target positions. Morphisms retain target
positions internally, and coequalizer partitioning uses them when the two
parallel morphisms share the same source/target layout, with the original
equality-driven fallback for all other layouts.

These hooks do not alter `equal`, `equal_carrier`, `eval`, endpoint checks, or
the public mathematical construction records. They consume only positions
already produced by the same admitted carrier; invalid target indices are
rejected by the validated morphism hook. The generic equality-only path
remains authoritative.

Normalized single-run timing from the same transient harness illustrates the
effect (seconds; process-local bytecode measurements, not a performance
proof):

```text
product n=64:          baseline .001734 -> position-indexed .000567 (~67% lower)
coequalizer n=256:     baseline .001267 -> position-indexed .000017 (~99% lower)
coequalizer n=512:     baseline .005420 -> position-indexed .000083 (~98% lower)
membership n=512:      baseline .001830 -> position-indexed .001949 (no meaningful change)
```

The product path now scales with its `n*m` output rather than repeated target
membership scans; coequalizer partition and quotient materialization reuse
known positions. The membership result confirms that further arbitrary lookup
improvement requires a deliberate stronger atom contract, not another list or
array conversion.

Validation receipt: `dune build --cache=disabled --no-config`, forced
`dune runtest --cache=disabled --no-config --force`, and `git diff --check`
pass. The transient benchmark files were removed after measurement.

### Stage 27 — Chapter 5 construction refactor (complete)

The next step follows the same multi-criterion refactor used for the finite
carrier and universal layers. It synchronizes one chapter's mathematical
definitions, public signatures, implementation, callers, tests, exercises,
and reader documentation in one dependency-ordered change. Renaming is one
part of the work, not the whole objective.

Chapter 5 owns comma objects/squares, finite graphs, indexed categories,
finite functor categories, and inherited universal maps. Its audit will score
each owner against five criteria:

* **Mathematical directness:** the signature and pseudocode reduce directly
  from the chapter definition, with premises and result-valued failures
  visible at the boundary;
* **Efficiency:** changed paths avoid redundant enumeration, endpoint checks,
  and position reconciliation, reusing the existing private indexed hooks
  where the representation already supplies the proof;
* **Readability:** owner-specific names distinguish graph, comma, indexed, and
  functor-category roles without obscuring generic category vocabulary;
* **Ergonomics:** callers express the construction with the fewest ambiguous
  arguments and receive the relevant typed result/error surface;
* **Maintainability:** ownership, invariants, and tests are local, with no
  compatibility aliases or parallel façade.

The implementation sequence is:

1. extend the definition ledger from `docs/chapter5.md` and the corresponding
   source signatures;
2. identify the smallest API and representation changes that improve all
   applicable criteria, including justified owner-specific renames such as
   `graph_morphism`, `fixed_morphism`, or `labelled_morphism`;
3. implement those changes together with focused efficiency reductions on the
   affected paths, not a separate benchmark campaign;
4. migrate all callers, positive/negative type contracts, tests, and
   exercises;
5. update `docs/chapter5.md`, pseudocode, the definition ledger, and the
   architecture receipt in parallel;
6. run the ordinary build/test/type-contract gate and inspect the resulting
   public surface for stale or duplicated vocabulary.

Acceptance is chapter-level improvement in mathematical directness,
efficiency, readability, ergonomics, and maintainability, with retired stale
vocabulary and synchronized documentation. Chapters 6 and 7 then follow the
same criteria for adjunction/algebra and closed/topos APIs.

#### Stage 27.1 receipt — Chapter 5 construction vocabulary

The Chapter 5 owner APIs were migrated without aliases. `Finite_graphs.Make(F)`
now exposes `graph_morphism`; its fixed-node and labelled owners expose
`Fixed.fixed_morphism`, `Labelled.labelled_morphism`, and
`Labelled.underlying_morphism`. `Constructions.Indexed.Make(I)` now exposes
`indexed_morphism`. `Constructions.Functor_category` now exposes
`finite_functor`, `natural_transformation`,
`equal_natural_transformation`, and `dual_natural_transformation`.

Generic `Constructions.Comma.arrow` and algebra `arrow` remain unchanged
because they name their own abstract constructions. All affected callers,
tests, and the Chapter 5 positive type contract were migrated. The guide and
definition ledger now state the incidence-square, indexed transport, and
naturality boundaries using the owner-specific names. No representation or
equality law changed; existing finite-set position-aware paths remain the
efficiency mechanism. Build and the forced full test suite both pass.

### Stage 28 — Chapter 6 adjunction-and-algebra refactor (complete)

Apply the same five-criterion contract to adjunctions, preservation
capabilities, algebra objects/morphisms, terminating chains, and free/cofree
builders. The likely owner-specific vocabulary candidate is
`algebra_morphism` for `Constructions.Algebras.arrow`; generic
`Universal.Adjunction.universal_arrow`, `unit_arrow`, and `factor` remain when
they are the direct universal-construction terms. The stage will reconcile
the pseudocode in `docs/chapter6.md` with `src/universal/adjunction.ml`,
`src/universal/preservation.ml`, and `src/constructions/algebras.ml`, then
migrate callers, exercises, type contracts, and documentation together.

Efficiency work is limited to changed algebra/adjunction paths and preserves
the existing finite-set position contract. Acceptance requires the full
mathematical-directness, efficiency, readability, ergonomics, and
maintainability review, followed by the ordinary build/test/type-contract
gate.

#### Stage 28.1 receipt — adjunction and algebra vocabulary

`Universal.Adjunction.t` is now the named `adjunction` capability, and
`Constructions.Algebras.arrow` is now `algebra_morphism`. All corresponding
projections, category records, free/cofree signatures, graph-algebra callers,
tests, and type-contract fixtures were migrated without aliases. The Chapter
6 guide states the algebra square and adjunction capability boundaries using
the new names. Generic `universal_arrow`, `unit_arrow`, and `factor` remain
because they are direct terms of the universal construction.

The implementation preserves endpoint/square validation, selected triangle
checks, result-valued errors, and the existing finite-set position-aware
efficiency path. `dune build --cache=disabled --no-config`, forced
`dune runtest --cache=disabled --no-config --force`, and the Chapter 6
positive/negative type-contract boundary checks pass.

### Stage 29 — Chapter 7 closed-and-topos refactor (complete)

Apply the same functional criteria to `Universal.Closed`, `Universal.Topos`,
and `Finite_set_topos.Make(F)`: direct names for exponentials, evaluation,
currying, classifiers, power objects, and quantifiers; explicit finite-domain
premises; targeted representation improvements only where the refactor makes
them local; synchronized guide, exercises, tests, and type contracts.

#### Stage 29.1 receipt — closed and topos vocabulary

`Universal.Topos.t` is now `Universal.Topos.topos`, and
`Universal.Closed.exp_obj` is now `exponential_object`. The finite-set topos
owner now exposes `evaluation_morphism`, `currying_morphism`, `power_object`,
and `exists`. Existing classifier, truth-value, connective, and quantifier
names remain direct mathematical terms.

The Chapter 7 guide and README now state these boundaries, including the
finite tagged-graph representation, monicity premise, and explicit rejection
of unsupported slice/presheaf/graph-topos generality. Tests and top-level
signatures were migrated without aliases. No equality, representation-law,
or finite-enumeration contract changed. Build and the forced full test suite
pass; Chapter 7 public and private type boundaries remain enforced.

### Stage 30 — integrated chapter contract review (complete)

Review Chapters 2–7 as one public surface: stale vocabulary, cross-chapter
ownership, pseudocode-to-signature alignment, README navigation, type
contracts, and complete build/test evidence. This is an integration review,
not a new broad performance campaign.

#### Stage 30.1 receipt — integrated contract review

**Vocabulary.** The retired concrete FinSet names (`set`, `arrow`, `apply`,
`set_*` universals) and the chapter-owner names retired in Stages 27–29 no
longer appear in their public owner surfaces. Remaining `arrow` names belong
to generic category/comma/diagram APIs or mathematical prose and are
intentional. A repository search found no stale Chapter 5–7 qualified names.

**Ownership.** `Finite_sets` owns recursive values, carriers, equality, and
morphism evaluation; `Universal.Diagrams`/`Universal.Limits` own generic
shapes and chosen universals; Chapter 5 owns comma/graph/indexed/functor
category constructions; Chapter 6 owns adjunction/preservation/algebra
constructions; Chapter 7 owns closed/topos capabilities and the finite-set
instance. No duplicate validator or second public representation was found.

**Definition reduction.** The reader guides and ledger now map the implemented
operations to incidence squares, indexed transport, naturality, adjunction
triangles, algebra homomorphism squares, exponentials, classifiers, power
objects, and quantifiers. The bounded slice, discrete-functor, and graph
exercise owners are now explicit; only general non-discrete/presheaf variants
retain research dispositions.

**Navigation and contracts.** README module links and all relative links in
`docs/*.md` resolve. The four positive compiler fixtures
(`positive.ml.txt`, `chapter5_positive.ml.txt`, `chapter7_positive.ml.txt`,
`chapter8_positive.ml.txt`)
compile. All fourteen negative fixtures fail at their intended type/privacy
boundaries, including the migrated adjunction and algebra records.

**Evidence.** Fresh `dune build --cache=disabled --no-config`, forced
`dune runtest --cache=disabled --no-config --force`, and `git diff --check`
pass. The complete suite retains the prior coverage receipts across
foundations, universal constructions, relations, Chapter 5 constructions,
adjunctions, algebras, toposes, and functor categories. No new broad
performance claim is made by this integration review.

### Finite topos exercise owners (complete)

The remaining Chapter 7 exercise contracts are now settled at the smallest
finite executable boundary. A slice owner fixes an anchor and computes every
operation fibrewise; a functor-category owner admits only discrete finite
sources, where pointwise exponentials and classifiers reduce to the existing
finite-set owner; a graph owner follows the repository's directed-incidence
orientation and computes the five-edge classifier. These alternatives were
selected over a second generic topos record because they preserve the current
equality and result-valued admission contracts while making the book's
reductions executable. General non-discrete functor categories and arbitrary
presheaf/slice claims remain reopen conditions, not hidden assumptions.

Completion evidence: the three functional owners build; their focused suite
checks slice fibre cardinalities and characteristic maps, discrete pointwise
exponentials/classifiers, and graph exponentials plus the five-edge classifier;
the forced complete suite remains green.

### Dense term unification and coequalizer reduction (complete)

The Chapter 8 boundary retains the book's coequalizer meaning but does not
retain its list-shaped substitution representation. `Term_unification` compiles
variables to dense integers, stores operator arguments in arrays, and uses
union-find/path compression during solving; `Terms` remains an explicit
adapter. `Coequalizer_reduction.factorized_coequalizer` owns the generic
pushout/coequalizer calculation from Exercise 1. Memoized pair reduction owns
finite first-order generalization from Exercise 2. The selected boundary is
falsified by requirements for higher-order, rational-tree, or equational-theory
unification, which remain outside this implementation.

### Closure-based presentation theory (kernel complete, extensions pending)

The Chapter 9 design is generalized rather than finite-equational. A
presentation contains an abstract signature and a persistent constraint
expression; a logic backend owns sentence transport, closure, entailment, and
optional model semantics. Closed theories are closure fixed points, so the
book's institution category is recovered without materializing sentence or
model sets. `Constructions.Presentations` now implements the generic kernel and
its focused abstract-backend test. Concrete institution adapters, theory
colimits, based environments, semantic operations, and the Grothendieck
construction remain dependent owners; their transport, closure, and colimit
premises are recorded in `docs/chapter9.md`.
