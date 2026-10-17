# Chapter 5 constructions and exercise solutions

## Context

Chapter 5 assembles the earlier arrows and universal maps into reusable
categories: comma objects, functor categories, indexed families, graphs, and
rewriting systems. The important deduction is compositional: each new object
is an endpoint-checked instance of an existing category or universal
construction, rather than a second representation of the same mathematics.

This chapter extends the OCaml learning library with category constructions and
their inherited finite universal maps. The source is Rydeheard and Burstall,
*Computational Category Theory*, Chapter 5, printed pp. 103–126. Exercise numbers
include the six exercises embedded in the chapter, not just §5.8.

All twelve exercises are addressed below. Programming solutions use the public
`Computational_category` namespace. General mathematical arguments are stated
separately from executable restrictions: finite enumerated functor domains,
uniform OCaml fiber representations, and elementary injective graph rewriting.
The proofs are worked mathematical arguments, not machine-checked certificates.

## Mathematical reduction

Chapter 5 turns universal constructions into reusable categories. A comma
object is an arrow in a common codomain; a comma morphism is a commuting
square. A functor category is a family of objects and arrows indexed by a
source category, with naturality as its defining equation. Graphs are a comma
instance of an incidence map, and indexed families are slice objects.

The code representation follows these deductions: endpoints are admitted before
squares are checked, finite source domains are snapshotted before naturality is
tested, and inherited limits/colimits are obtained from the corresponding
component constructions. Rewriting keeps the graph maps witnessing the double
pushout rather than returning only a changed graph.

## API example

The following complete example creates two directed multigraphs and their
product. Link it against the local `computational_category` library.

```ocaml
open Computational_category

module F = Instances.Finite_sets.Make (struct
  type t = string
  let equal = String.equal
end)
module G = Instances.Finite_graphs.Make (F)

let get = function Ok x -> x | Error _ -> failwith "example admission failed"
let value = F.atom
let graph nodes edges =
  get (G.graph ~nodes:(F.carrier_of_list (List.map value nodes))
    ~edges:(List.map (fun (e,s,t) -> value e, value s, value t) edges))

let () =
  let a = graph ["a";"b"] ["e","a","b"] in
  let b = graph ["x";"y"] ["f","x","y";"g","x","y"] in
  let product, _ = get (G.product (a,b)) in
  let p = product.Universal.Limits.prod_obj in
  assert (F.cardinality (G.nodes p) = 4);
  assert (F.cardinality (G.edges p) = 2);
  Printf.printf "graph product: %d nodes, %d edges\n"
    (F.cardinality (G.nodes p)) (F.cardinality (G.edges p))
```

Expected output: `graph product: 4 nodes, 2 edges`.
The two parallel edges remain distinct. They are not deduplicated as endpoint
pairs. Applications should match `Error` rather than use the example's `get`.

## The chapter constructions

### Comma categories and inherited colimits

For L : A → C and R : B → C, an object of (L,R) is (a,f,b) with
f : L(a) → R(b). An arrow (s,t) to (a′,f′,b′) satisfies
R(t) ∘ f = f′ ∘ L(s). Identity and composition are componentwise.

`Constructions.Comma.object_` and `arrow` admit these endpoints and squares.
The object and arrow representations are abstract.
`category`, `left_projection` and `right_projection` expose the category and
projection functors. Supplied L and R must be stable lawful functors with a
coherent common codomain; their laws are not proved by constructing records.

Theorem 3 (pp. 107–109) requires A and B finitely cocomplete and **L**
finitely cocontinuous. For a diagram with objects (aᵢ,fᵢ,bᵢ), calculate the two
component colimits, with legs λᵢ : aᵢ → a and μᵢ : bᵢ → b.
The arrows R(μᵢ) ∘ fᵢ form a cocone on L applied to the left diagram.
Preservation makes L(λᵢ) a colimiting cocone. Its unique factor gives
f : L(a) → R(b), and the resulting comma apex is (a,f,b).

