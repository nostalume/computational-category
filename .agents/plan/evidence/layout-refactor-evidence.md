# Mathematical-layout evidence

Evidence only; [canonical plan](../architecture-plan.md) governs current work.
Sections record historical, revision-scoped deliveries; they do not authorize new work.

## Recovery baseline

Entry HEAD: 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c; dirty working tree is the recovery authority,
not HEAD, which lacks the completed delivery. Before compaction, 51 files were
captured: every nonignored Git-tracked/untracked file plus the two preexisting
ignored functional_test.cmi/.cmo files. Existing root _build, .git internals and
other generated/cache files are explicitly excluded in the manifest.

Local retained snapshot (ignored, not portable/review source):
E:\Proj\course\computational-category\.agents\cache\layout-baseline-20261010-fca6db53-58a6-4fce-8951-b7cae2cb7523

- working-tree.zip: 131,766 bytes; SHA256
  e91e5b1909e484f8b623a52edb5db6dd99be7658b466da47defbb287e929c9ce.
- manifest.json binds each of 51 file paths, sizes and hashes; all ZIP entries
  were individually count/size/SHA256-verified against their entry files.
- status-before.txt and tracked-diff.patch preserve baseline status/diff.
- README.md explains recovery: extract and inspect in an owned separate directory,
  compare newer changes before copying anything back. Never reset to HEAD or
  overwrite later user work automatically. Keep this snapshot through cutover
  and acceptance; Stage 10 grants no restore/cleanup authority for it.
- Original canonical plan: 123,943 bytes, SHA256
  7a0b0e1644ae88b5fe418b0b63ded49693d54960b64a880a58648d13a87b5a92.
  Full original remains in the recovery ZIP. Older Chapter 2-5 history is archived
  once in pre-layout-audit.md; the approved current refactor section stays in the
  compact canonical plan rather than being duplicated in that history.

## Fresh baseline

Client date: 2026-10-10, Asia/Shanghai. Host filesystem snapshot recorded
captured_utc in manifest.json; the client date owns this report.
Installed OCaml 5.2.1 / Dune 3.24.2; normal build profile, no warning suppression,
cache disabled, no user config. HEAD remains the entry HEAD.

Commands (PowerShell, existing compiler environment below):
```powershell
$env:PATH='C:\Users\nostalgia\AppData\Local\opam\default\bin;C:\Users\nostalgia\AppData\Local\opam\.cygwin\root\usr\x86_64-w64-mingw32\sys-root\mingw\bin;C:\Users\nostalgia\AppData\Local\opam\.cygwin\root\bin;'+$env:PATH; $env:OPAM_SWITCH_PREFIX='C:\Users\nostalgia\AppData\Local\opam\default'; 
ocamlc -version
dune --version
dune build --build-dir 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523\baseline-build' --cache=disabled --no-config
dune runtest --build-dir 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523\baseline-build' --cache=disabled --no-config --force
& 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523\verify-consumers.ps1' -Root 'E:\Proj\course\computational-category' -Scratch 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523' -BuildDirectory baseline-build
& 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523\inventory.ps1' -Root 'E:\Proj\course\computational-category' -Scratch 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523'
```

Observed: build and forced runtest exit 0; six suites, all 33 PASS groups.
Coverage counters:
- Foundation: 6,146 map fixtures; 973 associativity triples; 1,020 unique mediators.
- Diagrams: 461 FinSet diagrams; 5,350 mediators; 5,529 uniqueness cases;
  351 larger equation-only cases; 39 Boolean diagrams / 100 mediators; 114 pullbacks.
- Relations: 47 admissions; 803 composable pairs; 15,625 associativity triples;
  15,771 checked span isomorphisms.
- Chapter 5 constructions: 101 law triples.
- Chapter 5 functors: 551 natural admissions; 576,095 law triples;
  3 exhaustive selected mediators.
- Chapter 5 indexed: 1,976 law triples; 2 exhaustive selected mediators.

These are existing fixture coverage, not an unrestricted mathematical proof.
Public checks and inventory verifier exit 0:
- positive and chapter5_positive compile/link/run; Chapter5 public consumer passed.
- All ten negatives exit 2 for their expected type boundary, not missing-library
  errors: mixed_equality, partition, raw_arrow, raw_comma, raw_functor, raw_graph,
  raw_indexed, raw_natural, raw_span, raw_twisted.
- README example: witnesses=4, image pairs=3.
- Chapter 5 guide example: graph product: 4 nodes, 2 edges.
- All 17 interfaces extracted without an extraction failure.

## Public API ownership inventory

Inventory is bound to all 17 existing modules, the snapshot manifest and HEAD,
not merely implementation-level names. The compiler extracted six explicit
interfaces and eleven implementation interfaces with their inline module
ascriptions respected. Each default below covers every exported type, value,
module signature, constructor and record field; exceptions override it exactly
once. Fields/constructors follow their defining type. Removed containers do not
justify compatibility aliases. Names within a future owner can be renamed during
the approved clean migration; this inventory assigns semantic owners, not frozen
private syntax.

All paths below are children of Computational_category.

| Existing module | Default destination owner | Exceptions / retained child meaning |
|---|---|---|
| Cat | Foundations.Category | All errors, category dictionary fields and helpers stay together. |
| Core | Exercises.Basic | All standalone arithmetic/list/tree/monoid exercises. |
| Universal | Universal.Limits | All primitive universal contracts, data fields and iso_initial. |
| Graphs | Universal.Diagrams | Exceptions listed immediately below. Shapes are not finite graph objects. |
| Functors | Foundations.Functor | Exceptions listed immediately below; cat_functor and its fields stay here. |
| Category_constructions | Constructions.Elementary | constant -> Foundations.Functor; projections remain with product ownership. |
| Abstract_limits | Universal.Limits | colimit_structure/fixed_colimit and fields -> named Free child; limit_structure/fixed_limit and fields -> named Cofree child. |
| Twisted_arrows | Constructions.Elementary.Twisted | All abstract arrow admission/accessors/category operations. |
| Comma_categories | Constructions.Comma | All abstract object/arrow admissions and inherited universal operations. |
| Functor_categories | Constructions.Functor_category | Finite-domain enumeration and frozen admitted functors/naturals; do not merge with general capability dictionaries. |
| Indexed_categories | Constructions.Indexed | INDEXED premise, Make outputs, right_adjoint fields and transpose operations. |
| Finite_sets | Instances.Finite_sets | ATOM, S and Make preserve one equality/value universe. |
| Colimits | Instances.Finite_set_universals.Make(F) | Merge public Make operations, not a re-export wrapper; private partition remains private. |
| Limits | Instances.Finite_set_universals.Make(F) | Same supplied F as colimits and square operations. |
| Finite_graphs | Instances.Finite_graphs.Make(F) | Labelled/Rewriting child ownership below; one graph type identity across children. |
| Relations | Constructions.Spans | Make(F).relation_span/image -> Instances.Finite_relations.Make(F); old Make container retires from generic owner. |
| Term_category | Instances.Terms | TermCategory container can flatten; FiniteCategory and every member -> one shared test fixture, no public library replacement. |

