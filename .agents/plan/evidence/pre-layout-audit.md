# Historical Chapter 2-5 delivery audit

Historical evidence only; NOT a current governing plan.
The canonical ../architecture-plan.md governs the mathematical-layout refactor.
Older authority/status passages below retain their historical scope and must not
be interpreted as current execution authorization. This artifact is the exact
pre-layout history prefix of the preserved Stage 10 entry plan, after this header.
The current refactor section was excluded to avoid a second active-plan copy.
Full original plan and all entry files remain in the local recovery snapshot.
Do not append current implementation instructions to this historical artifact.

# Architecture Plan: Trustworthy Computational Category Theory in OCaml

## Goal, authority, and status

- **Goal:** repair the existing learning project into a type-safe, law-tested
  implementation of selected Chapter 2-5 material and Chapter 5 exercises, with a mathematical module hierarchy, including generic finite colimits,
  limits through duality, and the relations application.
- **Authority:** the current request authorizes mathematical-layout evaluation
  and planning only. The user approved clean local API migration and Dune
  minimum 3.7 for that plan, not implementation. Earlier Chapter 5 delivery
  remains historical evidence. Installation, publication, commits and host
  setup remain outside scope.
- **Baseline:** `10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c`.
  Current root: `E:/Proj/course/computational-category`. At Stage 1 entry, only
  this tracked plan was modified by the earlier planning turn; no source was dirty.
- **Canonical artifact:** this existing, **tracked** file,
  `.agents/plan/architecture-plan.md`. It is not an ignored or confidential cache.
  Do not create a second plan, untrack this file, or change ignore policy.
- **Status:** historical Stages 1-9 are complete within their stated gates.
  Mathematical-layout Stages 10-13 are planned below, not implemented or
  authorized for execution. The user approved clean local API migration and
  Dune minimum 3.7; task 10.1 is first ready after implementation authorization.
- **Preserved direction:** OCaml, Opam/Dune, one package, functional modules,
  categories as values, and universality as executable maps. No relay facades
  or per-chapter packages are justified by the current consumers.
- **Excluded:** Chapters 6-10, completing all omitted Chapter 2 exercises, a
  dependent-type/proof framework, a general heterogeneous OCaml category library,
  performance targets, deployment, and publishing.

## Authority and evidence

The mathematical source is D. E. Rydeheard and R. M. Burstall,
*Computational Category Theory*, at
`H:/Storage/LibDb/Math/Computational Category Theory.pdf`.
SHA-256: `17f3ba03c0a496a0da3cb8fc8845c349d6d05ff342eeb7d40341e1238d3f94c8`.
Printed pages, not PDF indices, are used below.

- §§3.3-3.7, pp.47-59: categories as values, equality, partial composition, and
  the distinction between ML type correctness and categorical laws.
- §4.2, pp.69-74: primitive universal constructions and recursive tagged elements.
- §§4.4-4.7, pp.79-92: diagrams, universal cocones, generic finite colimits,
  representative quotients, and the pushout example.
- §§4.8-4.10, pp.93-100: duality, pairing/terminal-value closure, and relations.
- Source at the baseline owns current implementation facts. The book owns the
  mathematical specification, not current implementation or build claims.
- The user accepted the evaluation and requested planning. That agreement does
  not prove correctness or settle unspecified failure/compatibility behavior.

### Observed baseline and defects

These are observations of the original baseline, not claims that every defect
remains current. Stage 2 repaired metadata/import discovery; Stage 3 delivered
safe foundations and primitive repairs; Stage 4 delivered generic diagram
algorithms and pullbacks. Stage 5 delivered relation admission, images and span
composition. Reader documentation remains unreconciled until Stage 6. Historical
observations and checkpoint evidence below retain their original scope.

| Evidence at the baseline | Consequence / planned owner |
| --- | --- |
| `src/finite_sets.ml:103-106`; casts throughout `colimits.ml`, `limits.ml`, `functors.ml`, and `relations.ml` | Homogeneous raw payloads are not closed under the required constructions. Representation contract: Stage 1; repair: Stage 3. |
| `src/colimits.ml:142-146` | Both pushout legs are the coproduct quotient map, not arrows from the two input targets. Stage 3. |
| `src/limits.ml:9-16`; OCaml-inferred signature | Terminal arrows have empty source; the terminal bundle and dual bundle specialize to `unit`. Stage 3. |
| `src/relations.ml:17-26` | Relation projections target the relation carrier rather than its endpoints. Stage 5. |
| `src/cat.ml:25-29`, `src/finite_sets.ml:114-118`, `src/term_category.ml:24-26` | Structural list equality conflicts with extensional finite-set equality; the result wrapper can still raise. Stages 1 and 3. |
| `src/finite_sets.ml:40,235-236`; `src/core.ml:79-80` | Set images can contain duplicates; tag removal collapses distinct summands; free-monoid evaluation reverses order. Stage 3. |
| `src/graphs.ml`; `src/colimits.ml:148-152`; `src/relations.ml` | Diagram types exist, but general finite-colimit/dual-limit builders, pullbacks, and relation composition are absent. Stages 4 and 5. |
| `src/finite_sets.ml:208-227`, `src/colimits.ml:60-78`; no `.mli` files | Duplicate partition computation and publicly exposed representation/mutable state. Stages 1 and 3. |
| `dune-project:4`, `src/dune`, `tests/dune`, `computational_category.opam` | Dune stops at source metadata syntax; naming/wrapping metadata also require reconciliation. Stage 2. |
| `README.md` and the superseded version of this plan | Wrong book attribution, unsupported layering/visibility/safety claims, and absent capabilities described as implemented. Stage 6; this plan corrects its own claims now. |

**Executed evidence from the preceding review:** OCaml 5.2.1 loaded all current
modules and ran all seven existing test groups successfully in memory. Separate
probes reproduced the endpoint, equality, set-image, normalization, and monoid
defects. The tuple constructor syntax worked, contradicting its alleged parsing
ambiguity. Dune 3.24.2 failed at `dune-project:4` using a temporary build directory.
These are not a successful Dune build or evidence of universal-property correctness.
Old `_build/` artifacts are not completion evidence.