For any candidate comma cocone, the two component universal maps give u and v.
To check its square, precompose both candidate arrows with every L(λᵢ);
the candidate's squares and component factorization make the results equal.
Uniqueness of the preserved left colimit makes the square commute. Uniqueness
of u and v then gives uniqueness of the comma mediator.

`Constructions.Comma.cocomplete` implements this construction.
`colimit_with_projections` also returns the two component colimit structures,
used by edge-labelled graphs without computing a second quotient.

Limits require **R** continuous. The implementation swaps the two sides in
the opposite category, transports a comma colimit back, then uses
`Universal.Limits.dual_colimit`. A type-compatible but incoherent preservation capability
is not sufficient: the returned preserved cone/cocone must match the mapped
one. Preservation and universal uniqueness remain mathematical caller premises.

### Finite graphs and the book pushout

A graph is (E,inc,N), with inc : E → N × N. A graph morphism is an edge map and
a node map preserving incidence. Thus FinGraph = (Id,X), where X(N)=N×N.
`Instances.Finite_graphs.Make(F)` instantiates this comma category, its finite
(co)completeness, and products.

This differs from `Universal.Diagrams.graph`: the latter is a finite **labelled diagram
shape**, while `G.graph` is an object of the category of finite multigraphs.
Its explicit finite edge bindings retain loops, isolated nodes and parallel edges.
Node/edge sets use F's equality; duplicate edge identifiers are rejected.

The graph API is `graph_morphism src ~edges ~nodes tgt`; its
constructor checks both graph endpoints and the incidence square. The
fixed-node subcategory uses `Fixed.fixed_morphism`. Labelled graphs use
`Labelled.labelled_morphism` and expose `underlying_morphism` for forgetting
labels. These names distinguish graph-owned morphisms from the generic
`Constructions.Comma.arrow`, whose shorter name remains the direct abstract
comma construction.

In definition form, a graph morphism `(e,n):G→H` is admitted exactly when
`inc_H ∘ e = (n × n) ∘ inc_G`; the implementation delegates the product and
composition checks to the supplied finite category capabilities rather than
re-proving them in the graph layer.

The book's graph pushout (pp. 110–113) has four nodes and five edges. Its OCaml
regression constructs the input graphs and maps, computes the pushout and checks
a graph isomorphism to the book's incidence pattern, with both inverse equations
and mediator equations. Particular nested tags or representative names are not
the specification: graph objects are compared through their structure and maps.

### Functor categories and pointwise universals

`Constructions.Functor_category.finite_domain` admits an enumerated source category.
It checks identities, endpoints, closure and associativity over that enumeration.
The enumeration must cover the **intended** finite category or chosen closed
subcategory; it does not discover every object/arrow of an ambient category.

`finite_functor` snapshots object/arrow maps once per admitted key and checks
identity, endpoints and composition. `natural_transformation` snapshots components and checks
every naturality square. Equality is extensional on the admitted source, not
equality of callbacks. `category` uses vertical composition;
`horizontal` constructs the diagonal described on pp. 114–116:

β(F′a) ∘ G(αa) = G′(αa) ∘ β(Fa).

The right-hand route equals the left-hand route by β's naturality.
Outside-enumeration queries return a typed error. Empty source categories work.

Theorem 4 (pp. 116–118) computes a diagram's colimit pointwise in B.
The implementation caches each point's colimit once. For f : a → a′,
the sides λᵢ(a′) ∘ Dᵢ(f) give a cocone on D(a); its unique factor defines
the resulting functor's arrow map. Uniqueness proves its identity/composition
laws and the naturality of the injections. A candidate cocone factors
pointwise; uniqueness also proves those components form a natural
transformation and that it is the unique mediator.

`cocomplete` implements this construction for finite enumerated A.
`complete` obtains limits through the simultaneous source/target opposite
isomorphism. The general theorem applies to small sources with the required
chosen pointwise (co)limits; arbitrary infinite sources are not an executable
equality/admission claim of this library.