Graphs exceptions -> Universal.Limits:
- Types: colimiting_cocone, colimit, cocomplete_cat, limiting_cone, limit,
  complete_cat; all their record fields.
- Values: finite_colimit, dual_colimit, dual_limit, pushout, pullback,
  map_colimit, map_limit, coproduct, product.
- Every other Graphs export, including diagram/cone/cocone morphisms,
  fixed/variable-base dictionaries and shape duals, stays in Universal.Diagrams.

Functors exceptions:
- map_diagram, map_cocone, map_cone -> Universal.Diagrams.
- continuous_functor, cocontinuous_functor and their fields,
  id_continuous_functor, id_cocontinuous_functor, dual_continuous,
  transport_colimit -> Universal.Preservation.
- dual_colimiting, dual_limiting -> Universal.Limits.
- Make(F).product_functor, Make(F).product_continuous ->
  Instances.Finite_set_universals.Make(F). The old mixed Make container retires.

Finite_graphs.Make(F) children:
- labelled, labelled_arrow (both types and same-named admission values),
  underlying, labels, underlying_arrow, labelled_category, labelled_cocomplete
  -> Labelled child of the same instance.
- rewrite_result and all fields, rewrite -> Rewriting child of the same instance.
- Graph/arrow primitives and inherited universals stay in the parent instance.

No deletion of public behavior is implied except removal of the toy-category
library example, explicitly assigned to shared test support. Unsupported helpers
must not be silently hidden just because a new mli is convenient. The compiled
interface inventory below is a compact declaration index, not a replacement
signature or a new API authority; full types remain in the hash-bound snapshot.
Repeated names denote distinct type/value namespaces or nested signatures.

### abstract_limits

```text
type ('d, 'da, 'c, 'ca) colimit_structure = {
type ('d, 'da, 'c, 'ca) limit_structure = {
val fixed_colimit
val fixed_limit
```

### cat

```text
type error =
val ( let* )
val traverse
type ('o, 'a) cat = {
val compose
val parallel
val has_endpoints
val dual_cat
```

### category_constructions

```text
val one
val one_cocomplete
val one_complete
val constant
val product
val first
val second
val cocomplete_product
val complete_product
val slice
val coslice
```

### colimits

```text
module Make
val set_initial
val set_coproduct
val set_coequalizer
val set_coequalizer_classes
val set_pushout
val io_cp_ce_finset
val set_colimit
val cocomplete_finset
```

### comma_categories

```text
type ('oa, 'ac, 'ob) obj
type ('oa, 'aa, 'ac, 'ob, 'ab) arrow
val left_object
val right_object
val connecting_arrow
val source
val target
val left_arrow
val right_arrow
val object_
val equal_object
val arrow
val category
val left_projection
val right_projection
val colimit_with_projections
val cocomplete
val swap_object
val swap_arrow
val dual_to_swapped
val swapped_to_dual
val complete
val coslice_coproduct
```

### core

```text
type num = Zero | Succ of num
val numprint
val add
type 'a bintree = Tip of 'a | Node of 'a bintree * 'a bintree
val breadth
val depth
val tips
val int_pow
val fold
val maplist
val reverse_list
val sum_list
val max_list
val poly
type 'a monoid = { op
val free_monoid_hom
```

### finite_graphs

```text
module Make
type graph
type arrow
val graph
val nodes
val edges
val incidence
val source
val target
val edge_map
val node_map
val arrow
val category
val cocomplete
val complete
val product
type labelled
type labelled_arrow
val labelled
val underlying
val labels
val labelled_arrow
val underlying_arrow
val labelled_category
val labelled_cocomplete
type rewrite_result = {
val rewrite
```

### finite_sets

```text
module type ATOM = sig type t val equal
module type S =
type atom
type value
type view =
type set
type arrow
val atom
val tag
val pair
val terminal
val view
val equal
val emptyset
val singleton
val of_list
val to_list
val seteq
val member
val cardinality
val is_empty
val union
val inter
val diff
val mapset
val cartesian_prod
val disjoint_union
val powerset
val split
val singleton_split
val arrow
val arrow_result
val source
val target
val apply
val ident
val compose
val equal_arrow
val cat
module Make
type atom = E.t
type value
type view =
type set
type arrow
val atom
val tag
val pair
val terminal
val view
val equal
val emptyset
val singleton
val of_list
val to_list
val seteq
val member
val cardinality
val is_empty
val union
val inter
val diff
val mapset
val cartesian_prod
val disjoint_union
val powerset
val split
val singleton_split
val arrow
val arrow_result
val source
val target
val apply
val ident
val compose
val equal_arrow
val cat
```

### functor_categories

```text
type ('o, 'a) domain
val finite_domain
val objects
val arrows
val domain_category
type ('oa, 'aa, 'ob, 'ab) functor_
val object_map
val arrow_map
val equal_functor
val functor_
val identity_functor
val constant_functor
type ('oa, 'aa, 'ob, 'ab) natural
val source
val target
val component
val natural
val equal_natural
val category
val compose_functors
val diagonal
val horizontal
val dual_domain
val dual_functor
val dual_natural
val cocomplete
val complete
```

### functors