The verified local switch executables are in
`C:/Users/nostalgia/AppData/Local/opam/default/bin`; they are not on the current
shell PATH. Activate that existing switch's environment or set a process-local
PATH for checks. OCaml/Dune installation is not a prerequisite on this machine.
Dune metadata/wrapping references:
[source](https://dune.readthedocs.io/en/stable/reference/dune-project/source.html),
[package](https://dune.readthedocs.io/en/stable/reference/dune-project/package.html),
[library](https://dune.readthedocs.io/en/stable/reference/dune/library.html).
Resolve any version-sensitive detail against the selected Dune version.

## Decisions and invariants

### D1. Scope and package topology — settled for this goal

Retain the existing language, build system, and single functional package.
Grouping follows ownership and dependencies, not chapter numbers or a strict
numeric layering claim. The inspected consumers are the repository tests and
README examples; no supported external consumer is identified by those sources.
Absence of such evidence is not proof that external consumers do not exist.

Owner: package/topology contract. Reopen only for an evidenced consumer,
dependency cycle, genuine independently reusable boundary, or changed user goal.
Do not add a facade, compatibility shim, package, or module solely for symmetry.

### D2. Closed finite-set representation — settled target

Select a sealed FinSet module instance parameterized by the atomic payload type
and its equality module, using a native OCaml functor. Its abstract value, set,
and arrow types bind equality to the instance: different equality modules must
not share these types even if their payload types are both `int`. Construction
modules consume that same sealed instance rather than independently choosing
equality. Repeated use of the same equality module may share applicative types.

The value universe is recursively closed under atoms, nested summand labels,
pairs, and a terminal value. Expose safe constructors and a read-only structural
view so concrete constructions in other modules do not need private fields or
casts. Lift the supplied atomic equivalence through the constructors; never use
polymorphic OCaml equality on unknown payloads. Atomic payloads must be immutable
and their equality lawful, stable, and terminating. Current integer, character,
and string examples fit this premise.

Sets are duplicate-free, with extensional equality independent of enumeration.
Images deduplicate. Labels preserve overlapping and nested summands; display is
not a lossy normalization consumed by algorithms. Quotient targets use actual
representatives in this universe, not lists of equivalence classes cast to atoms.
Class lists may be inspection data. Representative selection is deterministic
for the same admitted enumeration, but canonical names, permutation-independent
representatives, and a fixed tag encoding are not promised. Compare alternative
quotient presentations via the induced isomorphism and mediator equations.

Material comparison:
- **Raw elements plus unchecked casts: invalidated.** Not closed or type-safe.
- **Recursive universe plus representatives: selected.** Preserves the book's
  named-element/category-as-value model and supports nested constructions.
  Accepted cost: wrapped atoms and a new instance-based public API.
- **Heterogeneous typed arrows with category/diagram packaging: deferred.**
  Addresses a broader library goal; two arrow type parameters alone do not
  integrate such arrows into the existing homogeneous generic contracts.
- **Finite ordinal objects: deferred alternative.** Changes the named-element
  contract without a current consumer requiring it. Freezing finite arrow maps
  under D3 does not replace objects by ordinal encodings.

Owner: `Finite_sets`. Exact constructor spelling and private storage are
implementation choices. No `Obj.magic` or substitute unsafe cast may remain
in the repaired source. Reopen if nested type integration or an admitted caller
requires heterogeneous objects, a different identity contract, or mutable atoms.

### D3. Equality, admission, and failures — settled target

**Category capability.** For this Chapter 2-4 slice, `Cat` carries supplied
computable object and arrow equality plus checked composition. This deliberately
narrows arbitrary mathematical categories to ones with executable equality;
undecidable-equality and later functor-category generality are not promised.
Generic composition delegates to the category's checked operation, with order
`g after f`; it never adds a structural-equality precheck or compares closures.
Duality reverses endpoints/composition and retains the supplied equality.

FinSet object equality is extensional. Arrow equality compares source and target
objects and outputs on the finite source, never callback identity. An arrow is
admitted by sampling its callback once per distinct source member on successful
construction, checking target membership, and retaining the complete finite
mapping. Application, equality, identity, and composition operate on admitted
maps without replaying that callback. Application to any value equivalent to a
source member uses the same stored entry; outside-source application fails.
Private arrays or association lists are not contractual choices.

This pays finite admission work and source-sized retained mapping data to avoid
a supposedly checked arrow changing afterward. Trusted callbacks without a
snapshot would not preserve the promised invariant; revalidating on every use
would repeatedly execute external code and still make equality unstable.
No latency, large-scale performance, or constant-space guarantee is inferred.

**Other supported categories.** Finite-category examples supply their own
computable equality. Term substitutions use extensional finite variable-name
sets, finite well-founded term trees, and named operators with finite argument
labels; labels identify positions, not list enumeration. Snapshot callback-based
substitution/argument maps over those labels and check variables against the
declared target. Term equality is syntactic structural equality of those admitted
trees under operator-name/label identity, not closure or alpha-equivalence.
Infinite/cyclic term generators and general symbolic-equivalence problems are
outside this slice.

**Failure contract.** `Cat` owns a shared typed semantic error vocabulary.
Expected categorical failures return `Error`, rather than a second direct-
exception composition API: noncomposable/nonparallel arrows, outside-domain or
outside-codomain values, malformed graph/diagram/term/relation input, different
bases, and failed commuting/factorization preconditions. Context identifies the
operation and affected endpoint/label when available; diagnostic prose and exact
variant spelling are not frozen. Nonfailing accessors and identity on admitted
objects need not acquire artificial error cases.

Caller callbacks and equality functions must be pure and terminating; supplied
objects/arrows/equality and category dictionaries must remain lawful and stable.
Callback/equality exceptions and runtime failures propagate unchanged, without
blanket catching, retries, or successful partial admission. Divergence is not a
typed result and has no promised timeout. Admission cannot decide arbitrary
callback totality or prove global equivalence/category laws. Use one consistent
category/capability dictionary per calculation; incoherent or mixed dictionaries
are outside the supported premise. This does not globally convert unrelated
`Core` exercise exceptions.

**Diagram and universal-map boundary.** Graph identifiers and bindings are finite,
complete, and unambiguous; freeze node/edge/source/target maps on the declared
identifiers and check endpoints at admission. Reject conflicting or undeclared
bindings, not silently skip them. Graphs/diagrams/cones/cocones have enforced
admission boundaries; downstream algorithms consume admitted values.

Cone/cocone bases agree extensionally on labelled node/edge sets, graph endpoints,
node objects, and edge arrows under the supplied categorical equality. A new
record or reordered enumeration is not a different base; a changed edge is.
Check side endpoints and commuting equations. Universal maps check their specific
source/target/base and compatibility equations before returning a mediator (D4).
Relations check pair membership, common span sources, and intermediate endpoints.

Owner: `Cat` for categorical capabilities/errors; `Finite_sets`,
`Term_category`, `Graphs`, and `Relations` for their own admission invariants.
No competing validator or structural equality authority is permitted. Reopen
only a failed boundary, law premise, or evidenced cost/consumer conflict.

### D4. Universality and generic reuse — settled mathematical requirements

Every construction returns structural arrows and an executable universal map,
not just an apex or its cardinality. Direction and input obligations are:

| Construction | Structural arrows | Admitted universal input / mediator |
| --- | --- | --- |
| Initial / terminal | From initial to X / from X to terminal | Declared X; arrow with those endpoints |
| Coproduct / product | A,B to C / P to A,B | f:A→X,g:B→X / f:X→A,g:X→B; mediator C→X / X→P |
| Coequalizer / equalizer of parallel f,g:A→B | q:B→Q / e:E→A | h:B→X with hf=hg / h:X→A with fh=gh; mediator Q→X / X→E |
| Pushout / pullback | B,C to P for common-source f,g / P to A,B for common-target f,g | Compatible pair of legs; mediator from / to P |
| Finite colimit / limit | Cocone / cone over the admitted diagram | Commuting cocone / cone on the same base; mediator between apexes in the universal direction |

Generic finite colimits use only a lawful category and its initial, binary
coproduct, and coequalizer capabilities, never FinSet tags/storage. Finite limits
reuse the construction through duality and terminal/product/equalizer capabilities.
If an inductive implementation restricts a diagram, universal-map inputs to a
subconstruction carry that restricted base; the full result restores the original
base. Do not weaken base checking to accommodate abbreviated book pseudocode.

A span retains witnesses, including multiple witnesses for one endpoint pair
after pullback composition. The extensional relation image is an explicit
deduplicating projection, not destructive normalization of the span.

Owner: universal-construction contract. Supplied category/capability laws remain
premises; finite tests and the Stage 1 witness are not a proof for all categories.

### D5. Ownership, visibility, and compatibility — settled target

Keep the existing functional peers and one package. Selected dependencies
below are the target, not a claim about current interfaces:

| Existing owner | Target responsibility and permitted domain dependencies |
| --- | --- |
| `Cat` | Category operations, equality, shared semantic failures, duality; no concrete-category dependency |
| `Finite_sets` | Sealed instance, values/sets/arrows and admission, FinSet category; depends on Cat |
| `Universal` | Primitive capability/data contracts and their categorical operations; depends on Cat, not Graphs or FinSet |
| `Graphs` | Admitted graph/diagram/cone/cocone, base transformations, generic finite-colimit/dual-limit algorithm and diagram specializations; depends on Cat and Universal, never FinSet |
| `Colimits` | Concrete FinSet initial/coproduct/coequalizer and colimit specialization; depends on Finite_sets, Universal, Graphs |
| `Limits` | Concrete FinSet terminal/product/equalizer and dual-limit specialization; depends on Finite_sets, Cat, Universal, Graphs |
| `Functors` | Functor operations and instance-based product functor; depends on relevant categorical/diagram/FinSet contracts |
| `Relations` | Generic span application through supplied complete-category capabilities and concrete FinSet pair admission/image; depends on Cat, Graphs, Finite_sets and required specialization |
| `Core`, `Term_category` | Existing exercise/domain owners; Term_category supplies Cat-compatible admitted substitutions and finite-category operations |

`Graphs` is the single physical home of the generic diagram algorithm, beside
its diagram and universal-cone/cocone contracts. This adds the meaningful
Graphs→Universal→Cat direction without a cycle. Moving it into Universal would
couple primitive contracts back to diagrams; concrete Colimits would mix generic
ownership with FinSet specialization. Neither alternative improves the required
dependency separation enough to justify that move or a new relay module.

Coequalizer partition/union-find computation has one private implementation
owner, `Colimits`; retire its duplicate in Finite_sets and do not export mutable
scratch. Finite_sets need not depend on universal constructions. Enforce claimed
abstraction with signatures; safe views permit cross-module construction.
Private representation and scratch state cannot be public compatibility surfaces.

**Package/namespace settlement.** Use `computational_category` as the canonical
Opam package and public/internal library name, preserving the existing Opam
filename, src public_name, and test dependency. Dune's single-package constraint requires the Dune project name to match;
use `computational_category` there too, while retaining repository slug
`computational-category`. Reconcile conflicting hyphenated package metadata,
not the existing library consumers. Preserve Dune wrapping; the public OCaml
entry is `Computational_category`. Migrate test imports and later README examples
under that wrapper rather than setting `wrapped false`.

Both dash and underscore are permitted Opam names; the underscore choice follows
the current file/library/dependency, not a language restriction. Package-file
discovery and public-name attachment follow [Dune packages](https://dune.readthedocs.io/en/stable/reference/packages.html);
namespace behavior follows [Dune library](https://dune.readthedocs.io/en/stable/reference/dune/library.html);
allowed names follow the [Opam manual](https://opam.ocaml.org/doc/Manual.html).
Use the configured origin, `https://github.com/nostalume/computational-category.git`,
for source metadata instead of placeholder `example` links. Retain declared
OCaml ≥4.14 and Dune ≥3.0 targets; only OCaml 5.2.1 was used for this witness.

**Cutover.** Inspected public consumers are the source modules, tests, README
examples, and build/package manifests. There are no local tags. These observations
do not establish whether remote releases or external consumers exist, and none
were claimed to be supported by the inspected material. Select a local cutover,
not speculative backward-compatibility shims. If a supported external consumer
is evidenced, reopen its migration obligations before breaking that surface.

Intentional breaks: raw list/set-arrow constructors and mutable fields become
abstract instance APIs; separate legacy tag types and lossy helpers are retired
or replaced by safe structural views; checked categorical failures replace direct
composition exceptions. Stage 2 migrates package/import consumers, Stage 3 migrates
foundation/primitive consumers and required type plumbing, Stages 4-5 deliver
generic/application behavior, Stage 6 migrates verified reader examples. Necessary
relation type plumbing in Stage 3 is not a claim that its semantics are repaired.
Exact API spelling and unrelated exercise exports remain implementation-local.

**Stage 2 decision delta (2026-10-10):** the earlier selection treated the Dune
project name as independent of package identity. The actual Dune 3.24.2 parser
rejected the underscore package with the hyphenated project name: a single
package must match its project. Reopen only that metadata premise; select the
underscore Dune project name, preserving the Opam filename/library/dependency
and repository slug. A second dummy package or renaming the existing library
would add scope without satisfying an admitted consumer. D2/D3, wrapping,
functional ownership and mathematical requirements remain unchanged. Fresh
release and package-selected builds below validate the corrected resolution.

Owner: module/compatibility contract. No new layer, facade, per-chapter package,
host installation, release, or compatibility window is authorized.

## Staged handoff

Checked tasks record completed evidence; unchecked tasks describe future outcomes.
Each stage closes a reviewable outcome,
not an automatic branch, commit, approval gate, or implementation authorization.
Update decisions and evidence here rather than duplicating them in another plan.

### Stage 1 — Settle the semantic and migration contract

**Consumer:** the implementer of Stages 2-5. **Dependencies:** baseline review.
**Owner:** architecture-planning. **Status:** complete on 2026-10-10.

- [x] **1.1 Close D2, D3, and D5.** Trace nested coproduct/product/quotient use,
  composition and its failure path, universal factorization, and public callers.
  Record the selected representation, equality/admission/error contract, relation
  witness semantics, public-name compatibility, and generic algorithm owner.
  If signatures remain uncertain, use a disposable in-memory type witness only:
  empty object, nested labelled coproduct, product, representative quotient, and
  dual primitive bundle. No production source or installation is part of this
  exploration. Stop once these finite cases establish type closure or expose
  the exact blocker; discard the witness, or reopen only the failed decision.

**Exit evidence:** D2/D3/D5 settled, supported input/output/error behavior explicit,
no unsafe cast needed for the witness, migration consumers accounted for,
dependencies acyclic. Ask the user only for a material goal or compatibility
tradeoff that evidence cannot decide. A failed witness leaves dependent stages
conditional, not implementation-ready.

**Recorded completion evidence (2026-10-10):**
- Fresh inspection at the same HEAD rechecked modules/callers, manifests, dirty
  state, origin, local tags, and applicable instructions. The book SHA-256 matches
  the earlier review. The current workspace root is E:/Proj/course/computational-category;
  the old recorded C: root was stale and is corrected above.
- Disposable OCaml source was piped via a PowerShell here-string to the existing
  `ocaml.exe -noinit -noprompt -nopromptcont` (5.2.1), without creating a source
  file, installing a dependency, or loading production implementations.
- Sealed instances for integer and string atoms typed and ran: empty initial
  source; nested labelled sums of cardinalities 4 and 6; product cardinality 8;
  coproduct/product mediator equations; a fixed representative quotient
  {1,2}→{1} and compatible/incompatible factor inputs; terminal arrows with actual
  non-unit sources; typed terminal/product/equalizer bundles in the dual.
- Reordered-set composition succeeded; invalid endpoints, outside-source
  application and outside-target images were rejected. Instrumented admission
  called a callback twice for a two-member source and no more on application;
  a callback exception propagated unchanged. Custom absolute-value equality
  deduplicated 1 and -1. An external construction module consumed the sealed
  interface without private fields or casts.
- Positive output contained `STAGE1_WITNESS_PASS` and
  `STAGE1_EXTERNAL_OWNER_PASS`, without interpreter errors or exceptions.
  An isolated negative run rejected passing an Abs_eq-instance set to the
  Int_eq-instance equality function despite both payloads being integers.
- This is type-closure/admission feasibility, not production verification,
  minimum-version testing, a general coequalizer algorithm, or a proof of
  generic colimits. The witness is discarded, not a second implementation.

### Stage 2 — Establish a reproducible Dune baseline

**Consumer:** all subsequent source verification. **Dependency:** Stage 1's package
and namespace contract. **Owner:** software-development.
**Status:** complete on 2026-10-10 as a harness baseline; development-profile
warning failures explicitly carried to Stage 3.

- [x] **2.1 Repair the build contract and migrate its callers.** Reconcile source
  metadata syntax, valid dependency/tag fields, package identity across manifests
  and Opam filename, public library naming, wrapper namespace, and test imports.
  Use the existing installed switch; do not install tools as an implicit task.
  Run a fresh Dune build/test baseline without relying on old artifacts.

**Exit evidence:** manifests parse; package/library/test discovery and imports work;
all seven baseline groups execute through Dune. Preserve the declared minimum
versions; if not tested, report that boundary rather than claim compatibility.
Pre-existing warning-as-error failures may be characterized using an explicitly
reported release-profile run; retain normal development warning policy and assign
the warnings to Stage 3. Such a run is a harness baseline, not a repaired-library
claim. Do not blanket-disable compiler warnings to manufacture completion.

**Recorded completion evidence (2026-10-10):**
- Changes: `dune-project` uses a valid nested GitHub source stanza, canonical
  underscore project/package names, package tags and `depends`;
  `computational_category.opam` agrees with its filename and actual origin;
  `tests/functional_test.ml` opens `Computational_category`. Library/test Dune
  stanzas already selected the correct name and were left unchanged. All seven
  baseline assertions/groups and all `src/*.ml` implementations are unchanged.
- Fresh before-change `dune build` failed at `dune-project:4` (exit 1).
  After repair, normal development `dune build` reaches source compilation but
  fails at `src/finite_sets.ml:145`, warning 39, unused `rec` (exit 1).
  No warning policy was changed. Release compilation also reports existing
  warning 26 at `src/colimits.ml:133` and warning 11 at
  `src/limits.ml:29,32`; assign these to their Stage 3 owning repairs.
- Final checks used OCaml 5.2.1 and Dune 3.24.2 from the installed default switch,
  process-local PATH only, separate new temporary build directories, disabled
  Dune cache, and no old workspace `_build` artifacts. Compiler subprocesses
  needed approved unsandboxed execution for Cygwin signal/shared-memory objects.
  No tool installation or host setting change was performed.
- `dune build --profile release --build-dir <new-temp>/release --cache=disabled --no-config`:
  exit 0; matching `dune runtest ... --force`: exit 0, all seven groups passed.
- `dune build -p computational_category -j 3 --build-dir <new-temp>/package --cache=disabled`:
  exit 0; matching `dune runtest -p computational_category ... --force`:
  exit 0, all seven groups passed. Dune `-p` already implies release-profile/
  no-config behavior; do not repeat `--no-config` with it. The generated
  `computational_category.install` names the library and its public wrapper.
  These are local staging artifacts only, not an installation or publication.
- `opam lint computational_category.opam` (Opam 2.6.1): Passed, exit 0.
  `git diff --check`: passed. Final conformance found no blocker in this
  metadata/import slice; no independent-agent review was requested.
- Minimum OCaml 4.14 / Dune 3.0 were not tested; targets are retained, not certified.
  This slice does not establish category laws, cast safety, complete algorithms,
  corrected reader docs, or a passing normal development build.

**Reproduction on this host:** prepend the installed switch's
`C:/Users/nostalgia/AppData/Local/opam/default/bin`, its existing MinGW bin at
`C:/Users/nostalgia/AppData/Local/opam/.cygwin/root/usr/x86_64-w64-mingw32/sys-root/mingw/bin`,
and `C:/Users/nostalgia/AppData/Local/opam/.cygwin/root/bin` to process-local PATH;
set process-local `OPAM_SWITCH_PREFIX` to the switch prefix. This avoids the
current shell's missing compiler PATH. Direct `opam exec` was not usable in the
sandbox (log-write/cygpath setup errors); the existing environment file supplied
the paths. For lint, direct `opam lint` worked with `OPAMLOGS` redirected to
the task's temporary root. Use newly created temporary build directories for
the commands above; remove the task build root after checks. Dune's package build
also promoted a temporary `computational_category.install` into the workspace;
its hash matched the staged manifest and its paths identified this task, so it
was removed rather than tracked or left as a stale build artifact.

### Stage 3 — Deliver safe foundations and lawful primitive capabilities

**Consumer:** generic construction and application implementers.
**Dependencies:** Stages 1 and 2. **Owner:** software-development.
**Status:** complete on 2026-10-10; normal-profile build and law-suite evidence
recorded below. Regression tests travel with each owning repair.

- [x] **3.1 Migrate finite sets, categories, and their existing consumers.**
  Implement the settled closed universe, invariant-preserving set operations,
  category-owned equality/composition/failure behavior, and enforced visibility.
  Remove duplicate partition computation and exposed mutable internals. Adapt
  category examples, term substitutions, and identity/product/dual functors.
  Correct free-monoid order with a noncommutative test. Any retained splitting
  helper used by recursion must demonstrably reduce the finite input.
- [x] **3.2 Repair primitive universal constructions.** Depends on 3.1. Supply
  initial/terminal, coproduct/product, coequalizer/equalizer, and pushout behavior
  with correct endpoints and executable mediators. Quotients retain representative
  closure; pushout legs originate at their respective target objects. Consume
  the settled admission/precondition policy instead of adding a second validator.

**Exit evidence:** normal-profile build/tests pass for this slice; no unsafe casts
remain in these migrated owners; terminal/dual bundles work over base payloads
other than `unit`; reordered object enumerations compose consistently; duplicate
images deduplicate; nested/overlapping summands remain distinct. Check category
and functor laws, substitution behavior, quotient equivalence closure, and each
primitive's endpoint, commuting, factorization, and bounded uniqueness laws.
Do not call the still-unmigrated relation API repaired at this stage.

**Recorded completion evidence (2026-10-10):**
- `Finite_sets.Make(E)` seals value/set/arrow types to atomic equality E.
  `Finite_sets.S` supplies safe recursive atom/tag/pair/terminal construction,
  structural views, deduplicating/extensional operations and finite admission.
  Raw list/arrow records, independent legacy tags, lossy normalization, direct
  exception composition and exposed partition scratch were retired. Successful
  arrow construction samples once per unique source and retains immutable entries.
- `Cat` now supplies equality and shared typed failures with category-owned
  checked composition and duality. TermCategory seals finite variable sets,
  operators, term trees and substitutions; function maps are frozen at admission.
  Identity/product/dual functors consume the new contracts. Core's free-monoid
  map now accumulates in word order, including noncommutative output.
- `Colimits.Make(F)` and `Limits.Make(F)` consume the same sealed instance F.
  Initial/terminal, coproduct/product, coequalizer/equalizer and the derived
  pushout have structural arrows and checked mediators. The private Colimits
  partition calculation materializes classes/routes; union-find arrays do not
  escape into quotient values, arrows or mediator closures. Quotients use actual
  carrier representatives; the duplicate Finite_sets implementation is gone.
- Graph/diagram/cone/cocone admission and typed arrow accessors were delivered
  as foundations, enforced by `src/graphs.mli`. Complete finite labelled maps,
  endpoint checks, commuting equations and extensional base comparison replace
  exposed callback records. Malformed binding/graph errors retain the offending
  finite label; targeted tests check this diagnostic context. Generic diagram algorithms remain unimplemented.
- `Relations` now has an abstract checked generic span surface, enforced by
  `src/relations.mli`. The old cast-based `relation_span` converter was retired
  as necessary API plumbing; concrete pair conversion/image and span composition
  were NOT delivered or claimed repaired at that checkpoint (Stage 5 work).
  Pullbacks were also absent there and were assigned to Stage 4.
- Normal-profile before-change build failed on warning 39 in Finite_sets.
  Final fresh `dune build` and `dune runtest --force` both exited 0, with no
  compiler warnings emitted and no warning overrides. Existing Stage 2 metadata,
  library/test Dune stanzas and README were not edited in this turn.
- `tests/functional_test.ml` now runs eight groups: Core, finite-set admission,
  category laws, terms, functors, primitive universality, pushouts, and diagram
  admission/span plumbing. Output: 6,146 generated map fixtures (including repeats
  across laws), 973 composable associativity triples, 1,020 unique-mediator cases.
  Enumerated carriers are all four subsets of a two-atom set (18 FinSet arrows);
  mediator domain/codomain sizes stay at most four. FinSet and its dual are
  exhaustively checked on those arrows; the finite category and selected term
  substitutions are additional bounded fixtures.
- Tests cover empty cases, reordered endpoints/bases, duplicate images, nested/
  overlapping sums and products, non-unit/string dual primitives, character and
  custom-equality quotients, transitive equivalence closure, representative changes
  up to induced isomorphism, mediator endpoints/equations/uniqueness, separate
  source/target mismatches, invalid diagrams and callback/equality exceptions.
  Larger fixed closure examples (including a four-member quotient carrier and
  a sixteen-member nested product-functor object) use targeted equations, not
  an exhaustive universality claim.
- Compiler fixtures in `tests/type_contracts/*.ml.txt` were checked separately
  with `ocamlc`, not silently included in `dune runtest`. The positive public-
  namespace/sealed-instance consumer compiled (exit 0). Four negatives exited 2
  with the expected diagnostic, not merely any compilation failure: mixed
  equality instances, raw arrow fields, private C.partition and raw graph fields.
- Three temporary source mutations produced their intended semantic test failures:
  `m.op (acc, f x)`→`m.op (f x, acc)` in Core (word order);
  pushout leg `q ∘ inj1`→`q ∘ identity(coproduct)` (wrong source);
  category-owned generic composition→structural middle-object precheck.
  Each original file was restored byte-for-byte in a finally block before fresh
  final build/test verification. These are mutation-sensitivity checks, not TDD.
- Source residue check found no `Obj.`, unsafe operations, cast-based/raw arrow
  aliases or old direct composition wrappers in source; `git diff --check`
  passed. Final conformance found no blocker. Independent-agent review was not
  requested/performed. Atomic immutability, stable equivalence, pure terminating
  callbacks and coherent lawful dictionaries remain caller premises; minimum
  OCaml/Dune versions and general formal correctness were not certified.

**Construction argument carried to Stage 4:** coproduct labels distinguish
summands and retain nesting; product values retain both components. A compatible
map out of a coequalizer is constant on the generating pairs, hence on their
equivalence closure, so restriction to representatives factors through q.
An equalizer is the admitted subset where f and g agree; a compatible incoming
map lands in that subset. Initial maps have empty source; terminal maps have
singleton target. For pushout, the quotient of the coproduct coequalizes
the two injected input legs; its legs are q after each injection and its mediator
is the coproduct mediator followed by quotient factorization. These explanations
plus finite tests support the implementation slice, not a proof of arbitrary
supplied categories or resource-unbounded execution.

**Reproduction:** use the process-local switch/toolchain paths recorded in Stage 2.
With a newly created temporary directory B:
`dune build --build-dir B --cache=disabled --no-config`, then
`dune runtest --build-dir B --cache=disabled --no-config --force`.
This turn tested OCaml 5.2.1 / Dune 3.24.2 with approved compiler subprocess access;
no installation/host setting change was made. Type probes use
`ocamlc -I B/default/src/.computational_category.objs/byte -c -impl tests/type_contracts/NAME.ml.txt -o TEMP/NAME.cmo`.
Compile `positive` first; for the four named negatives require exit 2 and the
specific type/field/value diagnostic above. Use valid underscore output-module
names. Keep compiler outputs outside the source tree. Task staging is removed
after evidence capture. Reader examples still use the superseded API; Stage 6
must reconcile them before claiming the documented reader experience works.

### Stage 4 — Deliver generic finite colimits and dual limits

**Consumer:** concrete FinSet specialization and pullback-based applications.
**Dependency:** Stage 3. **Owner:** software-development.
**Status:** complete on 2026-10-10; final scoped evidence is recorded below.

- [x] **4.1 Implement generic finite-colimit computation with universality.**
  Respect D4 and the selected owner. Handle the empty diagram, finite discrete
  diagrams, and diagrams with edges, carrying every side and mediator through
  composition. Consume the admitted diagrams under D3 and preserve the typed
  cone/cocone accessor contracts delivered in Stage 3.
- [x] **4.2 Specialize and dualize.** Depends on 4.1. Integrate FinSet finite
  colimits, dual diagrams/cones/cocones/universal arrows, general finite limits,
  and pushout/pullback specializations. Avoid parallel authoritative algorithms
  for the same operation.

**Exit evidence:** generic code has no concrete FinSet dependency and is exercised
with a separately specified lawful small category/capability bundle as well as
FinSet. Test empty, discrete, parallel-edge, and pushout/pullback diagrams,
dual direction, correct cocone/cone arrows, and mediator equations. The §4.7
pushout example has five apex elements and the required commuting sides, up to
the explicit isomorphism induced by labels/representatives. Do not freeze the
book's raw representative strings or tag nesting as a new compatibility promise.

**Recorded completion evidence (2026-10-10):**
- Stage 4 entry preserved the existing Stage 1-3 dirty state at HEAD `10ddb0c`;
  its fresh normal-profile build and eight-group foundation run exited 0.
  No applicable AGENTS.md was found in the relevant root/ancestor/source/test
  locations. No independent-agent review was authorized or performed.
- `Graphs.finite_colimit` owns the generic recursion: a discrete diagram is
  reduced one node at a time using initial/binary-coproduct capabilities; each
  remaining edge is imposed by coequalizing its source side and target-side
  composite. Recursion decreases a finite node/edge list. No concrete set/value
  representation is inspected. Mediators restrict the input cocone to the
  actual predecessor base before using its universal map, and return checked
  cocone arrows on the full original base.
- Graph, diagram, cone/cocone and arrow dual transformations reverse both graph
  endpoints and categorical direction. `dual_colimit`/`dual_limit` conjugate
  a capability in the opposite category of the input diagram; signatures state
  this premise. Universal arrows have checked input/output cones in the required
  direction, not just an underlying arrow or apex.
- `Colimits.Make(F)` exposes `set_colimit` and `cocomplete_finset`.
  `Limits.Make(F)` exposes `set_limit`, `complete_finset` and
  `set_pullback`, reusing the same generic algorithm through the existing dual
  primitive bundle. `Universal` adds checked pullback data/capability types.
  Graphs owns pushout/pullback diagram specializations and mediator assembly.
  The earlier concrete direct pushout derivation was retired; `set_pushout`
  now consumes `Graphs.pushout` and the shared colimit capability. Its existing
  endpoint/equation/uniqueness suite still passes. There are no parallel generic,
  quotient or pullback algorithms and no new package/facade.
- `tests/diagram_test.ml` adds five groups alongside the preserved eight
  foundation groups. The test Dune stanzas explicitly select their modules.
  Final fresh normal-profile `dune build` and `dune runtest --force` exited 0,
  with all 13 groups passing, no compiler warnings and no warning overrides.
  Cache/config were disabled and build outputs were outside the source tree.
- New suite output: 461 FinSet diagrams, 5,350 diagram mediator cases,
  5,529 bounded uniqueness cases (diagram and pullback cases combined),
  351 larger equation-only cases; 39 Boolean-order diagrams and 100 Boolean
  mediators; 114 FinSet pullbacks. Eleven shape templates cover empty, discrete
  diagrams of one/two/three nodes, loops, an edge, parallel edges, cycles,
  chains, spans and cospans. Each template enumerates all assignments of the
  four subsets of a two-atom carrier and all admitted edge maps.
  This is not enumeration of every possible graph topology.
- Mediator endpoints, side/edge triangles, full original bases and input/output
  cone/cocone-arrow accessors are checked. Uniqueness enumerates all maps only
  when the derived apex has at most four elements; larger derived objects
  (up to six for these colimits/eight for these limits) retain equation and
  endpoint checks, not an exhaustive uniqueness claim. Double-dual universality
  compares both colimit presentations by induced isomorphism on all 461 diagrams.
- The independent non-FinSet capability fixture is the two-object Boolean order
  false <= true, with endpoint-pair arrows, joins/false as colimit primitives and
  meets/true in the opposite category. All three valid arrows have identity,
  endpoint, composable associativity and noncomposable rejection checks.
  Its diagram apexes are checked against independently calculated join/meet;
  mediator uniqueness uses the independently enumerated endpoint pairs.
- Reordered object/node/edge presentations compare via universal induced
  isomorphisms. Changed-edge and empty/nonempty base mismatches are rejected.
  Primitive semantic errors and thrown exception identities propagate unchanged.
  Non-unit/string pullbacks preserve six witnesses in the targeted f-with-itself
  fixture, and the diagonal mediator projects to identities.
- The supplied PDF hash was reverified unchanged. A located text-layer extraction
  with pypdf revisited printed pp.83-88 and 90-96 (PDF pages = printed + 13).
  The book's pp.90-92 pushout fixture returns five classes, all specified labelled
  identifications and distinctions, a mediator to an explicitly labelled quotient
  with a checked inverse, reordered-presentation isomorphism and specialized
  mediator equations. Its raw representative strings/tag nesting are not frozen.
  A supplementary render was unavailable because the bundled Python lacked
  PyMuPDF; no package was installed and no visual/transcription-fidelity claim
  is made for that unperformed render.
- Manual compiler fixtures were rerun separately, not counted as Dune tests.
  The positive public-namespace fixture now consumes the generic/specialized
  capabilities and compiled without warnings (exit 0); four negatives exited 2
  with their specific expected diagnostics. `ocamldep -modules` reported only
  Cat/List/Universal for Graphs implementation, Cat/Universal for its interface
  and Cat for Universal. Generic code therefore has no FinSet dependency.
- Three temporary mutations compiled and triggered semantic failures: feeding
  the full cocone instead of its restricted edge-removal base; omitting dual
  graph endpoint reversal; and failing to reverse a dual cocone-arrow's domain
  and codomain. Each source was restored byte-for-byte in a finally block before
  the fresh final checks. These are mutation-sensitivity checks, not TDD.
- Source residue checks found no `Obj.`/unsafe operations or legacy lossy/direct
  composition helpers; `git diff --check` passed. Final self-conformance found no
  blocker. Existing metadata, README, relation source, Cat/Core/Finite_sets,
  term/functor source, functional_test.ml and warning policy were not changed
  in this turn; the separate positive type fixture was extended. Disposable
  compiler/mutation staging is removed after evidence capture. No installation, publication, commit or Stage 5 work occurred.

**Construction argument:** on a discrete diagram, the initial case has its unique
map and the node step combines the unique tail mediator with the head side by
binary-coproduct universality. For an edge e:s->t, the prior cocone sides
xi_s and xi_t after D(e) are parallel. Their coequalizer q makes every new side
q after xi_n commute with e and preserves earlier equations. A cocone on the
full diagram restricts to the predecessor, inducing u; its e equation implies
u coequalizes that pair, hence factors uniquely through q. Uniqueness at each
node/edge step yields the complete mediator. Limits reverse this argument through
duality. Pushout/pullback mediators assemble the common-source/common-target side
from the supplied compatible legs and use the same diagram universal map.
This explains the construction under lawful supplied dictionaries/capabilities;
finite runtime tests are not a machine-checked general proof.

**Reproduction and limits:** use the existing process-local toolchain environment
from Stage 2 and a fresh temporary build directory B:
`dune build --build-dir B --cache=disabled --no-config`,
then `dune runtest --build-dir B --cache=disabled --no-config --force`.
OCaml 5.2.1/Dune 3.24.2 were tested with approved compiler subprocess access.
The Stage 3 manual ocamlc fixture commands still apply. Minimum declared versions
remain untested. Stable lawful equality/dictionaries, immutable values, pure
terminating callbacks and coherent capability wiring remain caller premises;
recursive history/snapshots cost finite retained work/storage. No stack,
large-scale performance, arbitrary-category correctness or runtime-failure
recovery guarantee is added. Concrete relation/image/composition and reader
documentation remain Stage 5/6 work.

### Stage 5 — Deliver relation spans and composition

**Consumer:** the Chapter 4.10 application. **Dependency:** Stage 4.
**Owner:** software-development. **Status:** complete on 2026-10-10.

- [x] **5.1 Repair relation admission and endpoint maps; compose through
  pullbacks.** Treat relation pairs as values in the closed universe. Projection
  targets are the supplied endpoint objects; all pair components must belong to
  those objects under D3. Preserve witnesses in span composition and provide an
  explicit extensional relation image when a set of endpoint pairs is wanted.

**Exit evidence:** endpoint/membership tests, empty cases, duplicate-witness cases,
identity and associativity (spans up to isomorphism; images extensionally), and
the book's §4.10 example, whose image is `{(1,6),(2,6),(2,7)}`. No unsafe casts
remain anywhere in the repaired source. No display step feeds a lossy value back
into computation.

**Recorded completion evidence (2026-10-10):**
- Stage 5 preserved the prior Stage 1-4 dirty state at HEAD `10ddb0c`.
  Its fresh normal-profile baseline build and 13-group tests exited 0.
  Relevant root/ancestor/source/test/plan instructions were checked; no applicable
  AGENTS.md was found. No subagent or independent-agent review was authorized
  or performed.
- `Relations.Make(F).relation_span ~left ~right carrier` admits an outer Pair
  for every carrier member, checks each component against the corresponding
  supplied endpoint under F equality, and reports malformed input with its
  finite enumeration index. It decodes the pairs once into immutable entries,
  then uses Finite_sets' checked/frozen arrow admission for both projections.
  Their targets are the supplied left/right objects, not the relation carrier;
  empty relations retain those targets. Nested closed-universe components work.
- `Relations.identity` provides the identity-leg span. Generic
  `Relations.compose complete next previous` checks the common intermediate
  object under the supplied category equality, requests the shared Graphs
  pullback of previous.right and next.left, composes the respective external legs
  with its two projections, and returns an admitted span. It has no concrete
  finite-set views or a second pullback/matching implementation. Composition is
  explicitly next after previous, consistent with Cat and the definition on
  printed p.98; the abbreviated example-call order on p.99 is not adopted as an
  alternative convention. Reverse order with incompatible endpoints is rejected.
- `Relations.Make(F).image` enumerates the span's existing witness carrier,
  applies both frozen legs, constructs endpoint Pair values and deduplicates
  only the resulting set. It also works for generic spans with non-pair witness
  values. It does not mutate, replace or normalize the original carrier and is
  never fed back into composition internally. Duplicate paths remain distinct
  witnesses even when their endpoint image is one pair.
- The abstract span interface is retained and extended, not replaced by raw
  records or an extra relation wrapper. `ocamldep -modules` reported
  Cat/Finite_sets/Graphs/List/Universal for Relations implementation and
  Cat/Finite_sets/Graphs for its interface; there is no Limits dependency,
  new specialization facade, package or competing pullback algorithm.
  Snapshot hashes against the entry build showed only relations.ml/relations.mli
  changed among source owners. functional_test.ml and diagram_test.ml hashes
  were unchanged. Existing metadata, README and warning policy were untouched.
- `tests/relation_test.ml` adds seven groups; its Dune stanza selects its module.
  Final fresh normal-profile `dune build` and `dune runtest --force` exited 0,
  with all 20 groups in three executables passing without compiler warnings or
  warning overrides. The cache/config were disabled and outputs were staged
  outside the source tree. An initial unused test variable was corrected locally,
  not by suppressing the development warning.
- New suite output: 47 exhaustive finite relation admissions, 803 composable
  relation pairs, 15,625 span associativity triples, and 15,771 checked span
  isomorphisms. Admissions/pair compositions range over all four subsets of a
  two-atom endpoint universe and every subset of their cartesian products.
  A separate direct existential-membership oracle checks every composition
  image; direct compatible-witness enumeration checks its carrier cardinality.
- Associativity enumerates all triples of 25 endospans with fixed two-element
  endpoints and witness carriers drawn from the four subsets of a distinct
  two-element witness set. Both parenthesizations have the independently counted
  three-witness path multiplicity, equal images and an explicitly constructed
  span isomorphism. Tests match finite endpoint fibres one-to-one, admit forward/
  inverse arrows, then check both leg equations and both inverse equations.
  Equal images alone are not treated as a span isomorphism. Final witness
  carriers in this triple envelope have at most eight members.
- Both identity directions are checked by explicit span isomorphisms on all
  47 relation admissions and 25 endospans, including empty cases. Additional
  cases check nested pairs/tags, distinct duplicate-image witnesses, unchanged
  input callback counts, reordered common sources/intermediate objects and
  custom absolute-value equality. Nonpair/outside-left/outside-right inputs and
  incompatible intermediate endpoints are rejected.
- Supplied pullback semantic errors and thrown exception identities propagate
  unchanged. Targeted injections also check category object-equality, category
  identity and finite-pair membership equality exception propagation. A mismatched
  intermediate object fails before invoking a throwing pullback capability.
  Fault-injection fixtures do not certify lawful behavior of those deliberately
  throwing dictionaries.
- An independently specified terminal category (one object/one arrow) supplies
  a lawful complete-category capability and exercises generic span composition
  without a FinSet object/arrow type. General category/capability laws and coherent
  dictionary wiring remain premises, not facts proved by that single fixture.
- The supplied PDF SHA-256 was reverified unchanged. A pypdf text-layer extraction
  revisited printed pp.97-100 (PDF pp.110-113), locating the pullback definition,
  endpoint projection conversion and duplicate-witness explanation. The book's
  example has four witnesses, the image `{(1,6),(2,6),(2,7)}`, and two distinct
  witnesses in the (2,6) fibre. All were checked; the result was also compared
  by checked isomorphism with an explicit four-witness span. No raw nested-pair
  spelling, tag depth or unperformed visual/transcription check is claimed.
- Manual compiler fixtures remain separate from Dune tests. The positive public
  namespace consumer now uses relation admission, identity, composition and image
  and compiled without warnings (exit 0). All five negatives exited 2 with their
  expected diagnostics: mixed equality instances, raw arrow fields, private
  partition, raw graph fields and the new raw span-field fixture.
- Three temporary mutations compiled and triggered the intended semantic failures:
  changing a projection's target to the relation carrier; replacing supplied
  intermediate-object equality with structural equality; reversing image pair
  orientation. Each source was restored byte-for-byte in a finally block before
  fresh final checks. A command initially yielded before mutation completion;
  source restoration was verified by hash and the check was rerun through process
  completion before counting its result. This is mutation sensitivity, not TDD.
- Source residue checks found no `Obj.`/unsafe operations or old lossy/direct
  composition helpers; `git diff --check` passed. Self-conformance found no
  blocker. Disposable compiler/mutation staging is removed after evidence
  capture. No installation, publication, commit, README edit or Stage 6 execution
  occurred.

**Construction argument:** for spans r:A<-R->B and s:B<-S->C, their FinSet
pullback carrier corresponds via its two projections to compatible witness
pairs (x,y) with r.right(x) equal to s.left(y). Its projections followed by the external legs give a span
from A to C. Its image contains exactly the endpoint pairs admitting such a
witness; taking a set image deduplicates pairs, not witnesses. Pulling back an
identity yields a span isomorphic to the original. Each parenthesization of
three-span composition represents compatible triples of witnesses, and pullback
universality induces the comparison isomorphism respecting both external legs.
These explanations are conditional on lawful supplied capabilities; bounded
runtime isomorphisms/oracles are not a general machine-checked proof.

**Reproduction and boundaries:** use the existing process-local toolchain paths
from Stage 2 and a fresh directory B:
`dune build --build-dir B --cache=disabled --no-config`, followed by
`dune runtest --build-dir B --cache=disabled --no-config --force`.
OCaml 5.2.1/Dune 3.24.2 were tested with approved compiler subprocess access,
without installation/host setting changes. The manual ocamlc command in Stage 3
now also tests raw_span. Declared minimum versions remain untested. Immutable
atoms/objects, stable lawful equality/dictionaries and pure terminating callbacks
remain caller premises; larger inputs, stack/storage cost and arbitrary-category
correctness are not certified. Reader-facing documentation and the final
integrated claim remain Stage 6 work.

### Stage 6 — Verify the integrated claim and reconcile reader documentation

**Consumer:** project readers and the final implementation reviewer.
**Dependency:** Stage 5. **Owners:** software-development for verification;
software-documentation for reader-facing explanations. **Status:** complete
under the final evidence below (2026-10-10).

- [x] **6.1 Verify the complete promised slice.** Run fresh normal-profile
  `dune build` and `dune runtest` in the existing switch. Combine fixed regressions,
  book examples, finite enumerations, and a derivation explanation for generic
  universality. Verify the public namespace from a separate library consumer
  using local build/staging only, not host installation or registry publication.
- [x] **6.2 Reconcile README and affected source explanations with verified
  behavior.** Depends on 6.1. Attribute the correct book; document actual
  dependency/visibility boundaries, build commands, admission/failure policy,
  mathematical assumptions, covered/deferred scope, and migration. Remove the
  harmless-cast claim and the false tuple-parsing rationale. Update plan status
  only from the delivered evidence.

**Exit evidence:** a new reader can build and run the law suite from documented
commands; examples type-check against the public surface; documentation distinguishes
implemented contracts from test bounds and future work. Record tested tool versions
and any untested minimum-version boundary. No claim of formal proof, unrestricted
total callbacks, or production readiness.

## Validation envelope, effects, and recovery

- Finite enumeration is evidence, not a workload limit: use explicit small
  fixtures (base sets of at most two elements; diagrams up to three nodes and
  two edges). For uniqueness, enumerate maps in selected cases with mediator
  domain/codomain sizes at most four; larger book examples check specified
  equations and the construction argument. Record actual enumeration coverage.
- Exercise supported malformed-input/failure cases under D3: mismatched
  endpoints, nonparallel pairs, out-of-codomain images, invalid graph endpoints,
  incompatible universal-map inputs, and application outside a declared source.
  Test precondition boundaries according to the settled policy, not a stronger
  invented promise. Fixtures/callbacks must terminate and be pure.
- Persistent effect of the implementation is source/tests/manifests and later
  reader documentation; the library itself needs no I/O or global mutable state.
  Per-operation union-find scratch must not escape its owner. Concurrency,
  cancellation, resource budgets, and large-scale performance are not promised.
- **Impact classification:** reader documentation changes are planned; existing
  build/test configuration changes are planned; new CI/automation, releases,
  publication, and host mutation are excluded. Missing tools require separate
  environment authority rather than hidden setup.
- Stage boundaries are candidate delivery checkpoints only. Build-harness repair
  and safe primitive capabilities can remain useful if later work stops; the
  actual diff and dependency closure determine review shape.
- On failure, preserve baseline evidence and revert only the owning delivered
  change with separate authority. Do not reset unrelated edits or restore unsafe
  APIs as the accepted target. Retest dependent outcomes after any rollback.

## Reopen conditions and plan delta

This replaces the stale "scaffold plus build verification" plan: unsafe casts
are not accepted; absent generic algorithms are planned outcomes rather than
current facts; equality/endpoints/universality and compatibility precede their
implementation; old path/tool-absence and estimated-effort claims are removed.

Reopen only the affected decision if type integration fails, a supported caller
appears, equality/admission semantics conflict with an example, a dependency cycle
is evidenced, minimum-version compatibility fails, or the user changes scope.
Record changed evidence, affected premise and downstream stages, new status,
unchanged invariants, and renewed checks here. No global redesign follows from
an unrelated warning.

## Plan audit and first ready work

**Stage 1 self-audit, 2026-10-10, baseline `10ddb0c`:** source paths, owners, callers,
manifests and instructions were freshly rechecked. The plan is tracked and is
the sole intended mutation. No independent-agent review was requested or performed.

Corrections at their owning boundaries:
- **Previous blockers closed:** D2 equality/closure/quotient observability,
  D3 admission and failure semantics, and D5 generic ownership/package cutover
  now have selected contracts and explicit tradeoffs. The bounded sealed witness
  supports feasibility; production readiness is not inferred from it.
- **Topology:** Graphs→Universal→Cat is acyclic; generic algorithms cannot inspect
  concrete FinSet values. Private partition work has one Colimits owner.
  A new specialization consumes the existing generic owner, not another algorithm.
- **Adversarial input changes:** reordered objects/bases use supplied equality;
  a changed base fails admission. Recursive subdiagram factors require restricted
  bases. Throwing callbacks propagate; divergent callbacks are outside the
  terminating premise. Different same-payload equality instances cannot mix.
- **Compatibility:** only local cutover is settled. A supported external consumer
  reopens migration, not mathematical closure. Wrapper imports and metadata repair
  are assigned to Stage 2; no shim or release promise is invented.
- **Warnings with disposition:** finite snapshots retain source-sized data and
  perform upfront checks (accepted for the learning scope); equality/category laws
  remain trusted stable premises (bounded law tests, no proof claim); minimum
  versions remain untested (retain targets and report during verification).
- **Scope:** Stage 1 is complete; all production tasks remain unchecked. Stage 2
  has no design blocker, while Stages 3-6 depend on predecessor delivery.
  No implementation, README, build metadata, installation, commit or publication
  is authorized by this checkpoint.

**Stage 2 follow-up audit, 2026-10-10:** rechecked the current diff and commands.
Only build/package metadata, wrapper import and this tracked plan changed.
D5's single-package naming premise was corrected from parser evidence and
verified by fresh package build/test discovery. Normal warning policy, source
behavior and minimum-version targets remain unchanged. Existing warnings have
explicit Stage 3 owners; reader documentation remains assigned to Stage 6.
No plan-level blocker remains for 3.1, but its execution is not authorized here.

**Stage 3 follow-up audit, 2026-10-10:** actual owners, signatures, callers and
dependency directions were rechecked against D2/D3/D5. Generic category equality
has no structural fallback; FinSet/term state and Graphs/span admission are
enforced by abstract interfaces; partition state has one private owner. The
changed claims have law/error/static/mutation evidence. A nested test fixture
initially attempted the wrong summand injection and was rejected by admission;
it was corrected to the actual admitted injection, not by weakening the library.

The source slice has no conformance blocker. Warnings are discharged by normal
profile checks, while equality/category laws, callback termination, workload cost
and untested minimum versions retain their explicit premises/bounds. Reader docs,
generic algorithms and relation semantics are not concealed as complete outcomes.
The direct primitive pushout derivation may be integrated with Stage 4's generic
diagram specialization without adding a second authoritative algorithm.

**Stage 4 follow-up audit, 2026-10-10:** source/interface dependencies and the
actual implementation flow were rechecked against D3/D4/D5. Generic algorithms
remain in Graphs; supplied primitives and Cat own mathematical capability and
failure behavior. Restrictions preserve admitted invariants and use the actual
subdiagram base, while final mediators restore the full base. Duality reverses
both underlying shape and universal-arrow direction. Concrete specializations
share that generic owner; the direct concrete pushout algorithm is gone.

One test initially wired a FinSet limit capability into conjugation requiring
the opposite-category capability. Admission rejected the incoherent fixture.
It was corrected by supplying the dualized capability and the interface comment
now makes that premise explicit; no admission rule or architectural decision was
weakened. Temporary positive-fixture partial-application warnings were removed
by naming the capability values rather than discarding partial applications.

No conformance/plan blocker remains. Bounded law/static/mutation evidence supports
this slice, not formal correctness or independently reviewed reliability.
Workload/stack cost, lawful dictionary/equality/callback premises and untested
minimum versions retain their bounds. README remains stale until Stage 6.
Stage 5 will consume the checked complete-category/pullback capability without
choosing a second pullback algorithm.

**Stage 5 follow-up audit, 2026-10-10:** the actual relation flow and interface
were checked against D3/D4/D5. Span source/leg admission remains abstract; identity
and composition retain witnesses. Generic composition delegates to the existing
checked pullback owner and never examines a concrete finite-set representation.
Concrete pair admission preserves declared endpoints and image is a separate
deduplicating projection. No competing pullback algorithm, validator authority,
mutable owner or relay-only facade was introduced.

No conformance/plan blocker remains. Relation oracle, witness-count, finite
isomorphism, negative-input, exception, static and mutation evidence support
this slice. Independent-agent review was not authorized/performed. Stable lawful
dictionary/equality and callback/immutability premises, resource cost and untested
minimum versions retain their boundaries. The implementation checkpoint is
complete, but the documented reader experience remains unverified until Stage 6.

**Stage 6 final audit and evidence, 2026-10-10:** the latest user acceptance
authorized the final verification/documentation checkpoint, not publication.
Historical stage-specific authorization/status statements above describe their
then-current checkpoints; the current authority/status is at the top.

The documentation contract is a local public README for learners/developers
building the source and using the current wrapped OCaml API. Source/interfaces,
tests and manifests own current behavior; Rydeheard/Burstall own the mathematical
specification. No external docs publication or toolchain setup was performed.
The only Stage 6 reader-artifact edits are README and the synchronized
dune-project/opam descriptions: the latter formerly advertised a general
natural-transformation implementation absent from source. Removing that claim
is documentation reconciliation, not a new package/API policy. Existing source
explanations already match the settled ownership and need no additional edits.

The README now gives correct attribution and printed-page references,
normal-profile commands, wrapper/library identity, a complete public example,
admitted finite values/maps, equality and lawful-capability premises, exception
vs result scope (including retained Core conventions), generic construction
argument, dependencies/visibility, witness/image separation, migration and
explicit test/deferred-work boundaries. The false tuple parsing explanation,
harmless Obj.magic claim, exposed raw types and lossy normalization guidance
are removed. API cutover has no compatibility shim or external release promise.

Final evidence was closed at 2026-10-10 01:42:18 UTC,
using HEAD 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c plus the local
working changes, OCaml 5.2.1 and Dune 3.24.2 on Windows in the existing switch.
All edits remain uncommitted; no Git staging/commit operation was performed. The disposable root was:
`F:\Stratum\TEMP\computational-category-stage6-8103639e-f46d-4db6-82df-ccc759cef9ab`.
The existing Cygwin runtime required approved unsandboxed shared-memory access;
no compiler/runtime was installed or reconfigured.

**Fresh results after the final relevant README/metadata edit:**
- Normal `dune build --build-dir <scratch>/build --cache=disabled --no-config`:
  exit 0, no compiler warning/override. Build profile remains development.
- `dune runtest` with the same options and `--force`: exit 0; all 20 groups
  in three executables. Counts: foundation 6,146 map fixtures / 973 triples /
  1,020 uniqueness cases; diagrams 461 / 5,350 mediators / 5,529 uniqueness /
  351 larger equation-only cases, 39 Boolean diagrams / 100 mediators /
  114 pullbacks; relations 47 admissions / 803 pairs / 15,625 associativity
  triples / 15,771 checked isomorphisms. Book fixtures passed.
- Public positive compiler fixture: exit 0. All five independent negative
  fixtures: exit 2 plus their specific expected diagnostic, not arbitrary failure.
- The sole README OCaml block was extracted unchanged, compiled/linked with
  the local computational_category.cma and unix.cma from a separate temporary
  consumer directory, and run with ocamlrun: exit 0, exact output
  `witnesses=4, image pairs=3`. No installation or unwrapped imports.
- `ocamldep -modules` and `ocamlobjinfo`: exit 0. Graphs implementation
  imports Cat, List and Universal only; Graphs interface imports Cat and
  Universal. Universal imports Cat. The archive exposes Computational_category
  and its wrapped units. Generic ownership is not inferred merely from passing
  functional tests.
- README fence/link/section/suite inspection and synchronized-description
  checks passed. Exactly two fenced blocks (shell and complete OCaml example);
  linked source interfaces and all named suites exist. No pixel-render or
  full generated API-reference claim is made.
- `git -c core.safecrlf=false diff --check`: exit 0.
  Source, interfaces, tests and type fixtures were SHA256-identical to Stage 6
  entry, so prior focused mutations remain evidence on this same source; no
  mutation or implementation edit was made in Stage 6.

Two probe corrections did not change product behavior: the first separate
consumer link emitted OCaml's deprecated automatic Unix include alert; the final
command explicitly added `-I +unix` and reran cleanly, without suppression.
An ad hoc README fence check first assumed three blocks although the document
contains two; its expected count was corrected from six delimiters to four and
the inspection passed. Neither initial observation was called final success.

**Retained verifier source and inputs:** the following PowerShell script is the
exact final executed verifier (scratch existed before execution). For a rerun,
create a fresh task-scoped GUID directory under GetTempPath and substitute its
path; run from this repository root with the stated existing toolchain.
Type fixture inputs remain in tests/type_contracts; README owns the sample.
All compiler outputs target scratch.

```powershell
$ErrorActionPreference='Stop'
$env:PATH='C:\Users\nostalgia\AppData\Local\opam\default\bin;C:\Users\nostalgia\AppData\Local\opam\.cygwin\root\usr\x86_64-w64-mingw32\sys-root\mingw\bin;C:\Users\nostalgia\AppData\Local\opam\.cygwin\root\bin;'+$env:PATH; $env:OPAM_SWITCH_PREFIX='C:\Users\nostalgia\AppData\Local\opam\default';
$root='E:\Proj\course\computational-category'
$scratch='F:\Stratum\TEMP\computational-category-stage6-8103639e-f46d-4db6-82df-ccc759cef9ab'
$build=Join-Path $scratch 'build'
dune build --build-dir $build --cache=disabled --no-config
if($LASTEXITCODE -ne 0){throw 'Build failed'}
dune runtest --build-dir $build --cache=disabled --no-config --force
if($LASTEXITCODE -ne 0){throw 'Tests failed'}
$include=Join-Path $build 'default\src\.computational_category.objs\byte'
$lib=Join-Path $build 'default\src\computational_category.cma'
ocamlc -I $include -c -impl (Join-Path $root 'tests\type_contracts\positive.ml.txt') -o (Join-Path $scratch 'positive_delivery.cmo')
if($LASTEXITCODE -ne 0){throw 'Positive type fixture failed'}
$negative=@{
 mixed_equality='Make\(Magnitude\)\.set'
 raw_arrow='Unbound record field.*entries'
 partition='Unbound value.*C.partition'
 raw_graph='Unbound record field.*nodes'
 raw_span='Unbound record field.*sp_arrow1'
}
foreach($name in ($negative.Keys | Sort-Object)){
 $log=Join-Path $scratch ($name+'.log')
 $cmd='ocamlc'
 & $cmd -I $include -c -impl (Join-Path $root ('tests\type_contracts\'+$name+'.ml.txt')) -o (Join-Path $scratch ($name+'_negative.cmo')) 2> $log
 $code=$LASTEXITCODE
 $diagnostic=Get-Content -LiteralPath $log -Raw
 if($code -ne 2 -or $diagnostic -notmatch $negative[$name]){throw ($name+': unexpected exit or diagnostic: '+$code+' '+$diagnostic)}
 Write-Output ('EXPECTED REJECTION '+$name+' exit='+$code)
}
$readme=Get-Content -LiteralPath (Join-Path $root 'README.md') -Raw
$blocks=[regex]::Matches($readme,'(?s)```ocaml\r?\n(.*?)\r?\n```')
if($blocks.Count -ne 1){throw 'Expected exactly one complete OCaml example'}
$example=Join-Path $scratch 'readme_example.ml'
$blocks[0].Groups[1].Value | Set-Content -LiteralPath $example -Encoding utf8 -NoNewline
$exe=Join-Path $scratch 'readme_example.byte'
Push-Location $scratch
try{
 ocamlc -I $include -I +unix unix.cma $lib $example -o $exe
 if($LASTEXITCODE -ne 0){throw 'Public README example failed to compile/link'}
 $output=ocamlrun $exe
 if($LASTEXITCODE -ne 0 -or $output -ne 'witnesses=4, image pairs=3'){throw ('README output mismatch: '+$output)}
 Write-Output ('PUBLIC README CONSUMER '+$output)
}finally{Pop-Location}
Write-Output 'STAGE6 VERIFICATION COMPLETE'
```

Final reader-artifact SHA256:
```text
E:\Proj\course\computational-category\README.md 40BA256D8465A5292F7DBF7A5DA7345F418FEF8646D0A0D9FAEA858E88ACCA0A
E:\Proj\course\computational-category\computational_category.opam 37A0F13EA0CAE025056EFC4A20B4191785CF895D75B04EBEC53413DF0D534F1B
E:\Proj\course\computational-category\dune-project 7F53A9ACC0B529F4B3FAEFF6EDF628762BB9A3C42B8AE6E4CB81658F1753662B
```

Stage 6 input identities (unchanged before/after verification):
```text
E:\Proj\course\computational-category\src\cat.ml 6E8C3D54C67DC969FB7FCE800C8B8A7853103EE7E837CD84D6B7DEA4CD6A6B8A
E:\Proj\course\computational-category\src\colimits.ml A20043C630AE63C787FF8C4FCFA7384F6987E9BBC03DBCAD8A855F0A37DC5D54
E:\Proj\course\computational-category\src\core.ml 8EB4283903E4C37A2BB281B82AFF9D70088E6FDB30B85967A9E2D4781DB72C83
E:\Proj\course\computational-category\src\finite_sets.ml CCC07488D8837FEBD785471988925379272DDCB98A80532D14E4FD3AE4912E07
E:\Proj\course\computational-category\src\functors.ml 64663AC436D1400B43F95F6A3A68B6FF0B0AC4B9AC1C07F9D04F3E4812DF71E9
E:\Proj\course\computational-category\src\graphs.ml 44463662A8DDA92CA832BAE409AA00E7945611F8474618BA5A5AAB17B099C1A3
E:\Proj\course\computational-category\src\limits.ml A766E182ACE272E0C10AE73E8609C8C54F21170A74072C202E9B4F350F0999E9
E:\Proj\course\computational-category\src\relations.ml C61D4D8F529A3AB1D79566AC075A8A757DB1BE6482358CB52150AF98C411CB6F
E:\Proj\course\computational-category\src\term_category.ml 673AEB81BB606E7A92B25DF8772CF99C1283DC3E6772CF1D740B3E5C99189CB8
E:\Proj\course\computational-category\src\universal.ml DE9F5A33C791FA0AF4B6FD2B9BF8CA67202E008092FF5BCA87823F7A18855118
E:\Proj\course\computational-category\src\graphs.mli ACD314C36EDF548F9463BB20096E56162157D2887A6022C06D971DEBBDC75897
E:\Proj\course\computational-category\src\relations.mli 31361B37C45CF9180ED138B49DA48509ED032C197AE7D8E804ED6B3E492A30A5
E:\Proj\course\computational-category\tests\diagram_test.ml 0476700C65428EF0C4F5F08177AF8D866C5EFEC8FA76AAFE38F5EDE6FB88FB0B
E:\Proj\course\computational-category\tests\functional_test.ml 1F953174AEE9DF4A99466A46C40EB1744B8B7D5BF18B24E37EFF224B5C8F03A1
E:\Proj\course\computational-category\tests\relation_test.ml 5A6472A70601BDBB3A4B045388B8ED081B946615685772C6948D736A006DEEE2
E:\Proj\course\computational-category\tests\type_contracts\mixed_equality.ml.txt D34CCDDE0609C78B5E2B2DC4802778183C96F06ED34E3008A4F88323E191EA96
E:\Proj\course\computational-category\tests\type_contracts\partition.ml.txt 8C9B66295875F75561F5D383FFFAA72FB8FC8346F3D6AC353C520AD2ABCF5CB0
E:\Proj\course\computational-category\tests\type_contracts\positive.ml.txt A199558B6467ED49D78E77C79FAB5632EE3A375B0A711DFB67EDE09CF3E24818
E:\Proj\course\computational-category\tests\type_contracts\raw_arrow.ml.txt 6FE5498E9B2A296D0F44B9E143A6B37038EDE3F1FA3A75C30215CE895FA97CF5
E:\Proj\course\computational-category\tests\type_contracts\raw_graph.ml.txt 30246035E2ACEFD303A9AA38EB28B4EAED94B9E35358E9E20D77EA2D7E22AEFE
E:\Proj\course\computational-category\tests\type_contracts\raw_span.ml.txt D6DB379ED65375CADECF5227B16E308805C6DFCC10F26D2F4ED1B133738A6447
```

**Conformance and plan-audit disposition:** no blocker remains for the accepted
learning-project contract. The actual dependency graph, sealed value/admission
boundaries, single generic finite-construction owner, private partition lifetime,
checked composition order and separate witness/image semantics agree with D1-D5.
The README migration matches the real local API diff, not an imagined release.
Removing the description drift was the smallest reader-impact correction;
no new abstraction, validator, algorithm, handler, package split, ignore change
or compatibility residue was introduced.

Changing a supplied law/immutability premise, increasing workload, asking for
an external release, or requiring the untested minimum versions reopens only
the corresponding evidence/policy owner; “all stages complete” does not authorize
those operations. Existing resource/stack/cost uncertainty is accepted because
no production or performance bound was promised. Independent-agent review was
not authorized/performed; this conformance review is self-review, not independent
reliability evidence. Fresh tests support the fixed small enumerations and book
fixtures, not formal correctness over arbitrary lawful categories.

**Completion:** all six planned stages and their local exit gates are delivered.
No first-ready task remains. Installation, publication, commits, broader chapters,
formal proof and performance certification remain excluded. The Stage 6 GUID temporary
root was removed after resolving its absolute path, checking the GetTempPath
prefix and exact basename, and using native Remove-Item -LiteralPath. Absence
was observed afterward. The pre-existing root _build remains untouched; no
root .install file or separate consumer output remains. Final Git status retains
only the cumulative authorized working changes; HEAD is unchanged. The retained
plan's trailing whitespace/EOF formatting was repaired and the final diff check
passed. No independent review or new authorization is inferred from cleanup.

## Chapter 5 extension — authorized 2026-10-10

The user now requested Chapter 5 including exercises. This supersedes only
the former Chapter 5 exclusion: Stages 1-6 are retained as historical completed
Chapter 2-4 work, not reopened. Source SHA256 is unchanged from their final
checkpoint at entry. HEAD remains 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c
with the cumulative uncommitted changes; no applicable AGENTS.md was found.
End-to-end local implementation, tests, worked solutions, README and plan updates
are authorized; no stage-by-stage confirmation is required by this request.
Installation, network upload, commits and publication remain outside authority.

### Source and exercised scope

The unchanged supplied PDF has SHA256
17f3ba03c0a496a0da3cb8fc8845c349d6d05ff342eeb7d40341e1238d3f94c8.
Chapter 5 is printed pp.103-126 / one-based PDF pp.116-139.
All pages were inspected through pypdf 6.10.0 text extraction. The graph example
and difficult exercise diagrams on printed 110,124-126 were additionally
rendered locally with pypdfium2 5.13.0 and inspected. Appendix D has only
Chapter 2 programming answers; it supplies no Chapter 5 solution oracle.
No supplied PDF is edited or uploaded.

Main constructions: comma categories and inherited colimits (Theorem 3),
finite graphs, natural transformations and functor categories, pointwise
colimits (Theorem 4), canonical duality transports, and abstract fixed-shape
colimit/free-object structures. Every exercise 1-12 gets a located worked
solution; exercises requesting programs also get a reusable checked
implementation or an explicitly scoped implementation plus the general
mathematical construction. Proof exercises are not replaced by finite tests.

### Settled extension decisions

- **C5.1 Domain/admission:** retain D1-D5, typed expected failures, propagated
  callback/runtime exceptions, next-after-previous composition, lawful coherent
  dictionaries and immutable values. Add comma objects/arrows with explicit
  endpoints and commuting-square admission; never compare callback identity.
  Shape graphs (existing Graphs) are not objects of FinGraph.
- **C5.2 Finite functor domain:** naturality and extensional functor equality
  require a complete finite domain enumeration. Admit a finite category
  enumeration, freeze maps/components once, verify endpoints, identities,
  composition/naturality over that domain. Empty domains and custom equality
  are supported. Arbitrary infinite callback equality is undecidable and is
  not hidden behind physical/structural closure equality. General mathematics
  remains in worked derivations; executable functor categories explicitly
  restrict the source to the admitted finite enumeration.
- **C5.3 Reuse/owners:** Graphs owns fixed-shape diagram arrows and variable-base
  cone/cocone arrows, since these share its existing admitted shape/base laws.
  Functors owns mapping diagrams/cones, functor composition, preservation and
  isomorphism transport. New functional modules own comma categories,
  finite-domain functor categories, elementary category constructions,
  graph objects/applications and uniform-fiber indexed categories; they remain
  within the existing wrapped library. Universal keeps its existing lower-level
  dependency; do not introduce a Graphs/Universal/Functors cycle.
  No chapter package, relay facade, second union-find or generic finite
  colimit algorithm is justified. Subcomponent colimit evidence may accompany
  comma inheritance for edge-labelled graph reuse, not be recomputed by a
  competing quotient implementation.
- **C5.4 Limits/duality:** inherited comma limits require the right functor
  continuous, not the left cocontinuous. Transport through the swap
  dual(L,R) <-> (dual R,dual L), then use the existing dual-colimit adapter.
  Finite functor limits use the canonical simultaneous domain/codomain dual.
  X(a)=a*a preserves limits by pairing two mediators; it does not generally
  preserve coproducts. No generic preservation is inferred from a function type.
- **C5.5 Advanced exercises:** graph grammar programming chooses the explicit
  elementary double-pushout case with injective rule legs and matches and a
  dangling-edge refusal. It is not automatic grammar matching or all
  noninjective rewriting. Edge-labelled finite graphs model only the structural
  NFA graph, not initial/final states or epsilon/regular-expression compilation.
  Explain the additional language-recognition structure rather than claim a
  colimit alone recognizes union/concatenation/star.
  Indexed categories use one OCaml object/arrow type across fibers and supplied
  strict lawful reindexing; admission checks the selected fiber. The general
  heterogeneous-fiber propositions are proved in prose, not encoded using
  Obj.magic or a new dependent-type framework.
- **C5.6 Abstract scope:** provide a real fixed-shape free-object adapter used
  against Graphs, plus the 2-functor/adjunction laws and indexed-shape
  interpretation in exposition. This is not an executable universe-polymorphic
  model of all Cat. Keep Chapter 6 general adjunction development excluded;
  an explicit right-adjoint transposition capability is sufficient for the
  indexed-category limit construction.
- **C5.7 Compatibility/cost:** additive APIs leave existing consumers valid.
  No new Cat.error variant is necessary unless an existing semantic alternative
  cannot express the new failures. Finite-domain admission can require pair/
  triple enumeration; no scale/stack guarantee or timeout is promised.
  Stateful/nonterminating callbacks and mutation of admitted values remain
  outside the lawful input contract. No external or irreversible effect is
  introduced by mathematical operations.

Rejected alternatives: raw callback functor objects would make equality,
naturality and category composition uncheckable; casts/dynamic universal
payloads erase fiber ownership; per-exercise custom quotient algorithms duplicate
the existing owner; a full higher-category/dependent-type framework exceeds
this learning project's represented operations. Explicit finite domains and
uniform fibers preserve the available checked contract while the general proofs
retain the mathematical scope. Reopen only the affected decision if a supported
consumer actually requires infinite domain equality, heterogeneous fibers,
noninjective rewriting, or production resource bounds.

### Stage 7 — Constructed categories and inherited graph universals
Consumer: graph/category users. Dependency: completed Stage 6.
- [x] 7.1 Implement admitted diagram morphisms, functor mapping/transport,
  comma category projections, inherited colimits and dual limits; products,
  terminal/constant/slice and twisted-arrow constructions.
- [x] 7.2 Implement finite graphs as comma objects, their products/limits/
  colimits, and the book graph pushout with endpoint-preserving isomorphism
  evidence. Reuse preservation X and underlying component universal maps.
Exit: category laws, negative squares/endpoints, independent dictionaries,
universal equations/selected uniqueness, duality directions, and old suite pass.

### Stage 8 — Functor, abstract and advanced exercise capabilities
Consumer: Chapter 5 learners and application callers. Dependency: Stage 7.
- [x] 8.1 Implement finite-domain functors/natural transformations, both
  compositions, pointwise colimits and dual limits, chosen limit arrows, and
  fixed-shape abstract free-object adapters.
- [x] 8.2 Implement coslice coproducts by pushout, edge-labelled graphs,
  elementary checked DPO rewrites and uniform-fiber Grothendieck operations/
  inherited colimits and right-adjoint limits.
Exit: laws, pointwise universal equations and bounded unique mediators,
interchange/duality, malformed/frozen callback cases, gluing/dangling refusal,
indexed identity/composition and both inherited universal constructions.

### Stage 9 — Exercise solutions and integrated evidence
Consumer: readers/final reviewer. Dependency: Stage 8.
- [x] 9.1 Write a public Chapter 5 guide/solutions covering all twelve exercises,
  including the canonical-isomorphism conditions and proofs of Propositions 7
  and 8. Explain Theorems 3/4 and abstract cocone structures, assumptions and
  executable restrictions separately; update README current scope/navigation.
- [x] 9.2 Fresh normal Dune build/runtest and public consumer/static checks;
  selected mutation-sensitive law tests; final actual-diff conformance and plan
  audit. Preserve earlier work and clean only owned GUID scratch.
Exit: every exercise accounted for by source locator, solution and appropriate
proof/program evidence; no omitted star exercise silently called complete,
no formal-proof/unbounded/heterogeneous/infinite-domain certification.

### Extension plan audit

Current evidence supports these semantic owners and additive surfaces. Removing
the new diagram-morphism boundary would lose variable-base cone/free-object
semantics; merging graph objects with diagram shapes would confuse different
mathematical categories. Fixed finite enumeration is necessary for checked
extensional equality, not a test-only design constraint. Changing the right
functor preservation to left preservation changes only comma-limit readiness.
The twelve exercise outcomes share one repository/consumer and stay in this
single tracked plan; the reader guide has a distinct educational lifecycle.
No blocker remains for the bounded implementations. General higher-universe,
heterogeneous-fiber and arbitrary rewrite claims remain explicitly excluded.
Independent-agent review was not authorized; this is self-audit.
Stages 7-9 are complete within their exits; no first-ready task remains.


## Chapter 5 delivery — 2026-10-10 (Asia/Shanghai)

### Achieved consequence and stages

Stages 7, 8 and 9 are complete within C5.1-C5.7 and their stated exits. The
local wrapped package now admits the Chapter 5 category constructions and
supplies inherited finite universal maps. The public guide docs/chapter5.md
contains located worked solutions for all twelve exercises, including the
star exercises and general proofs of Propositions 7 and 8. This does not
mean an unrestricted graph-grammar implementation or all of Cat was encoded.

- Stage 7: Graphs owns diagram maps and variable-base cone/cocone maps;
  Functors owns mapping, preservation and inverse transport. Comma_categories
  owns squares and inherited universals; Category_constructions/Twisted_arrows
  own elementary categories. Finite_graphs separates graph objects from
  diagram shapes and reuses comma inheritance. The printed book graph pushout
  is checked against its incidence pattern by explicit inverse graph arrows.

- Stage 8: Functor_categories admits frozen finite-domain functors and natural
  transformations with vertical/horizontal compositions and cached pointwise
  universals. Limits use simultaneous opposites. Abstract_limits implements
  actual nonidentity-base free/cofree factorization, not just a record label.
  Coslice coproducts use pushouts. Labelled graphs reuse actual edge-colimit
  evidence. Elementary DPO rewriting checks injectivity/dangling conditions.
  Indexed_categories admits selected fibers and uses preservation or genuine
  right-adjoint transposition for inherited colimits/limits.

- Stage 9: README navigation, current scope, manual fixture inventory and
  manifests reflect the additive surfaces. Guide solutions 1-12, source
  interfaces, tests, examples and actual dependency topology were inspected.
  Fresh delivery checks and selected semantic counterfactuals passed below.

### Actual-diff conformance and limits

Self-review found no remaining blocker against the settled extension decisions.
New comma, functor, natural, twisted and indexed representations are abstract;
expected failures use existing Cat.error and callback exceptions propagate.
No casts, universal payload serialization, closure equality, new generic
quotient/limit algorithm, module cycle, per-chapter package, installation or
external publication was introduced. ocamldep confirms Graphs -> Cat/Universal,
Functors -> Graphs/Finite_sets/Cat; new owners depend on these, not vice versa.
ocamlobjinfo confirms all modules in the Computational_category wrapper.

Accepted boundaries: complete finite source enumeration is a caller premise
(closure is checked, not discovery of every ambient arrow); coherent lawful
dictionaries, strict indexing, preservation and natural inverse adjunction
bijections remain supplied capabilities. Higher/universe and heterogeneous
claims are explained mathematically, not erased by casts. NFA programs model
structural labelled graphs, not state designations/regex semantics. DPO code
requires injective rule legs and match, with dangling refusal. No scale, stack,
termination, all-platform or machine-checked-proof certification is made.
Normal development profile is used without warning suppression; OCaml/Dune
minimum versions remain unverified. No independent-agent review was authorized.

### Final execution evidence

Host: Windows, PowerShell login disabled, existing Opam/Cygwin compiler;
OCaml 5.2.1, Dune 3.24.2. Working tree based on
10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c; all earlier Chapter 2-4 work
remains uncommitted. This turn changed Graphs/Functors additively plus
Chapter 5 modules, tests, reader documentation and manifest descriptions.
Earlier source/tests were not reset. The hash table below binds final files.

Owned scratch root used for all new compiler outputs and temporary probes:
`F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca`.
Existing compiler commands required sandbox escalation for Cygwin shared
memory. No environment installation or host setup was performed.

Canonical final commands, run after the last source/test/document edits:
```powershell
dune build --build-dir 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca\final-build' --cache=disabled --no-config
dune runtest --build-dir 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca\final-build' --cache=disabled --no-config --force
& 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca\verify-consumers.ps1' -Root 'E:\Proj\course\computational-category' -Scratch 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca' -BuildDirectory 'final-build'
```
Fresh directory build and entire combined command exited 0. All six test
executables succeeded, with 33 PASS groups (20 retained and 13 Chapter 5).

| Evidence | Observed result |
| --- | --- |
| Foundation | 6,146 map fixtures; 973 associativity triples; 1,020 unique mediators |
| Diagrams | 461 FinSet diagrams; 5,350 mediator cases; 5,529 uniqueness cases; 351 larger equation-only cases; 39 Boolean diagrams/100 Boolean mediators; 114 pullbacks |
| Relations | 47 admissions; 803 pairs; 15,625 associativity triples; 15,771 checked span isomorphisms |
| Chapter 5 constructions | 7 PASS groups; 101 category-law triples; book graph pushout isomorphism and graph product equations |
| Chapter 5 functors | 4 PASS groups; 551 natural admissions; 576,095 law triples; 3 exhaustive selected mediator cases, including nonconstant objects/arrow |
| Chapter 5 indexed/abstract | 2 PASS groups; 1,976 law triples; 2 exhaustive selected mediator cases; nonidentity constant-empty transport/right-adjoint constant-terminal; nonidentity-base free/cofree factors |
| Positive API fixtures | Both compile/link/run; Chapter5 public consumer passed |
| Negative API fixtures | All 10 exit 2 for the expected specific type boundary, not a missing wrapper/library |
| README example | Compiles/links/runs: witnesses=4, image pairs=3 |
| Chapter 5 example | Compiles/links/runs: graph product: 4 nodes, 2 edges |
| Local Markdown | README/guide relative files and anchors valid; exact ordered exercise index 1-12 |
| Static | git -c core.safecrlf=false diff --check exit 0; cast/serialization/catch-all scan empty; dependency/wrapper inventory coherent |

Counts are bounded fixtures, not a theorem about all possible programs.
Selected mediator enumeration is not claimed for every large derived apex.
Finite-functor tests also check nonstructural source equality and reordered
target enumerations, frozen callbacks, malformed laws, nonidentity horizontal
endpoints, interchange and simultaneous duality.

Mutation-sensitive feedback used isolated copies under the owned GUID root;
the real working source was never replaced. All three mutated copies compiled
under the normal profile, then their designated suite exited 2:
- comma square guard bypass -> Failure("comma square: accepted");
- naturality guard bypass -> Failure("non-natural components: accepted");
- horizontal beta component evaluated at alpha.src instead of alpha.tgt ->
  after admission and vertical groups passed, Failure("unexpected checked error")
  in the horizontal group using distinct source/target objects.
No compilation failure or timeout was counted as mutation detection. These
are selected sensitivity checks, not a mutation score. Exact verifier source
and inputs are retained below; the persistent regression files remain in tests.

Book SHA256 was rechecked unchanged:
17f3ba03c0a496a0da3cb8fc8845c349d6d05ff342eeb7d40341e1238d3f94c8.
No PDF edit, upload or external solution oracle was used. Mathematical
derivations in the guide are self-checked worked arguments, not formal proofs.

Source artifact inspection found two ignored pre-existing files
tests/functional_test.cmi and tests/functional_test.cmo dated 2026-10-07.
They and the pre-existing root _build directory are deliberately retained.
An early ad hoc scan printed an overbroad 'no compiler outputs' line despite
listing those two files; the correct conclusion is no new Chapter 5 compiler
outputs in source/tests/docs. Only owned GUID scratch is eligible for cleanup.

### Retained verifier source and inputs

Inputs: the hash-bound src/tests/manifests below; manual fixtures under
tests/type_contracts; exact OCaml fences in README.md and docs/chapter5.md.
The consumer and mutation scripts use the existing compiler executable on PATH.
The Markdown verifier uses the bundled Python runtime. All source below is
retained here even though temporary execution copies are removed at closure.

Consumer verifier (verify-consumers.ps1):
```powershell
param([string]$Root,[string]$Scratch,[string]$BuildDirectory='build')
$ErrorActionPreference='Stop'
$buildRoot=Join-Path $Scratch $BuildDirectory
$objs=Join-Path $buildRoot 'default\src\.computational_category.objs\byte'
$lib=Join-Path $buildRoot 'default\src\computational_category.cma'
$checks=Join-Path $Scratch 'consumers'
New-Item -ItemType Directory -Path $checks -Force | Out-Null
function Compile($name,$source) {
  $target=Join-Path $checks ($name+'.cmo')
  $output=& ocamlc -I $objs -c -impl $source -o $target 2>&1
  if($LASTEXITCODE -ne 0){throw "Compile $name failed: $output"}
  return $target
}
function Execute($name,$object,$expected) {
  $exe=Join-Path $checks ($name+'.byte')
  $out=& ocamlc -I $objs -I +unix unix.cma $lib $object -o $exe 2>&1
  if($LASTEXITCODE -ne 0){throw "Link $name failed: $out"}
  $out=& ocamlrun $exe 2>&1
  if($LASTEXITCODE -ne 0 -or (($out -join [Environment]::NewLine) -notmatch $expected)){throw "Run $name failed: $out"}
  Write-Output ('PASS {0}: {1}' -f $name,$out)
}
$fixtures=Join-Path $Root 'tests\type_contracts'
foreach($name in @('positive','chapter5_positive')){
  $obj=Compile $name (Join-Path $fixtures ($name+'.ml.txt'))
  $expected=if($name -eq 'chapter5_positive'){'Chapter5 public consumer passed'}else{'.*'}
  Execute $name $obj $expected
}
$negative=@{
  mixed_equality='Make\(Magnitude\)\.set'
  raw_arrow='Unbound record field.*entries'
  partition='Unbound value.*partition'
  raw_graph='Unbound record field.*nodes'
  raw_span='Unbound record field.*sp_arrow1'
  raw_comma='Unbound record field.*left'
  raw_functor='Unbound record field.*object_entries'
  raw_natural='Unbound record field.*components'
  raw_twisted='Unbound record field.*forward'
  raw_indexed='Unbound record field.*index'
}
foreach($name in ($negative.Keys | Sort-Object)){
  $output=& ocamlc -I $objs -c -impl (Join-Path $fixtures ($name+'.ml.txt')) -o (Join-Path $checks ($name+'.cmo')) 2>&1
  $code=$LASTEXITCODE
  if($code -ne 2 -or (($output -join [Environment]::NewLine) -notmatch $negative[$name])){
    throw "Wrong negative result for $name (exit $code): $output"
  }
  Write-Output ('PASS negative {0}: exit 2, expected type boundary' -f $name)
}
$documents=@(@('README.md','readme_example','witnesses=4, image pairs=3'),
  @('docs\chapter5.md','chapter5_example','graph product: 4 nodes, 2 edges'))
foreach($doc in $documents){
  $text=[IO.File]::ReadAllText((Join-Path $Root $doc[0]))
  $matches=[regex]::Matches($text,'(?s)\x60\x60\x60ocaml\r?\n(.*?)\r?\n\x60\x60\x60')
  if($matches.Count -ne 1){throw "Expected one OCaml example in $($doc[0])"}
  $source=Join-Path $checks ($doc[1]+'.ml')
  [IO.File]::WriteAllText($source,$matches[0].Groups[1].Value,[Text.UTF8Encoding]::new($false))
  Execute $doc[1] (Compile $doc[1] $source) $doc[2]
}
```

Mutation verifier (verify-mutations.ps1):
```powershell
param([string]$Root,[string]$Scratch)
$ErrorActionPreference='Stop'
$cases=@(
  @('comma_square','src\comma_categories.ml','if l.Functors.f_cod.equal_arr lhs rhs then',
    'if true || l.Functors.f_cod.equal_arr lhs rhs then','chapter5_test','comma square: accepted'),
  @('naturality','src\functor_categories.ml','if src.codomain.equal_arr left right then',
    'if true || src.codomain.equal_arr left right then','chapter5_functor_test','non-natural components: accepted'),
  @('horizontal_endpoint','src\functor_categories.ml','let* fa = object_map alpha.tgt a in',
    'let* fa = object_map alpha.src a in','chapter5_functor_test','unexpected checked error')
)
foreach($case in $cases){
  $dir=Join-Path $Scratch ('mutation_'+$case[0])
  New-Item -ItemType Directory -Path $dir | Out-Null
  foreach($name in @('dune-project','computational_category.opam','src','tests')){
    Copy-Item -LiteralPath (Join-Path $Root $name) -Destination $dir -Recurse
  }
  $path=Join-Path $dir $case[1]
  $source=[IO.File]::ReadAllText($path)
  if(([regex]::Matches($source,[regex]::Escape($case[2]))).Count -ne 1){
    throw "Mutation anchor is not unique: $($case[0])"
  }
  [IO.File]::WriteAllText($path,$source.Replace($case[2],$case[3]),[Text.UTF8Encoding]::new($false))
  $build=Join-Path $dir 'build'
  $out=& dune build --root $dir --build-dir $build --cache=disabled --no-config 2>&1
  if($LASTEXITCODE -ne 0){throw "Mutation must compile: $($case[0]): $out"}
  $out=& dune exec --root $dir --build-dir $build --cache=disabled --no-config ('tests/'+$case[4]+'.exe') 2>&1
  $code=$LASTEXITCODE
  if($code -eq 0 -or (($out -join [Environment]::NewLine) -notmatch [regex]::Escape($case[5]))){
    throw "Mutation not caught as expected: $($case[0]) exit $code : $out"
  }
  Write-Output ('PASS mutation {0}: compiled; test exit {1}; {2}' -f $case[0],$code,($out -join [Environment]::NewLine))
}
```
Command:
```powershell
& 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca\verify-mutations.ps1' -Root 'E:\Proj\course\computational-category' -Scratch 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca'
```

Markdown verifier (verify-docs.py):
```python
import pathlib,re
root=pathlib.Path(r'E:\Proj\course\computational-category')
slug=lambda s: re.sub(r'[^a-z0-9 -]','',s.lower()).replace(' ','-')
for rel in ['README.md','docs/chapter5.md']:
 p=root/rel; text=p.read_text(encoding='utf-8')
 for link in re.findall(r'\[[^\]]+\]\(([^)]+)\)',text):
  if '://' in link: continue
  file,_,anchor=link.partition('#')
  target=p.parent/file if file else p
  assert target.is_file(),(rel,link)
  if anchor:
   headings=re.findall(r'^#+ +(.+)$',target.read_text(encoding='utf-8'),re.M)
   assert anchor in [slug(h) for h in headings],(rel,link)
 print('PASS local Markdown links and anchors:',rel)
text=(root/'docs/chapter5.md').read_text(encoding='utf-8')
numbers=[int(n) for n in re.findall(r'^## Exercise (\d+) ',text,re.M)]
assert numbers==list(range(1,13)),numbers
print('PASS complete exercise solution index 1-12')
```
Command:
```powershell
& 'C:\Users\nostalgia\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'F:\Stratum\TEMP\computational-category-ch5-b69d46a8-6d09-4766-806a-15c5f8c949ca\verify-docs.py'
```

### Final file identities (SHA256)

| Repository-relative file | SHA256 |
| --- | --- |
| `computational_category.opam` | `3d91859bae9349b3e5bde560fc6a6e6fc0e4de4f1a81887f8f84f77cd6a12431` |
| `docs/chapter5.md` | `dcb7291d334940669ad25abd435871f19065f2f8228508eed9bf7677d7c605b3` |
| `dune-project` | `ea32c60fc134c057abfe24c026cdeb3135eca23caea40ada4bbf43b5b1e9784c` |
| `README.md` | `0337ac9271e3f27447bfb7662da1c616ce25951906ee17721d168d4e137ad65c` |
| `src/abstract_limits.ml` | `e15e1e1220077e7959b20411247dc7582ea5ae1acae11660c7858528fda9f572` |
| `src/cat.ml` | `6e8c3d54c67dc969fb7fce800c8b8a7853103ee7e837cd84d6b7dea4cd6a6b8a` |
| `src/category_constructions.ml` | `6700241ad9fb7457c6961d57354402f6c78db472de7b4aaab551d6d39258d350` |
| `src/colimits.ml` | `a20043c630ae63c787ff8c4fcfa7384f6987e9bbc03dbcad8a855f0a37dc5d54` |
| `src/comma_categories.ml` | `9e17932746cfc75843ed07bfa82274622b24f466d8210c52f1cdca5da3028602` |
| `src/comma_categories.mli` | `ff3d788044f2c3458efa11aa50f148907667d2571caca595225b397ab6ae9d6a` |
| `src/core.ml` | `8eb4283903e4c37a2bb281b82aff9d70088e6fdb30b85967a9e2d4781db72c83` |
| `src/dune` | `976405bd43350b252a796cfc388079481c3d83ffdef7868c9f86adff2d8143f0` |
| `src/finite_graphs.ml` | `67a92f127d2325c1503553c02fccf716a32657502f556ad7b684099fd4fed1a6` |
| `src/finite_sets.ml` | `ccc07488d8837febd785471988925379272ddcb98a80532d14e4fd3ae4912e07` |
| `src/functor_categories.ml` | `e91d7aacb3ff52d2e7e03fc2c04f9ae675c702a50ef78c4aedc047f681f36a9e` |
| `src/functor_categories.mli` | `8eef4b4b2541e9448d28852cd96c335f2c31f18e15c8041c4ffb8e0162201682` |
| `src/functors.ml` | `7a90d77badd3ff67da617b4b3d1575ae8f9a075eec912012d22cb0464969bf97` |
| `src/graphs.ml` | `3553541fc35afc581b696d6ed5f19ee5bb19b7849a30e6a867c30b6a2321f704` |
| `src/graphs.mli` | `00d8d3653bc9482dcf3bee67214205c30d1f58d01c93b25f437f60f7536e6207` |
| `src/indexed_categories.ml` | `2c2b4a5282cda06f8c740ab45d5bb6b519a7e59d770bb89d4f0c760148904f29` |
| `src/indexed_categories.mli` | `db6300507f052b063b87758599b3205361c81141f0613e028b671ee2e0442a5c` |
| `src/limits.ml` | `a766e182ace272e0c10ae73e8609c8c54f21170a74072c202e9b4f350f0999e9` |
| `src/relations.ml` | `c61d4d8f529a3ab1d79566ac075a8a757db1be6482358cb52150af98c411cb6f` |
| `src/relations.mli` | `31361b37c45cf9180ed138b49da48509ed032c197ae7d8e804ed6b3e492a30a5` |
| `src/term_category.ml` | `673aeb81bb606e7a92b25df8772cf99c1283dc3e6772cf1d740b3e5c99189cb8` |
| `src/twisted_arrows.ml` | `78dfb3397ff5f0b8bdb1e3b68c4c77d343918b84409f2b4f2007852eedcc49e2` |
| `src/twisted_arrows.mli` | `4d0b2d263764571a1bca7df5e680c93346037ac346ce271aeb72154bbc57a74e` |
| `src/universal.ml` | `de9f5a33c791fa0af4b6fd2b9bf8ca67202e008092ff5bca87823f7a18855118` |
| `tests/chapter5_functor_test.ml` | `576b19ddf26688e679ab5ec93fbefcaf048935e04d0063ac4272f9ee51719c99` |
| `tests/chapter5_indexed_test.ml` | `2b116ac291223c53922ef3aae6b8b16b87019939f3a37071f91d01b6efa1dfb7` |
| `tests/chapter5_test.ml` | `e2426070a2f159246f6d5895dd9292e64ec6931f765bf5f861395208a4c3e00d` |
| `tests/diagram_test.ml` | `0476700c65428ef0c4f5f08177af8d866c5efec8fa76aafe38f5ede6fb88fb0b` |
| `tests/dune` | `ccbb3a5ef7a31a894a30344fbf8d2746df96844f3f53a07a0fde92f2c2e26ba4` |
| `tests/functional_test.ml` | `1f953174aee9df4a99466a46c40eb1744b8b7d5bf18b24e37eff224b5c8f03a1` |
| `tests/relation_test.ml` | `5a6472a70601bdbb3a4b045388b8ed081b946615685772c6948d736a006deee2` |
| `tests/type_contracts/chapter5_positive.ml.txt` | `54962a8b7524a28a739132a6502225dbfc9c70edac06539b253f99fa3e4f9fc6` |
| `tests/type_contracts/mixed_equality.ml.txt` | `d34ccdde0609c78b5e2b2dc4802778183c96f06ed34e3008a4f88323e191ea96` |
| `tests/type_contracts/partition.ml.txt` | `8c9b66295875f75561f5d383fffaa72fb8fc8346f3d6ac353c520ad2abcf5cb0` |
| `tests/type_contracts/positive.ml.txt` | `a199558b6467ed49d78e77c79fab5632ee3a375b0a711dfb67ede09cf3e24818` |
| `tests/type_contracts/raw_arrow.ml.txt` | `6fe5498e9b2a296d0f44b9e143a6b37038ede3f1fa3a75c30215ce895fa97cf5` |
| `tests/type_contracts/raw_comma.ml.txt` | `55b2e74e3c7d2bc5bd8a38baf18591e479e74afe23076432cfc00196b700c911` |
| `tests/type_contracts/raw_functor.ml.txt` | `60ee7a5278ad11bcd1ac0f6ae7d1327a4f99540a8b5cd220ab1cf1546b2eb552` |
| `tests/type_contracts/raw_graph.ml.txt` | `30246035e2acefd303a9aa38eb28b4eaed94b9e35358e9e20d77ea2d7e22aefe` |
| `tests/type_contracts/raw_indexed.ml.txt` | `422118a984ea1eb0b9963c008bbc3bd2cd173669066ab68b4fa04049c02e7cdd` |
| `tests/type_contracts/raw_natural.ml.txt` | `dcebfd5a130a45067ab11b14615eb12826c2e1444ec36e10102988107b84da27` |
| `tests/type_contracts/raw_span.ml.txt` | `d6db379ed65375cadecf5227b16e308805c6dfcc10f26d2f4ed1b133738a6447` |
| `tests/type_contracts/raw_twisted.ml.txt` | `404e318947d1bd38eea9059f25a5ec9cef00afc32baf2e21fb0682815a6c60c2` |

### Closure audit

The smallest ready dependency chain is closed: 7.1 -> 7.2 -> 8.1/8.2 -> 9.1 -> 9.2.
Removing a module boundary now would confuse domain ownership or merge distinct
shape/object categories; no relay facade or parallel mathematical authority is
present. Book facts, local execution and caller premises remain distinguished.
No required Chapter 5 worked exercise is omitted; restricted programming
variants are named rather than silently promoted to unrestricted completion.
No further local stage is ready under this completed request. Chapters 6-10,
unrestricted graph grammars, heterogeneous fibers and publication need separate
authority and decisions. Final cleanup and unchanged-file audit are recorded
immediately after their observed completion, not presumed here.

Final closure observation (2026-10-10): all 47 hash-bound delivery inputs
were unchanged after final execution. Resolve-Path and the exact GUID basename
confirmed the scratch target stays beneath GetTempPath before native
Remove-Item -LiteralPath -Recurse -Force. Post-observation confirms that only
the owned Chapter 5 scratch directory is gone. Existing root _build and the
two ignored 2026-10-07 functional-test artifacts remain untouched.
HEAD is still 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c; no commit,
branch, worktree, install or publication was created. Final diff --check
succeeded. The canonical plan remains tracked and all work remains local.