### Abstract fixed shape structures

Section 5.7 (pp. 120–124) treats the base functor β : Cocones(C) → Diagrams(C).
A colimit is a free object over a diagram for β; equivalently, choosing all of
them gives a left adjoint. Limits use a right adjoint.

For a fixed labelled shape, `Universal.Diagrams.diagram_arrow` admits natural diagram
maps. `cocone_map` and `cone_map` include both a base-diagram map and an apex
map. They are not the existing fixed-base universal `cocone_arrow`/
`cone_arrow` types.

`Universal.Limits.Free.fixed_colimit` returns the chosen free cocone, its unit and a
factorization operation for **arbitrary admitted base morphisms**, not merely
identity-base cocones. Given η : D → base(c), precompose c's sides with η
and apply D's ordinary colimit universal map. The factor's base is η, and the
unit equation follows. Its uniqueness is the ordinary colimit uniqueness.
`Universal.Limits.Cofree.fixed_limit` is the cofree version, reversing the base-arrow direction.

At the general 2-categorical level, diagram/cocone constructions must act on
categories, functors and natural transformations, preserving identities,
vertical and horizontal composition. The base transformation must respect
those actions. For a fixed shape, componentwise pairing/splitting gives the
product/comma commutation isomorphisms; evaluating at each source object gives
the functor-category commutation isomorphism. Morphisms and their equations
are sent componentwise, so the inverse maps and the required commutations
follow at the same time. A family of these structures, one for each allowed
shape, gives the indexed treatment of §5.7.3.

The executable adapter exercises the fixed-shape free/cofree operations.
It does not encode all of Cat as an OCaml universe or certify every
2-functor/adjunction law. These additional general laws are part of the
mathematical structure, not consequences of the adapter record type.

## Exercise 1 Indexed sets

Source: p. 106. For a family (Sᵢ) indexed by A, form the **tagged** disjoint union
X = {(i,s) : i∈A, s∈Sᵢ}, and define p(i,s)=i. Tags are essential: equal
unlabelled elements belonging to different fibers must not collapse.

Conversely, p : X → A determines Sᵢ = {x∈X : p(x)=i}.
Starting from p, the map x ↦ (p(x),x) is a bijection over A with inverse
(i,x) ↦ x. Starting from a family, each original Sᵢ is naturally bijective
to the corresponding fiber of the tagged union. These are equivalences of
representations, not literal equalities of encodings.

A family map consists of maps Sᵢ → Tᵢ. It induces (i,s) ↦ (i,hᵢ(s)),
which commutes with projection to A. Every commuting map over A restricts to
these fiber maps. Thus the category is Set/A = (Id,K_A), with
K_A : 1 → Set constant at A.

Program surface: `Constructions.Elementary.slice`, `Constructions.Comma.object_`
and `arrow`; finite payloads can retain their index with `F.pair`.
This representation does not turn arbitrary heterogeneous OCaml element types
into a common type by casting.

## Exercise 2 Cones as comma objects and the limit functor

Source: p. 106. Fix a small source J and D : J → C.
Let Δ : C → C^J be the diagonal functor and K_D : 1 → C^J constant at D.
A comma object (x,α,*) of (Δ,K_D) is exactly a cone α : Δx → D.
A comma arrow (u,id_*) satisfies α = α′ ∘ Δu, precisely the cone-arrow
triangle. This identifies the fixed-base cone categories.

For each diagram D choose a limiting cone H(D), with legs λᵢᴰ.
For η : D → E, the sides ηᵢ ∘ λᵢᴰ form a cone on E.
Its unique factor u : lim D → lim E defines H(η) in the category of cones
with varying base: it has base η and apex u. For an identity base map,
identity is the unique factor. For η then θ, both the composite factors and
H(θ∘η) have the same projection equations, so uniqueness equates them.
Thus H is a functor into the total cone category; forgetting its base and
sides gives the usual limit functor into C.