```text
type ('oa, 'aa, 'ob, 'ab) cat_functor = {
val id_functor
val dual_functor
val compose
val map_diagram
val map_cocone
val map_cone
type ('oa, 'aa, 'ob, 'ab) continuous_functor = {
module Make
val product_functor
val product_continuous
type ('oa, 'aa, 'ob, 'ab) cocontinuous_functor = {
val id_cocontinuous_functor
val id_continuous_functor
val dual_colimiting
val dual_limiting
val dual_continuous
val transport_colimit
```

### graphs

```text
type graph
type ('o, 'a) diagram
type ('o, 'a) cocone
type ('o, 'a) cone
type ('o, 'a) cocone_arrow
type ('o, 'a) cone_arrow
val graph
val graph_nodes
val graph_edges
val graph_source
val graph_target
val diagram
val diagram_graph
val diagram_category
val diagram_nodes
val diagram_edges
val node_object
val edge_arrow
val same_base
val cocone
val cone
val cocone_apex
val cocone_base
val cocone_side
val cone_apex
val cone_base
val cone_side
val cocone_arrow
val cone_arrow
val cocone_apex_arrow
val cocone_arrow_domain
val cocone_arrow_codomain
val cone_apex_arrow
val cone_arrow_domain
val cone_arrow_codomain
type ('o, 'a) colimiting_cocone = {
type ('o, 'a) colimit =
type ('o, 'a) cocomplete_cat = {
type ('o, 'a) limiting_cone = {
type ('o, 'a) limit =
type ('o, 'a) complete_cat = {
val finite_colimit
val dual_graph
val dual_diagram
val dual_cocone
val dual_cone
val dual_cocone_arrow
val dual_cone_arrow
val dual_colimit
val dual_limit
val pushout
val pullback
type ('o, 'a) diagram_arrow
val diagram_arrow
val diagram_arrow_domain
val diagram_arrow_codomain
val diagram_component
val diagrams_category
type ('o, 'a) cocone_map
type ('o, 'a) cone_map
val cocone_map
val cone_map
val cocone_map_domain
val cocone_map_codomain
val cocone_map_base
val cocone_map_apex
val cone_map_domain
val cone_map_codomain
val cone_map_base
val cone_map_apex
val total_cocone_category
val total_cone_category
val map_colimit
val map_limit
val coproduct
val product
```

### indexed_categories

```text
module type INDEXED =
type base_obj
type base_arr
type fiber_obj
type fiber_arr
val base
val fiber
val valid_object
val transport
module Make
type obj
type arrow
val index
val value
val source
val target
val base_map
val fiber_map
val object_
val equal_object
val arrow
val category
val projection
val cocomplete
type right_adjoint = {
val transpose
val untranspose
val complete
```

### limits

```text
module Make
val set_terminal
val set_product
val set_equalizer
val io_cp_ce_dual_finset
val set_limit
val complete_finset
val set_pullback
```

### relations

```text
type ('o, 'a) span
val span
val span_source
val span_left
val span_right
val identity
val compose
module Make
val relation_span
val image
```

### term_category

```text
module TermCategory
type names
type opr
type term
type view =
type substitution
val names
val names_list
val equal_names
val operator
val operator_name
val operator_args
val var
val application
val view
val equal_term
val substitution
val apply_term
val source
val target
val ident
val compose
val equal_arrow
val cat
module FiniteCategory
type obj = A | B | C
type arr = F | G | H | K | Id of obj
val source
val target
val ident
val comp
val cat
```

### twisted_arrows

```text
type 'a arrow
val source
val target
val forward
val backward
val arrow
val category
```

### universal

```text
type ('o, 'a) initial_obj = {
type ('o, 'a) terminal_obj = {
type ('o, 'a) coproduct_data = {
type ('o, 'a) coproduct =
type ('o, 'a) product_data = {
type ('o, 'a) product =
type ('o, 'a) coequalizer_data = { coeq_obj
type ('o, 'a) coequalizer =
type ('o, 'a) equalizer_data = { eq_obj
type ('o, 'a) equalizer =
type ('o, 'a) pushout_data = {
type ('o, 'a) pushout =
type ('o, 'a) pullback_data = {
type ('o, 'a) pullback =
type ('o, 'a) io_cp_ce_cat = {
val iso_initial
```


## Verifier sources

### Existing public consumers / documentation examples

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

### Public interface extraction

```powershell
param([string]$Root,[string]$Scratch)
$ErrorActionPreference='Stop'
$byte=Join-Path $Scratch 'baseline-build\default\src\.computational_category.objs\byte'
$dest=Join-Path $Scratch 'api'
New-Item -ItemType Directory -Path $dest -Force | Out-Null
foreach($f in (Get-ChildItem -LiteralPath (Join-Path $Root 'src') -Filter '*.ml' | Sort-Object Name)) {
 $mli=[IO.Path]::ChangeExtension($f.FullName,'.mli')
 $mode=if(Test-Path -LiteralPath $mli){'-intf'}else{'-impl'}
 $input=if($mode -eq '-intf'){$mli}else{$f.FullName}
 $out=& ocamlc -I $byte -open Computational_category -i $mode $input 2>&1
 if($LASTEXITCODE -ne 0){throw "Interface extraction failed: $input : $out"}
 [IO.File]::WriteAllText((Join-Path $dest ($f.BaseName+'.mli.txt')),($out -join [Environment]::NewLine),[Text.UTF8Encoding]::new($false))
 Write-Output ('PASS inventory {0}: {1}' -f $f.BaseName,$mode)
}

```

## Namespace feasibility probe

This is a tooling-mechanism probe, not product code or a mathematical universality
implementation. It uses abstract arrow/diagram placeholders, sibling imports,
cross-owner dependencies, one wrapped library, a functor-generated instance and
an external executable. Builds and consumer run exit 0; no parent-alias cycle
occurred. Both malformed public record constructions exit 2 for the expected
hidden field. Dune language 3.0 control exits 1 with:
'qualified' is only available since version 3.7 of the dune language.
The same mechanism compiles with language 3.7 using installed Dune 3.24.2.
This establishes no language floor above the accepted 3.7 for this mechanism,
not a minimum-binary compatibility certification. Actual Dune 3.7 / OCaml 4.14
binaries and the future production cutover remain untested.

Invocation after applying the same existing compiler environment:

```powershell
& 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523\probe.ps1' -Scratch 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523'
```

### Probe driver and negative control

```powershell
param([string]$Scratch)
$ErrorActionPreference='Stop'
$probe=Join-Path $Scratch 'probe'
& dune build --root $probe --build-dir (Join-Path $Scratch 'probe-build') --cache=disabled --no-config
if($LASTEXITCODE -ne 0){throw 'Qualified probe build failed'}
& dune exec --root $probe --build-dir (Join-Path $Scratch 'probe-build') --cache=disabled --no-config consumer/main.exe
if($LASTEXITCODE -ne 0){throw 'Qualified consumer failed'}
$byte=Join-Path $Scratch 'probe-build\default\src\.hierarchy_probe.objs\byte'
foreach($name in @('negative_arrow','negative_diagram')){
 $field=if($name -eq 'negative_arrow'){'hidden_source'}else{'hidden_arrow'}
 $out=& ocamlc -I $byte -c -impl (Join-Path $probe ($name+'.ml')) -o (Join-Path $Scratch ($name+'.cmo')) 2>&1
 $code=$LASTEXITCODE
 if($code -ne 2 -or (($out -join [Environment]::NewLine) -notmatch ('Unbound record field.*'+$field))){throw "Wrong sealed boundary: $name / $code / $out"}
 Write-Output ('PASS {0}: exit 2, sealed representation {1}' -f $name,$field)
}
$control=Join-Path $Scratch 'control'
New-Item -ItemType Directory -Path $control -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $control 'dune-project'),"(lang dune 3.0)",[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $control 'dune'),"(include_subdirs qualified)",[Text.UTF8Encoding]::new($false))
$out=& dune build --root $control --build-dir (Join-Path $Scratch 'control-build') --cache=disabled --no-config 2>&1
$code=$LASTEXITCODE
if($code -eq 0 -or (($out -join [Environment]::NewLine) -notmatch '3.7')){throw "Wrong language-floor control: $code / $out"}
Write-Output ('PASS Dune 3.0 control: exit {0}; {1}' -f $code,($out -join ' '))

```

### Exact probe source inputs

#### dune-project

```lisp
(lang dune 3.7)
(name hierarchy_probe)
```

#### src/dune

```lisp
(include_subdirs qualified)
(library (name hierarchy_probe))
```

#### src/foundations/category.mli

```ocaml
type arrow
val identity : int -> arrow
val source : arrow -> int
val compose : arrow -> arrow -> (arrow, string) result
```

#### src/foundations/category.ml

```ocaml
type arrow = { hidden_source : int }
let identity hidden_source = { hidden_source }
let source a = a.hidden_source
let compose g f = if source g = source f then Ok f else Error "domain"
```

#### src/foundations/functor.ml

```ocaml
let map a = Category.identity (Category.source a)
```

#### src/universal/diagrams.mli

```ocaml
type t
val singleton : Foundations.Category.arrow -> t
val arrow : t -> Foundations.Category.arrow
```

#### src/universal/diagrams.ml

```ocaml
type t = { hidden_arrow : Foundations.Category.arrow }
let singleton hidden_arrow = { hidden_arrow }
let arrow d = d.hidden_arrow
```

#### src/universal/limits.ml

```ocaml
type chosen = { diagram : Diagrams.t }
let choose diagram = { diagram }
```

#### src/universal/preservation.ml

```ocaml
let map c = Limits.choose (Diagrams.singleton (Foundations.Functor.map (Diagrams.arrow c.Limits.diagram)))
```

#### src/constructions/comma.ml

```ocaml
let choose a = Universal.Limits.choose (Universal.Diagrams.singleton a)
```

#### src/instances/toy.ml

```ocaml
module Make (E : sig val object_id : int end) = struct
let chosen = Constructions.Comma.choose (Foundations.Category.identity E.object_id)
end
```

#### src/exercises/basic.ml

```ocaml
let twice x = x + x
```

#### consumer/dune

```lisp
(executable (name main) (libraries hierarchy_probe))
```

#### consumer/main.ml

```ocaml
open Hierarchy_probe
module T = Instances.Toy.Make (struct let object_id = 7 end)
let () =
 let chosen = Universal.Preservation.map T.chosen in
 let a = Universal.Diagrams.arrow chosen.Universal.Limits.diagram in
 assert (Foundations.Category.source a = 7);
 assert (Foundations.Category.compose a a = Ok a);
 assert (Foundations.Category.compose a (Foundations.Category.identity 8) = Error "domain");
 assert (Exercises.Basic.twice 7 = 14);
 print_endline "PASS qualified namespaces, sibling and cross-owner imports, wrapped consumer"
```

#### negative_arrow.ml

```ocaml
let bad : Hierarchy_probe.Foundations.Category.arrow = { hidden_source = 7 }
```

#### negative_diagram.ml

```ocaml
let bad : Hierarchy_probe.Universal.Diagrams.t = { hidden_arrow = Hierarchy_probe.Foundations.Category.identity 7 }
```

## Conformance and closure scope

No architecture blocker emerged from the probe. Declaration routing retains
admission laws and separates general theory from concrete instances; stage 11
still must validate the actual extraction graph and type identities. No tests
were invented as post-hoc RED/GREEN evidence. No new mathematical result,
algorithm speedup, unrestricted exercise completion or public release is claimed.

Final closure checks and owned-scratch cleanup are recorded below after execution.

### Final closure verifier

Historical payload: 112,017 bytes, SHA256
24a265dbac010bb3f95aa0405b4b642fa9323b620f0af08dce1097ff711f3be2.
Active plan: 13,456 bytes, reduced from 123,943 entry bytes (about 89%);
historical material is preserved, not deleted or presented as new authority.

Invocation (owned scratch, prior to its verified cleanup):

```powershell
& 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523\closure.ps1' -Root 'E:\Proj\course\computational-category' -Scratch 'F:\Stratum\TEMP\computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523' -Snapshot 'E:\Proj\course\computational-category\.agents\cache\layout-baseline-20261010-fca6db53-58a6-4fce-8951-b7cae2cb7523'
```

```powershell
param([string]$Root,[string]$Scratch,[string]$Snapshot)
$ErrorActionPreference='Stop'
$manifest=Get-Content -LiteralPath (Join-Path $Snapshot 'manifest.json') -Raw | ConvertFrom-Json
if((& git -C $Root rev-parse HEAD).Trim() -ne $manifest.head){throw 'HEAD changed'}
$count=0
foreach($f in $manifest.files){
 if($f.path -eq '.agents/plan/architecture-plan.md'){continue}
 $path=Join-Path $Root $f.path
 if((Get-Item -LiteralPath $path).Length -ne $f.bytes -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $f.sha256){throw "Baseline file changed: $($f.path)"}
 $count++
}
Write-Output ('PASS {0} non-plan baseline files unchanged, including ignored compiler artifacts and manifests' -f $count)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath=Join-Path $Snapshot 'working-tree.zip'
if((Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'e91e5b1909e484f8b623a52edb5db6dd99be7658b466da47defbb287e929c9ce'){throw 'Recovery archive changed'}
$zip=[IO.Compression.ZipFile]::OpenRead($zipPath)
try {
 if($zip.Entries.Count -ne $manifest.files.Count){throw 'Wrong recovery entry count'}
 foreach($f in $manifest.files){
  $entry=$zip.GetEntry($f.path)
  if($null -eq $entry -or $entry.Length -ne $f.bytes){throw "Wrong archive entry: $($f.path)"}
  $stream=$entry.Open()
  $sha=[Security.Cryptography.SHA256]::Create()
  try{$hash=([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','').ToLowerInvariant()}finally{$sha.Dispose();$stream.Dispose()}
  if($hash -ne $f.sha256){throw "Wrong archived hash: $($f.path)"}
 }
 $reader=[IO.StreamReader]::new($zip.GetEntry('.agents/plan/architecture-plan.md').Open(),[Text.Encoding]::UTF8)
 try{$original=$reader.ReadToEnd()}finally{$reader.Dispose()}
}finally{$zip.Dispose()}
$boundary=$original.IndexOf('## Mathematical-layout refactor plan — 2026-10-10',[StringComparison]::Ordinal)
$history=$original.Substring(0,$boundary)
$archive=[IO.File]::ReadAllText((Join-Path $Root '.agents\plan\evidence\pre-layout-audit.md'))
if(-not $archive.EndsWith($history,[StringComparison]::Ordinal)){throw 'Historical prefix changed'}
$header=$archive.Substring(0,$archive.Length-$history.Length)
if($header -notmatch 'Historical evidence only; NOT a current governing plan'){throw 'Missing historical authority boundary'}
if($header -match '## Mathematical-layout refactor plan'){throw 'Current plan accidentally copied to archive header'}
Write-Output 'PASS all 51 recovery entries reverified and historical payload byte-preserving'
$plan=[IO.File]::ReadAllText((Join-Path $Root '.agents\plan\architecture-plan.md'))
if($plan -cne [IO.File]::ReadAllText((Join-Path $Scratch 'compact-plan.md'))){throw 'Canonical plan differs from reviewed content'}
if($plan -notmatch '\[x\] 10.1' -or $plan -notmatch '\[x\] 10.2' -or $plan -match '\[x\] 1[123]\.'){throw 'Wrong stage status'}
foreach($link in @('evidence/pre-layout-audit.md','evidence/layout-refactor-evidence.md')){
 if(-not (Test-Path -LiteralPath (Join-Path (Join-Path $Root '.agents\plan') $link))){throw "Missing artifact: $link"}
}
& git -C $Root diff --check
if($LASTEXITCODE -ne 0){throw 'Diff whitespace check failed'}
& git -C $Root ls-files --error-unmatch .agents/plan/architecture-plan.md
if($LASTEXITCODE -ne 0){throw 'Canonical plan not tracked'}
Write-Output 'PASS current-stage authority, artifact links, tracked plan and diff --check'
$before=@(Get-Content -LiteralPath (Join-Path $Snapshot 'status-before.txt'))
$after=@(& git -C $Root -c core.quotepath=false status --porcelain=v1 --untracked-files=all)
$delta=@(Compare-Object $before $after)
foreach($d in $delta){
 if($d.SideIndicator -ne '=>' -or $d.InputObject -notmatch '^\?\? \.agents/plan/evidence/(pre-layout-audit|layout-refactor-evidence)\.md$'){throw "Unexpected status change: $($d.InputObject)"}
}
if($delta.Count -ne 2){throw "Unexpected new-file count: $($delta.Count)"}
Write-Output 'PASS only canonical plan content and two evidence artifacts changed in Stage 10'
$resolved=(Resolve-Path -LiteralPath $Scratch).Path
$temp=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')+'\'
$expected='computational-category-layout-stage1-fca6db53-58a6-4fce-8951-b7cae2cb7523'
if(-not $resolved.StartsWith($temp,[StringComparison]::OrdinalIgnoreCase) -or (Split-Path -Leaf $resolved) -ne $expected){throw 'Unsafe cleanup target'}
Remove-Item -LiteralPath $resolved -Recurse -Force
if(Test-Path -LiteralPath $resolved){throw 'Scratch residue'}
if(-not (Test-Path -LiteralPath $Snapshot)){throw 'Retained recovery snapshot missing'}
if(-not (Test-Path -LiteralPath (Join-Path $Root '_build'))){throw 'Preexisting root build missing'}
Write-Output 'PASS exact owned temporary scratch removed; recovery snapshot and preexisting root _build remain'

```

### Observed final closure — 2026-10-10

Closure verifier exited 0:
- All 50 non-plan baseline files remain size/hash-identical, including source,
  tests, both documentation inputs, manifests, ignore rules and existing ignored
  compiler artifacts. HEAD is unchanged.
- All 51 ZIP entries were reverified; the historical archive's payload exactly
  matches the original history prefix from that recovery ZIP.
- Stage 10 alone is complete; artifact links resolve and the canonical plan
  remains tracked. git diff --check passed.
- Status delta from entry consists solely of the two new evidence documents;
  the already-modified canonical plan is the only existing file changed now.
- Resolve-Path, GetTempPath containment and the exact owned GUID basename were
  checked before native recursive removal. Post-observation: owned scratch gone;
  retained recovery snapshot and preexisting root _build still present.