Program surface: `Constructions.Functor_category.diagonal` and comma builders for finite J;
`Universal.Limits.map_limit` takes the base morphism and two already calculated
limiting cones and returns the admitted variable-base cone map.
General functor object maps now return `result`, as arrow maps do; chosen
colimit/limit computations need no falsely total object callback. This explicit
universal-map operation remains useful when the two cones are already known.
Tests cover the comma representation and identity map; the argument above
gives composition.

## Exercise 3 Products of graphs

Source: p. 106. For G and H, take nodes N_G×N_H and edges E_G×E_H.
The edge (e,f) has source (s_G(e),s_H(f)) and target (t_G(e),t_H(f)).
The projections preserve incidence, so they are graph morphisms.

For graph morphisms u : K → G and v : K → H, pair their edge maps and their
node maps. The pair is a graph morphism because both source/target equations
hold componentwise. It factors through both projections; any other factor
has the same edge and node coordinates and therefore equals it.

Program: `Instances.Finite_graphs.Make(F).product`. It uses the inherited complete
comma category and `Universal.Limits.product`, not another graph-product algorithm.
Its chosen encoding can be isomorphic to, rather than literally the same
as, the elementary pair representation above. The example at the start and
tests check counts and universal projection equations, including empty graphs.

## Exercise 4 Continuity of the square functor

Source: p. 119. Suppose λᵢ : P → Dᵢ is limiting. Apply X(a)=a×a.
For a cone kᵢ : Z → Dᵢ×Dᵢ, projecting each kᵢ yields two cones on D.
Their unique factors are u,v : Z → P. The paired map ⟨u,v⟩ factors
the original cone through X(λᵢ). Conversely, the two projections of any such
factor are forced to be u and v, so the factor is unique.

This includes the empty diagram: P is terminal and P×P is again terminal
up to its unique isomorphism. No special atom type or unit encoding is required.

Program: `Instances.Finite_set_universals.Make(F).product_continuous`.
It projects a candidate cone, calls the original universal map twice, pairs
the answers and admits the result. **Do not** substitute cocontinuity:
X generally does not preserve coproducts (a singleton coproduct has two
elements, whose square has four; two singleton squares have coproduct size two).

## Exercise 5 Canonical duality isomorphisms

Source: p. 120, Propositions 5–6 on pp. 118–120.

For comma categories, define Φ : (L,R)^op → (R^op,L^op) by
(a,f,b) ↦ (b,f,a). An opposite comma arrow is sent by swapping its two
components and its source/target objects. The reversed square in C^op
is the same underlying commuting square in C. Swapping twice gives the
identity on both objects and arrows; composition and identities are preserved.

The defining conditions include:
1. the left projection after Φ is the opposite right projection, and vice versa;
2. the distinguished connecting transformation is the opposite original
   connecting transformation, under that swap.

Projections alone do **not** determine the connecting arrow. Together these
conditions determine an image object's two endpoints and its connecting arrow.
They determine an image arrow's two components as well. The comma universal
characterization therefore forces Φ; its explicit inverse proves it an
isomorphism. `dual_to_swapped` and `swapped_to_dual` implement these maps.

For functor categories, Θ : (B^A)^op → (B^op)^(A^op) sends F to its
simultaneous opposite and reverses a natural transformation's direction while
retaining each underlying component. Naturality in the opposite is the
original naturality equation reversed. It respects vertical composition and
has the same operation as inverse.

The defining condition is compatibility with **all evaluation data**: evaluation
at objects and the evaluation natural transformations associated with arrows
of A. Object evaluations fix F(a); arrow evaluations fix F(f); evaluations of
natural transformations fix their components. Consequently the functor-category
universal characterization forces Θ. Merely fixing object evaluations would
not force all the arrow maps.