- Git emitted existing LF-to-CRLF conversion warnings, not whitespace failures.
  No normalization policy, Git configuration or ignored artifact was changed.

No commit, branch, worktree, installation, publication, production file move or
real Dune/Opam manifest change occurred. The recovery snapshot remains local and
ignored; portable review evidence is in these two audit documents. A future
cutover must revalidate unchanged input/caller assumptions and its actual graph.

## Stage 11 — Buildable owner and namespace cutover — 2026-10-10

### Authority, revision and recovery
The user's "agree, proceed" authorizes the next stage, canonical Stage 11,
not Stage 12's test reorganization or Stage 13's whole-refactor acceptance.
HEAD remains 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c; all work remains uncommitted and local.
Before editing, all 50 Stage 10 non-plan files matched their preserved hashes.
A second dirty-entry snapshot captured 53 files and was later entry/hash-verified:
E:\Proj\course\computational-category\.agents\cache\layout-cutover-entry-20261010-465672ca-6b27-42e9-908a-70f91ae16bbb
working-tree.zip SHA256:
e70452bec137a97f9d514972ad9a1eb2c04118021c0e17784d0c4d4d83dfc25b.
The Stage 10 snapshot remains intact; neither snapshot is a reset-to-HEAD recipe.

### Achieved ownership
The public wrapper now exposes exactly Constructions, Exercises, Foundations,
Instances and Universal, generated natively by include_subdirs qualified.
There are 16 implementation files and 8 interfaces, versus 17 and 6 at entry;
the gain is ownership/navigation, not a dramatic file-count reduction.
No old flat forwarding modules remain. Source paths follow the accepted map.

- Foundations owns Category and general Functor capabilities (including constants).
- Universal.Diagrams owns shape/admission/morphisms and functor mapping.
  Universal.Limits owns primitive contracts, chosen capabilities, the one generic
  finite-colimit algorithm, its dual, specializations and Free/Cofree children.
  Universal.Preservation owns continuity/cocontinuity and inverse transport.
- Constructions owns Elementary (with real Twisted child), Comma,
  finite-domain Functor_category, Indexed and generic witness-bearing Spans.
- Instances owns Finite_sets, merged Finite_set_universals.Make(F),
  Finite_graphs with real Labelled/Rewriting children, Finite_relations and Terms.
  Graph children retain their parent's graph/arrow identities; the graph instance
  now uses one concrete universal capability instance, not separate C/L/P modules.
- Exercises.Basic retains the selected standalone algorithms.
  The unrelated textbook category lives once in tests/toy_category.ml and is
  shared by two existing executables through private category_test_support.
  This private test library is not another public package or a library dependency.

The real Dune language declaration and both dependency minima now agree on 3.7.
One public package and its wrapped library remain. All source/test/compiler-fixture
callers and both example blocks were migrated together. README owners and source
links were minimally corrected for this cutover; broader navigation/migration
explanation and mathematical regrouping of tests remain Stage 12 work.
Book Cat (the mathematical universe) remains distinct from Foundations.Category.

### Sealing and restriction seam
Opaque diagrams cannot be read as records by their separate universal owner.
Four small read/restriction operations now live with diagram admission:
discrete_tail, without_first_edge, graph_bindings and cocone_sides.
They return only admitted, immutable values/bindings and do not call supplied
dictionary callbacks again. The finite induction uses the same remaining-node
and first-edge restrictions as before, with no extra edge scan or re-admission.
All admission records remain sealed; partition scratch stays private.
Regression checks were added inside the existing diagram failure/duality group,
including empty/edgeless cases and an armed callback that must not be sampled.
The 33-group structure and original enumeration counters remain unchanged.

### Feedback and repairs
Initial migration feedback found category record-label qualification, chosen
duality routing and wrapped test-support imports; these were corrected locally.
The first producer draft failed UTF-8 decoding before writing any changes.
An unintended same-arrow-type restriction on iso_initial was corrected before
final acceptance: it still supports the original two arrow types over one object
type. The 25 old-signature contracts now all compile against new owners.
No test-first or optimization history is claimed.

Representative faults were injected only into fresh owned disposable copies:
- Reversing dual-limit mediator direction compiled successfully, then the diagram
  oracle failed with exit 2 / cone arrow endpoints.
- Dropping the Diagrams interface compiled successfully, then the normally
  forbidden raw_graph fixture compiled with exit 0, detecting lost sealing.
Both faults were restored in their copies; production files were never mutated
for these checks. The fault checks were repeated against the final semantic state;
the subsequent change was only child-module closing-line formatting.

### Fresh final execution and limits
OCaml 5.2.1, Dune 3.24.2, bundled Python 3.12.14, Windows/Opam-Cygwin.
Normal profile; cache disabled; no user config or warning suppression.
Actual Dune 3.7 / OCaml 4.14 binaries and other platforms remain untested.

Main invocation (from the repository root, using the Stage 10 compiler environment):
```powershell
& 'F:\Stratum\TEMP\computational-category-layout-stage2-465672ca-6b27-42e9-908a-70f91ae16bbb\final.ps1' -Root 'E:\Proj\course\computational-category' -Scratch 'F:\Stratum\TEMP\computational-category-layout-stage2-465672ca-6b27-42e9-908a-70f91ae16bbb' -Snapshot 'E:\Proj\course\computational-category\.agents\cache\layout-cutover-entry-20261010-465672ca-6b27-42e9-908a-70f91ae16bbb'
```
The retained final driver runs:
- dune build --build-dir <owned scratch>/final-build --cache=disabled --no-config;
- dune runtest with the same scope/options and --force;
- the retained verify-consumers.ps1 and extra-boundaries.ps1;
- ocamlc -I <build>/default/src/.computational_category.objs/byte -c
  -impl <scratch>/api_contracts.ml -o <scratch>/api_contracts.cmo;
- structural/recovery checks, 50-file input hash recheck and git diff --check.

Observed final driver exit 0:
- Six suites / all 33 behavioral groups pass, with every original coverage counter
  equal to Stage 10 (including 576,095 functor and 1,976 indexed law triples).
- Both positive public consumers compile/link/run; all ten existing negatives
  reject for their expected boundary, exit 2.
- README prints witnesses=4, image pairs=3; guide prints
  graph product: 4 nodes, 2 edges.
- Three additional temporary consumers reject raw labelled/term records and
  retired Computational_category.Graphs specifically, exit 2.
- All 25 routed original public-signature contracts compile, including general
  helper polymorphism, concrete Make outputs and shared graph child identities.
- Actual ocamldep output confirms general theory has no concrete-instance import;
  the normal build confirms no qualified parent-alias cycle.
- Root wrapper contains only the five native groups. No legacy source, cast or
  toy-category production dependency remains; documentation file links resolve.
- Original implementation string literals/error contexts are preserved as a
  multiset; this is supporting evidence, not a proof of behavioral equivalence.
- All 53 recovery entries were reverified; all 50 tested product/test/doc inputs
  were hash-identical after execution. Ignore rules, historical audit and the
  preexisting ignored compiler artifacts remain unchanged.
- git diff --check passes; existing LF/CRLF warnings are not gate failures.

### Retained execution inputs
verification.zip in the Stage 11 snapshot retains 65 individually hash-verified
entries: 50 final delivery inputs plus 15 producer/verifier sources or results.
SHA256: 68f55b21aa8551cffa1918231fd98e1f7d7638cb2df61b318057cee9ea69483a.
verification-manifest.json binds every entry. The ZIP contains final-results.txt,
final-inputs.json, actual dependencies, 25-contract consumer, original interface
inventory, structural and mutation drivers, public/example verifier and the
three extra negative inputs. migrate.py is an intermediate ownership mapper /
producer history, not a replayable final migration; audit-api.py executes only
its mapper definitions. These files do not grant automatic execution/restore
authority. README.md in the cache states retention and recovery precautions.

### Conformance and next handoff
No Stage 11 blocker remains: accepted owners and abstraction identities survive,
general/concrete dependencies point correctly, the generic algorithm is not
duplicated, API consumers use new paths, and mathematical premises/expected
errors/exceptions remain bounded by their original contracts.
No commit, branch, worktree, installation or publication occurred.
Stage 11 is complete; Stage 12 is next, after user authorization.
Final cleanup/last-artifact observation follows after execution below.

### Exact owned-scope cleanup command

```powershell
$ErrorActionPreference='Stop'
$scratch='F:\Stratum\TEMP\computational-category-layout-stage2-465672ca-6b27-42e9-908a-70f91ae16bbb'
$snapshot='E:\Proj\course\computational-category\.agents\cache\layout-cutover-entry-20261010-465672ca-6b27-42e9-908a-70f91ae16bbb'
$resolved=(Resolve-Path -LiteralPath $scratch).Path
$temp=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')+'\'
if(-not $resolved.StartsWith($temp,[StringComparison]::OrdinalIgnoreCase) -or
 (Split-Path -Leaf $resolved) -ne 'computational-category-layout-stage2-465672ca-6b27-42e9-908a-70f91ae16bbb'){
 throw 'Unsafe cleanup target'
}
if((Get-FileHash -LiteralPath (Join-Path $snapshot 'verification.zip') -Algorithm SHA256).Hash.ToLowerInvariant() -ne
 '68f55b21aa8551cffa1918231fd98e1f7d7638cb2df61b318057cee9ea69483a'){
 throw 'Verification bundle changed'
}
Remove-Item -LiteralPath $resolved -Recurse -Force
if(Test-Path -LiteralPath $resolved){throw 'Scratch remains'}
if(-not (Test-Path -LiteralPath $snapshot) -or -not (Test-Path -LiteralPath (Join-Path $PWD '_build'))){
 throw 'Retained recovery or preexisting root build missing'
}
Write-Output 'PASS owned Stage 11 temporary tree removed; recovery snapshots and preexisting root _build remain'

```

Observed closure: the exact cleanup command exited 0. The owned Stage 11 scratch
tree is absent; both ignored recovery snapshots and preexisting root _build
remain. The 50 tested delivery inputs were rechecked unchanged after the final
plan/evidence edits. Canonical authority/status and code fences were inspected;
the plan remains tracked and diff --check passes. Historical pre-layout evidence,
ignore policy and the two older ignored compiler artifacts remain hash-identical.
No remaining Stage 11 work or conformance blocker was found. Stage 12 is not started.

## Stage 12 — Mathematical tests/navigation and LOC reduction (2026-10-10)

Authority: the latest agreement authorizes Stage 12 with a LOC-reduction
preference. No production/API/algorithm change; Stage 13 acceptance stays pending.
HEAD remains 10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c; actual dirty entry owns comparison.
Documentation serves learners/maintainers of the local 0.1.0 tree; source,
interfaces and tests own current behavior. No publication or new manual.

Six chronological suites become foundations (5 groups), universals (8),
spans/relations (7), constructions/graphs (7), functor categories (4) and
indexed/free-cofree (2). Primitive/diagram checks move out of the mixed foundation
suite. Shared checks and a bounded FinSet fixture have six/two coherent consumers
respectively; the sole toy category stays private. Repeated universal instances
collapse per supplied F. Independent oracles are not unified; no one-case files.

| Category (physical / nonblank lines) | Entry | Final |
| --- | --- | --- |
| Production .ml/.mli (24 files; byte-identical) | 2685 / 2553 | 2685 / 2553 |
| Tests .ml including private support (7 -> 9 files) | 1868 / 1809 | 1851 / 1791 |
| Test Dune wiring | 34 / 28 | 11 / 10 |
| README and Chapter 5 guide | 759 / 614 | 751 / 606 |

Net test code/wiring reduction: 40 physical lines; reader docs: 8.
Counts exclude plans, recovery archives and generated outputs. This is not a
runtime performance claim or deletion of coverage. All 34 test-function bodies
(33 groups) and 30 selected oracle/law helpers match entry modulo alias,
reject_any and indentation changes. All twelve exercise bodies remain identical
after correcting three accidentally renamed mathematical headings. Two other
general-limit sentences and the cofree API reference are repaired; no proof
premises, finite/uniform/injective qualifications or examples are removed.