These are uniqueness statements for the specified literal constructions and
their complete universal data. With different chosen presentations, the
corresponding comparison is uniquely determined up to the appropriate natural
isomorphism. Tests check the explicit inverse equations, not this general
higher-universal uniqueness theorem.

## Exercise 6 Limits in functor categories

Source: p. 120. For D : J → B^A, set P(a)=lim D(a).
For f : a → a′, the sides Dᵢ(f) ∘ λᵢ(a) form a cone on D(a′);
its unique factor defines P(f). Uniqueness proves identity and composition.
The λᵢ are natural transformations. Every candidate cone factors pointwise,
and its factor is natural by the same uniqueness argument. Pointwise uniqueness
then gives the universal limit in B^A.

Program: `Constructions.Functor_category.complete` implements this through Θ from
Exercise 5, the pointwise colimit implementation, and duality. It reverses both
the source category and target category, and reverses natural transformations.
It does not implement a second independent pointwise-limit algorithm.
Tests check product/pullback equations and selected exhaustively unique mediators.

## Exercise 7 Product categories

Source: p. 124. Objects and arrows of A×B are pairs; sources, targets,
identities, equality and composition are componentwise. Identity and associativity
follow from the two category laws. A diagram projects to D_A and D_B.
Its colimit has apex (colim D_A,colim D_B) and paired legs; a candidate cocone
factors by the pair of component mediators. Both are uniquely forced.
The same proof with arrows reversed gives limits.

Program: `Constructions.Elementary.product`, `cocomplete_product`,
`complete_product`, `first` and `second`.
These reuse the supplied component capabilities and checked diagram builders.
They neither infer preservation from arbitrary functors nor use closure equality.

## Exercise 8 Twisted arrow categories

Source: p. 124. For f : a → b and f′ : a′ → b′, an arrow is
(h : a → a′, k : b′ → b) satisfying f = k ∘ f′ ∘ h.
The reversed direction of k is essential.

For (h₁,k₁) followed by (h₂,k₂), compose as
(h₂∘h₁, k₁∘k₂). Its square holds because
k₁∘k₂∘f₂∘h₂∘h₁ = k₁∘f₁∘h₁ = f₀.
Identity is (id_a,id_b). The laws follow from associativity/identity in C,
including the reversed order on the second component.

Program: `Constructions.Elementary.Twisted.arrow` checks the endpoints and square;
`category` supplies this composition. No string-name or callback equality
stands in for the original category's arrow equality.

## Exercise 9 Coslice coproducts

Source: p. 124. In (K_a,Id), the constant **left** functor need not preserve
colimits: it sends the initial object of 1 to a, which need not be initial in A.
Consequently Theorem 3 cannot simply be invoked. This differs from the slice
case, where the constant functor is on the right.

For objects f : a → x and g : a → y, form their pushout p : x → P,
q : y → P. Its connecting map is p∘f = q∘g : a → P.
These are coproduct legs in the coslice. A coslice cocone h,k satisfies
h∘f = k∘g, so the pushout's unique factor is exactly the required coslice
mediator. Thus the coslice coproduct is a pushout, not an ordinary disjoint union.

Program: `Constructions.Comma.coslice_coproduct`, with
`Constructions.Elementary.one` and the underlying cocomplete capability.
A finite regression identifies the shared anchor: two two-element targets
produce a three-element coslice coproduct, not a four-element disjoint sum.

## Exercise 10 Edge labelled nondeterministic automata

Source: pp. 124–125. The structural graph of an NFA with alphabet A is a
finite graph G plus a function E_G → A. An arrow is a graph map whose
edge map commutes with these labellings. These are exactly comma objects/arrows
in (Edges,K_A). The Edges projection preserves graph colimits because the
edge sets and universal maps in the graph colimit are the corresponding
FinSet colimits. Hence Theorem 3 applies.

Program: `Instances.Finite_graphs.Make(F).labelled`, `labelled_morphism`,
`labelled_category` and `labelled_cocomplete`.
The implementation retains the graph construction's edge colimit evidence;
its universal map creates the output labels. A quotient cannot identify
incompatible labels in an admitted labelled diagram.

This structural category alone has **no initial/final states**. For language
recognition, add those designated subsets. For epsilon transitions, extend the
alphabet or explicitly represent epsilon. Disjoint coproducts give the graph
part of union, with unions of designated states. Standard concatenation can
use fresh epsilon transitions from first final states to second initial states;
gluing an exit and entry by pushout is suitable only under the corresponding
entry/exit restrictions. Star likewise needs added entry/exit, bypass/loop
transitions and acceptance choices. Unrestricted identification of states can
change the language; a graph colimit by itself does not prove regular-expression
semantics. DFA transition algebras and a regex/NFA compiler are not implemented.

## Exercise 11 Elementary graph grammar operations

Source: p. 125. The following precise double-pushout solution uses injective
rule legs and an injective match, rather than silently assuming all rewriting
variants have the same operations.

A rule is L ← K → R: K is the preserved interface. A match m : L → G
locates the occurrence. Delete from G exactly the image of L's nodes and edges
outside K. If a retained edge touches a deleted node, reject the operation
(the dangling condition). Otherwise the remaining incidence relation defines
a graph D and maps K → D → G.

Injectivity ensures the images of L and D intersect precisely in K, and their
union is G on both nodes and edges. These bijections preserve incidence, so
L ← K → D has pushout G: D is a pushout complement. Form the second pushout
D ← K → R to obtain the rewritten graph G′. The existing graph universal
construction supplies its arrows and mediators.

Program: `G.Rewriting.rewrite ~interface_to_left ~interface_to_right ~matched`.
It returns the context, rewritten graph, context-to-host map and the two maps
into the output. Invalid endpoint, noninjective and dangling cases return typed
errors. Tests include deletion/addition and refusal of a dangling edge.
There is no automatic match enumeration, noninjective rule semantics or
complete graph-grammar language. These are genuinely additional variants,
not consequences of this elementary program.

## Exercise 12 Indexed categories and both inheritance propositions

Source: pp. 125–126. Let F : C → Cat be a strict indexed category.
Write T_f=F(f). Objects of its Grothendieck category are (c,x);
arrows (f,g) : (c,x) → (d,y) have g : T_f(x) → y in F(d).
For a following (h,k), composition is (h∘f, k∘T_h(g)).
Strictness makes its source T_(h∘f)(x). Identity and associativity follow
from functoriality of F and the fiber category laws.

Program: `Constructions.Indexed.Make(I)` admits indexed objects and
`indexed_morphism` values. Its constructor checks base endpoints, transport,
fiber membership, and transported fiber endpoints before returning the
result-valued morphism.
`valid_object` owns fiber membership; each selected fiber's dictionary checks
payload endpoints and equality. All fibers use one OCaml object/arrow
representation. General dependent/heterogeneous fibers are covered by the
argument, not erased into a runtime universal payload.

### Proposition 7 Colimits

Assume C and every F(c) have the required colimits and every T_f preserves them.
For a diagram (cᵢ,xᵢ), let λᵢ : cᵢ → c be its base colimit.
Move xᵢ to T_λᵢ(xᵢ) in F(c). For an edge (fᵢⱼ,gᵢⱼ), the moved arrow is
T_λⱼ(gᵢⱼ); its source is T_(λⱼ fᵢⱼ)(xᵢ)=T_λᵢ(xᵢ).
Strictness and the original diagram equations give a diagram in F(c).

Take its fiber colimit z, with legs σᵢ. Then (c,z) with
(λᵢ,σᵢ) is a cocone in G(F).

For another cocone into (d,y), the base universal map gives a unique u : c → d.
Preservation makes T_u(z) the colimit of the transported fiber diagram.
The candidate's fiber legs are a cocone on that diagram, since
T_u T_λᵢ=T_(u λᵢ). Its unique factor q : T_u(z) → y gives (u,q).
Both components are uniquely forced, proving the universal property.