Scratch: F:/Stratum/TEMP/computational-category-layout-stage3-df930505-6675-4d49-89aa-b9c680c1f07c.
Using the recorded existing compiler environment, normal profile and no warning
suppression: baseline build/forced runtest used --build-dir <scratch>/baseline-build,
--cache=disabled --no-config; final.ps1 -Root E:/Proj/course/computational-category
-Scratch <scratch> used fresh final-build with the same flags. audit.py and
closure.py verified the actual entry diff, bodies/oracles, links, all 33 group
labels and counters. Driver sources and raw outputs are retained below.

Observed exit 0: fresh final build/runtest, two public positives, ten negatives
(exit 2 at their expected type boundary), README output witnesses=4, image pairs=3,
guide output graph product: 4 nodes, 2 edges. Old map count splits 36 + 6110 = 6146;
all other enumeration counts match. Direction/sealing mutations were detected
before and after regrouping; a bad-image admission mutant also compiled and was
rejected by the shared helper (test exit 2). Faults stayed in disposable copies.
OCaml 5.2.1 / Dune 3.24.2 Windows only; minimum binaries/platforms remain untested.

Recovery/evidence reuse the existing layout-cutover-entry-20261010-465672ca-6b27-42e9-908a-70f91ae16bbb
cache directory: stage12-entry.zip captures 51 entry files plus manifest, SHA256
70ea1df6a80b71b99b0f6451492d242a68916b22492cd51519d886861861c5c5.
stage12-verification.zip contains 51 final product inputs and 20 verifier/producer/
result files (71 individually hash-verified entries), SHA256
bc14acd853665c3e0760ba0d6115c3c8d8ba34de6d556632f2eb2edf30525ec1.
stage12-entry.json and stage12-verification-manifest.json bind paths/hashes.
Producer scripts are history, not idempotent replay instructions; verifier paths
must be rebound to a reviewed owned scratch before rerunning. Retain bundles
through Stage 13; extract separately and compare newer work before any restore.
No blocker remains for Stage 12; preexisting compiler artifacts/ignore policy and
all tested product hashes were rechecked unchanged. No install/commit/publication.

Cleanup receipt: stage12-cleanup.ps1 / stage12-closure.txt in the retained cache.
Exit 0: exact owned scratch removed; recovery bundles, root _build and older
compiler artifacts retained; final product hashes and diff --check still pass.

## Stage 13 — Integrated acceptance (2026-10-10)

Latest agreement authorizes the fourth/final layout stage. HEAD remains
10ddb0c2cac79b8ef3c7433ef7a423c4f6c7262c; the dirty product tree is unchanged
from all 51 Stage 12 tested inputs. No production/test/reader-doc edit was needed.
Only canonical status and this evidence report change in the working tree.

Scratch: F:/Stratum/TEMP/computational-category-layout-acceptance-5c985ce3-de7a-440b-96a0-33f712fef95b.
With the previously recorded environment, acceptance.ps1 -Root
E:/Proj/course/computational-category -Scratch <scratch> ran ocamlc -version,
dune --version, normal dune build and forced runtest using fresh
<scratch>/final-build, --cache=disabled --no-config. It then compiled/ran
public/example fixtures, four extra boundaries and api_contracts.ml, extracted
ocamldep -modules dependencies and ran git diff --check. audit.py, topology.py
and closure.py evaluated the actual diff, structure, manifests, links and hashes.
All final drivers exited 0. Early verifier-only expectations were corrected for
the named S sealing ascription, quoted compiler module names, a missing copied
baseline log and a comment containing a retired word; no product fault was found.

Fresh results: all 33 behavioral groups and original enumeration counts match
one-to-one (36 + 6110 = 6146 map fixtures); both positives passed. Ten expected
negative type fixtures exit 2 at their intended boundaries. Extra expected
rejections cover a retired flat module, raw labelled/term records and private
test-fixture import from a standalone public library. Both documentation outputs
match. All 25 routed pre-layout public signature contracts compile, including
heterogeneous iso_initial and shared graph/child type identities.

Six complete implementation owners match the pre-layout bodies modulo namespace
routing/comments/whitespace; every implementation string literal/error context
survives. The generated wrapper exposes five native groups, no handwritten
facades/casts remain, one finite-colimit algorithm owns its dual reuse, and each
FinSet graph instance uses one concrete-universal owner. Actual ocamldep output
and its conservative resolved graph are acyclic; generic theory has no instance
or test-fixture dependency. The generated local install manifest excludes test
support; no installation was executed. All twelve exercise sections, retained
proof restrictions, local links/anchors and both complete code examples pass
inspection. Stage 12's three mutation results remain applicable by unchanged
source/test hashes; they were not re-executed as new Stage 13 mutation work.

LOC transparency versus the original dirty layout entry: implementations
2163 -> 2154 (-9), interfaces 419 -> 531 (+112), total production 2582 -> 2685
(+103); test .ml 1827 -> 1851 (+24), including the relocated toy fixture and
preserved seam regressions. Thus this is ownership/sealing repair, not an overall
source-LOC reduction. Stage 12 separately reduced test/wiring by 40 lines and
reader docs by 8; acceptance adds no production/test/doc lines.

Final retention reuses the existing cutover cache directory:
stage13-verification.zip has 79 individually hash-verified entries: 52 accepted
product inputs, verifier sources/results, dependencies/install metadata, full
pre-layout-to-final diff and the canonical/evidence entry before status updates.
SHA256: 101ce23663f782bf1cfad0e874ea461779c7c29690239cf16076b48da8314817.
stage13-verification-manifest.json binds every entry. Rebind verifier paths to a
reviewed owned scratch for any rerun; do not execute historical producers or
restore over newer work automatically. Keep all recovery bundles while changes
remain uncommitted.

No conformance blocker remains; all four layout stages are locally accepted.
Bounds: OCaml 5.2.1 / Dune 3.24.2 on Windows only; declared OCaml 4.14 / Dune 3.7
binaries, other platforms, actual installed/registry consumers, unrestricted
theorems and scalability remain unverified. No branch, commit, installation,
publication, new worktree or independent-agent task was performed.

Closure: stage13-cleanup.ps1 / stage13-closure.txt record exit 0: the exact owned
scratch is removed; all recovery bundles and preexisting build/compiler artifacts
remain. All 79 retained entries and 52 accepted product hashes were reverified.