Program: `G.cocomplete` takes the base colimit capability, fiber capabilities
and their transport-preservation maps. The returned preserved cocone is checked
against the actual mapped cocone before its universal map is used.

### Proposition 8 Limits

Assume C and every F(c) have the required limits and each T_f has a chosen
right adjoint R_f with natural inverse transposition bijections
Hom(T_f a,b) ≅ Hom(a,R_f b). This is stronger data than an arbitrary
type-compatible pair of functions.

For the base limit λᵢ : c → cᵢ of the projected diagram, put
yᵢ=R_λᵢ(xᵢ) in F(c). For an edge (fᵢⱼ,gᵢⱼ), define yᵢ → yⱼ as the
λⱼ-adjoint transpose of

gᵢⱼ ∘ T_fᵢⱼ(ε_λᵢ,xᵢ) : T_λⱼ(yᵢ) → xⱼ.

Here ε is the adjunction counit and λⱼ=fᵢⱼ∘λᵢ.
These arrows form a diagram: the untransposed composite for two consecutive
edges is
gⱼₖ ∘ T_fⱼₖ(gᵢⱼ) ∘ T_(fⱼₖ fᵢⱼ)(ε_λᵢ,xᵢ),
the same arrow used for their composite edge. This follows by the defining
transpose/counit equation and naturality. Bijectivity then equates the
transposed composites; the identity case follows from the same equation.

Take z=lim yᵢ in F(c). Untranspose each projection z → R_λᵢ(xᵢ) to
obtain T_λᵢ(z) → xᵢ. Together with λᵢ these form a cone from (c,z).

A candidate cone from (d,w) gives a unique base map u : d → c.
Its fiber legs T_(λᵢ u)(w) → xᵢ transpose to a cone from T_u(w) to yᵢ.
The fiber limit gives a unique q : T_u(w) → z. The map (u,q) is the
required mediator; natural inverse transposition verifies the original
triangles. Base uniqueness and fiber uniqueness prove total uniqueness.

Program: `G.complete` uses right-adjoint records (`right`, `to_right`,
`from_right`). It checks visible endpoints in both transpose directions.
Naturality, inverse bijection laws and strict indexing are caller premises,
not inferred from those endpoint checks. The test transport is nonidentity:
constant empty set with right adjoint constant terminal set, along the
nonidentity arrow of a Boolean base. Tests include both inherited universals,
selected exhaustive mediator uniqueness and rejection of an invalid mate.

For nonstrict indexing, chosen comparison isomorphisms must be included
coherently. The strict uniform implementation does not silently substitute
identity comparisons for a general pseudofunctor.

## Verification boundaries

All 33 groups run in six mathematical suites; [README navigation](../README.md#verification-and-limits)
links each subject to its tests. [Constructions](../tests/constructions_test.ml),
[functor categories](../tests/functor_category_test.ml) and
[indexed/free-cofree structures](../tests/indexed_test.ml) exercise this chapter.
Finite-functor laws enumerate 18 walking-arrow functors over subsets of two
atoms; their natural-transformation category supplies 576,095 composable
associativity triples. Construction checks include 101 law triples; indexed
checks include 1,976. The pointwise suite enumerates three selected
unique-mediator cases, including a nonconstant functor; the indexed suite
enumerates two. These numbers include repeated test fixtures and are
not an exhaustive theorem about arbitrary input.

The book graph pushout is tested through an explicit incidence-preserving
isomorphism, not raw tag equality. Other checks cover frozen callbacks, invalid
naturality/squares, empty categories/graphs, labels, rewriting refusal, and
nonidentity indexed transport. Mathematical proofs above establish their stated
conclusions under their assumptions; finite tests provide bounded implementation
evidence. Neither proves the supplied callback laws or certifies all platforms,
unbounded work, arbitrary higher-universe encodings or formal correctness.
