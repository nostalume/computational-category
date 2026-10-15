# Chapter 6: adjunctions and terminating free algebras

## Context

An adjunction turns two families of universal problems into one reversible
hom-set calculation. That calculation explains why comma constructions,
components, preservation, and algebraic free constructions can share one API.
The executable model therefore treats units, counits, factors, and algebra
homomorphism squares as checked mathematical data, while termination bounds
remain explicit premises.

This learner guide covers the definitions, graph components, initial objects,
exercises **1–12**, and preservation by adjoints in Rydeheard and Burstall,
*Computational Category Theory*, printed pp. 127–154. The supplied PDF's printed
page number is 13 less than its one-based PDF page number. These are construction
arguments under explicit laws, not machine-checked proofs.

Exercises 10–11 are implemented against the general adjunction capability below.
The starred investigations 13–16 have bounded research dispositions at the end
of this guide, but no production implementation is claimed for them.

## Conventions and capabilities

Write `F:B→A ⊣ G:A→B`; composition `g f` means **g after f**. The unit is
`η:I_B→GF` and the counit `ε:FG→I_A`. General category dictionaries and functors
must be lawful and coherent; chosen universal arrows and callbacks must be stable
and terminating. Their uniqueness and the naturality laws are premises.

[Universal.Adjunction](../src/universal/adjunction.mli) owns one abstract
`adjunction` capability:

- `of_universal ~right choose` supplies, for each `b`, an object `F b`, an arrow
  `η_b:b→G(F b)`, and the unique factor of any `h:b→G a`.
- `of_unit_counit ~left ~right ~unit ~counit` supplies the two functors and
  natural components satisfying `ε_(F b) F(η_b)=id_(F b)` and
  `G(ε_a) η_(G a)=id_(G a)`. It uses the same factorization representation.
- `transpose adj b a h` takes `h:b→G a` to `h#:F b→a`;
  `untranspose adj b a k` returns `G(k) η_b`.
- `unit`, `counit`, `left`, `right`, `universal`, `identity`, and `dual` expose
  those capabilities. The dual is `G^op ⊣ F^op`, with unit/counit exchanged.

Object and arrow maps return `result`. Selected unit/factor endpoints and factor
triangles are checked. `Foundations.Functor.natural_component` checks a selected
component's endpoints; `check_naturality` and `Adjunction.check_triangles` check
selected equations. These operations do **not** prove global laws or uniqueness.
Supplier errors and exceptions propagate unchanged. There is no equality test
between arbitrary infinite-domain component functions; the existing frozen
finite-domain transformations in `Constructions.Functor_category` have a separate
admission responsibility.

### Why the two descriptions agree (pp. 128–131)

From universal arrows define `F(f)=(η_(b') f)#` for `f:b→b'`. Both `F(id_b)`
and `id_(F b)` factor `η_b`, so uniqueness gives the identity law. Both
`F(g f)` and `F(g) F(f)` factor `η_(b'') g f`, giving composition. The defining
factor equation is naturality of `η`. Set `ε_a=(id_(G a))#`; its factor equation
is the right triangle. The identity and `ε_(F b) F(η_b)` factor the same unit,
giving the left triangle. Similarly, for `u:a→a'`, the two sides of counit
naturality factor `G(u)`, so uniqueness equates them.

Conversely define `h#=ε_a F(h)`. Naturality of `η` and the right triangle give
`G(h#) η_b=G(ε_a) GF(h) η_b=G(ε_a) η_(G a) h=h`.
For `k:F b→a`, naturality of `ε` and the left triangle give
`(G(k) η_b)#=ε_a FG(k) F(η_b)=k ε_(F b) F(η_b)=k`.
Thus transpose/untranspose are inverse, and the universal factor is unique.

## Exercise 1 — projection-preserving comma isomorphism (p. 131)

An object of `(F,I_A)` is `(b,k:F b→a,a)`. Send it to
`(b,G(k) η_b,a)` in `(I_B,G)`, leaving each morphism's pair `(u,v)` unchanged.
The comma equation `v k=k' F(u)` becomes
`G(v) G(k) η_b=G(k') η_(b') u` by functoriality and naturality.
The reverse object map uses `h#`. The hom bijection above makes both composites
identities on objects; they already preserve the morphism pairs. This is an
isomorphism preserving both projections, not merely equivalent categories.

Conversely let such an isomorphism `J` and inverse be supplied. Its object action
gives a bijection `ψ_(b,a):Hom_A(F b,a)→Hom_B(b,G a)`. A comma morphism
`(id_b,v)` from `k` to `v k` shows `ψ(v k)=G(v) ψ(k)`; the morphism `(u,id_a)`
from `k' F(u)` to `k'` shows `ψ(k' F(u))=ψ(k') u`. These are the two naturality
laws of the bijection. Set `η_b=ψ(id_(F b))` and
`ε_a=ψ⁻¹(id_(G a))`. The laws give `ψ(k)=G(k) η_b` and
`ψ⁻¹(h)=ε_a F(h)`, hence the inverse equations yield both triangles and the
previous adjunction description.

Programs: `Constructions.Comma.adjunction_forward`, `adjunction_backward`, and
`adjunction_of_isomorphism ~left ~right ~forward ~backward`. The last requires
lawful inverse, projection-preserving functors; it checks the projections of the
objects used to recover unit and counit, not all objects of an arbitrary category.

## Exercises 2–3 — floor and ceiling (p. 132)

The ordered sets ℤ and ℝ are thin categories: a unique arrow `x→y` exists iff
`x≤y`. For the inclusion `U:ℤ→ℝ`,

`ceil(r)≤n ⇔ r≤U(n)` and `U(n)≤r ⇔ n≤floor(r)`.

For the first equivalence, an integer above `r` is above the least such integer;
for the second, an integer below `r` is below the greatest such integer. Therefore
`ceil ⊣ U ⊣ floor`. Monotonicity supplies the functor laws. The ceiling unit is
`r≤U(ceil r)` and its counit `ceil(U n)=n`; the floor unit is `n=floor(U n)`
and its counit `U(floor r)≤r`. All naturality/triangle equations then hold because
each relevant hom set has at most one arrow. “Below/above” includes equality.

The OCaml values in the complete example below solve the programming part on
**exact finite chains**: integers `−2,…,2` and half-integers `k/2` for
`k=−4,…,4`. Both rounding functions land in the integer chain. They do not encode
all reals as floats, nor promise unbounded machine-integer arithmetic. Negative
odd numerators need correction because OCaml integer division truncates to zero.

## Graph components (pp. 132–134)

The book's functor `D(S)=(S,S,id,id)` has **one loop per vertex**, not zero edges.
`Instances.Finite_graphs.Make(F).loop_graph_functor` names that convention.
For `g=(N,E,s,t)`, let `q:N→C(g)` coequalize `s,t`. Its equivalence classes are
exactly semipath-connected components. A graph map to `D(S)` has node map `f`
satisfying `f s=f t`, and its edge map is necessarily `f s`. The coequalizer
gives a unique `u:C(g)→S` with `u q=f`. The unit has node map `q` and edge map
`q s=q t`. Thus `C ⊣ D`; mapping graph arrows and the counit follow from the same
universal construction. `components_adjunction` reuses the existing FinSet
coequalizer, retaining that instance's value universe and representative choices.
The empty graph gives the empty quotient; parallel edges and loops do not create
extra components. This is undirected semipath connectivity, not strong connectivity.

## Exercise 4 — colimits and total cocones (p. 138)

Fix a finite shape `J` and a category `C` with chosen colimits of diagrams of
that shape. Let `Diag_J(C)` have diagram morphisms, and `CoCone_J(C)` be the
**total** cocone category: a morphism `(u,h):(d,c)→(d',c')` consists of a
diagram map `u:d→d'` and apex map `h`, with `h c_n=c'_n u_n`.
Forgetting the apex/legs gives `V:CoCone_J(C)→Diag_J(C)`.

Send `d` to its chosen colimiting cocone `L(d)`. For any cocone `c'` over `d'`
and diagram map `u:d→d'`, the legs `c'_n u_n` form a cocone on `d`. Its unique
colimit mediator is the apex part of a unique morphism `L(d)→c'` over `u`.
This supplies `L ⊣ V` and its action on arrows. The unit's base map is `id_d`;
the counit has base `id_(d')` and the unique apex map into the supplied cocone.
This is not an assertion that the apex alone is an object of the cocone category.

Program: `Limits.Free.adjunction (Limits.Free.fixed_colimit cat shape colimit)`.
With a finitely cocomplete capability, pass its `cc_cat` and `cc_colimit` as
shown below. `Limits.Cofree.adjunction` supplies the dual construction on total
cones using the existing opposite-category machinery.

## Exercise 5 — postcomposition and pullback (p. 139)

Let `h:a→b` in a category with chosen pullbacks. `Σ_h:C/a→C/b` sends
`p:x→a` to `h p`, with the same underlying morphism. For `v:y→b`, choose the
pullback `P=a×_b y` with `p₁:P→a`, `p₂:P→y`, so `h p₁=v p₂`.
Define `h*(v)=p₁`. A morphism `r:v→v'` lifts uniquely along
`(p₁,r p₂)` to a morphism of the pullbacks; uniqueness gives functoriality.

A morphism `Σ_h(p)→v` is precisely `r:x→y` with `h p=v r`. Its transpose into
`h*(v)` is the unique pullback map with projections `(p,r)`. Conversely compose
a slice map with `p₂`. Pullback uniqueness makes these inverse, proving
`Σ_h ⊣ h*`. The unit at `p` is the lift of `(p,id_x)` into the pullback of
`h` and `h p`; the counit at `v` is `p₂`. The triangle identities follow from
the inverse formulas. Program: `Elementary.slice_postcompose complete h`;
the current adapter takes a complete capability and reuses its chosen pullback.

For `C=Set`, write `X_i=p⁻¹(i)`. Postcomposition leaves the carrier unchanged
and its `b`-fiber is the disjoint union of `X_i` over all `i` with `h(i)=b`.
Pullback of a `b`-indexed family `Y` has carrier
`{(i,y) | h(i)=v(y)}`, with `a`-fiber `Y_(h(i))`. A noninjective `h` can
duplicate fibers: it does not quotient or identify their elements. An empty
preimage contributes an empty fiber. Morphisms act fiberwise by the same formulas.

## Exercise 6 — carrier and product (p. 139)

For a category with chosen binary products, `Σ_a:C/a→C` forgets the indexing
arrow. Define `Π_a(c)=(π₂:c×a→a)`. On `u:c→c'`, use the product map whose
projections are `u π₁` and `π₂`. For `p:x→a`, the bijection is

`Hom_C(x,c) ≅ Hom_(C/a)(p,π₂:c×a→a)`.

It takes `r` to the product pairing `⟨r,p⟩`, with inverse `k↦π₁ k`.
The second projection equation is exactly the slice condition; the first and
product uniqueness give the inverse equations. Therefore `Σ_a ⊣ Π_a`, with
unit `⟨id_x,p⟩` and counit `π₁`. Program:
`Elementary.slice_carrier cat chosen_product a`. For FinSet, the right adjoint
has one copy of `c` for each index in `a`; the empty index has empty product.

## Preservation by adjoints (Proposition 9, pp. 140–141)

Let `λ_n:d_n→l` be a colimit and let `β_n:F(d_n)→a` be a cocone. Naturality of
`η` shows the legs `G(β_n) η_(d_n)` form a cocone on `d`, hence determine a
unique `v:l→G(a)`. Transpose it to `v#:F(l)→a`. Naturality of the hom bijection
in its first argument gives `v# F(λ_n)=β_n`. Conversely any mediator of the
mapped cocone untransposes to a mediator of the original cocone, so it equals
`v` and hence its transpose equals `v#`. Thus **left adjoints preserve existing
colimits**. Applying this argument to `G^op ⊣ F^op` shows right adjoints preserve
existing limits. Neither statement asserts that every required (co)limit exists.

Programs: `Universal.Preservation.adjoint_cocontinuous` and `adjoint_continuous`.
They map and factor the supplied universal cocone/cone, rather than search for
or independently reconstruct a second universal algorithm. The empty shape
also proves preservation of initial/terminal objects when those exist.

## F-algebras and exercise 12 — created limits (pp. 142, 152)

An algebra of an endofunctor `F:C→C` is `(a,α:F(a)→a)`. A homomorphism
`h:(a,α)→(b,β)` satisfies `h α=β F(h)`. Identity and composition satisfy the
square by functoriality, so these form a category with carrier forgetful functor.
`Constructions.Algebras` admits abstract objects and
`algebra_morphism` values with these endpoint/square checks, and exposes
`category` and `forgetful`. The constructor checks
`h ∘ α = β ∘ F(h)` after validating the carrier endpoints.

For a diagram of algebras, take its underlying limit with projections `p_n:l→a_n`.
The arrows `α_n F(p_n):F(l)→a_n` form a cone: for a diagram homomorphism `h`,
`h α_n F(p_n)=α_m F(h) F(p_n)=α_m F(p_m)`. The underlying limit's unique
mediator gives `α:F(l)→l`, making every `p_n` an algebra homomorphism.
For another algebra cone, its underlying mediator `u` is a homomorphism because
the projections of `u β` and `α F(u)` agree; limit uniqueness equates them.
Underlying uniqueness also gives uniqueness among algebra maps. This includes
the empty diagram (the terminal algebra). **F need not preserve limits.**

Program: `Algebras.complete f complete_category` supplies finite limits using
the existing limit capability. It checks the full algebra-diagram base before
forgetting: different structures on equal carriers are not interchangeable.

## Theorem 5 — iterated coproducts (pp. 143–145)

Assume countable coproducts and their preservation by `F`. Let
`T(a)=Σ_(n≥0) F^n(a)`, with injections `ι_n`. Preservation makes the legs
`F(ι_n)` a coproduct, so there is a unique `α:F(T(a))→T(a)` satisfying
`α F(ι_n)=ι_(n+1)`. The generator is `ι_0`.
Given an algebra `(b,β)` and `h:a→b`, define `ν_0=h` and
`ν_(n+1)=β F(ν_n)`. Coproduct universality gives a unique `u` with
`u ι_n=ν_n`. Comparing composites with every `F(ι_n)` proves `u α=β F(u)`.
Conversely a homomorphism extending `h` has exactly these composites by
induction, so is this unique `u`. Thus the construction is free.

The executable `Algebras.Free.coproduct` covers the **eventually initial** case.
It recognizes the initial arrow into each iterate by a checked inverse. It then
uses a finite discrete colimit (including that last initial summand), and a
supplied `Preservation.cocontinuous_functor` to construct the structure. The
omitted next summand is initial because F preserves initial objects. Its map
is composed through the recognized initial-object isomorphism, not identified
with a potentially different chosen zero. `Preservation.by_comparison` can
provide this capability by recomputing an image colimit and checking that its
comparison to the mapped apex is invertible; this costs an extra colimit, rather
than pretending preservation is known from object equality.

The returned `Adjunction.universal_arrow` contains the admitted algebra as
`free_object`, the generator as `unit_arrow`, and checked homomorphism `factor`.
It can feed `Adjunction.of_universal ~right:(Algebras.forgetful f)` directly.
No second free-object representation is introduced. A work bound is required;
exhaustion returns `Category.Iteration_limit bound`. Neither a bound nor an
equal-looking pair of iterates establishes eventual initiality.

## Exercise 7 — terminating omega-chains (p. 150)

Suppose `f_n:a_n→a_(n+1)` is invertible for all `n≥N`. The apex `a_N` is a
colimit: for `i<N`, its leg is the composite of the forward arrows into `a_N`;
for `i>N`, its leg is the inverse of the forward composite from `a_N` to `a_i`.
These legs commute with each `f_i`. For a compatible omega-cocone with legs
`q_i`, the unique mediator is `q_N`: the forward and inverse formulas force
`q_i=q_N λ_i`, and `λ_N=id` forces uniqueness.

`Limits.Chain.terminating` searches for the first invertible arrow under the
exercise's **invertible-tail premise**. It checks both equations of each inverse
it uses, adjacent endpoints, and candidate prefix equations. The finite search
does not prove the tail premise. `leg` also checks requested tail arrows; a false
tail premise can be exposed by a later request. The bound limits search and
supported leg indices, not arbitrary callback time. A candidate for `factor`
must be a globally compatible cocone; finite prefix checks do not admit an
arbitrary infinite family. This is a bounded executable presentation of the
terminating case, not an omega-colimit capability for every chain.

`Category.iso_cat` supplies recognition/inversion; `Category.inverse` validates
endpoints and both inverse equations. `Finite_set_universals.Make(F).isomorphisms`
constructs inverses from the frozen map. Equal source/target cardinalities alone
do not imply bijectivity.

## Exercise 8 — initial-chain construction (pp. 150–151)

Assume an initial object, omega-colimits, and preservation of those colimits by F.
Start with the initial arrow `f_0:0→F(0)`, and set `f_(n+1)=F(f_n)`. Let
`λ_n:F^n(0)→l` be its colimit. The shifted chain has the same colimit, so
preservation supplies a unique `α:F(l)→l` with `α F(λ_n)=λ_(n+1)`.
For any algebra `(b,β)`, let `ν_0` be its initial arrow and
`ν_(n+1)=β F(ν_n)`. These legs commute with the chain (by induction starting
with initial uniqueness), giving `u:l→b`. Its homomorphism equation follows by
comparison on the jointly universal legs `F(λ_n)`. Every homomorphism has these
legs by induction, giving uniqueness. Hence `(l,α)` is the initial algebra.

For the free F-algebra on `a`, replace F by **H(x)=a+F(x)**. An H-algebra is
exactly an F-algebra with a chosen generator map from a. The constant a plus F
preserves omega-colimits here: an omega-cocone's maps on the a summand are all
equal, while the other summand factors through the preserved F-colimit.
Thus the initial H-algebra gives the required free F-algebra.

Programs: `Algebras.Free.initial_chain` and `Free.chain`. In the terminating
case, an invertible `f_N:a_N→F(a_N)` gives structure `f_N⁻¹`; its future maps
are invertible by functoriality. Factors are the finite recursion for `ν_N`.
No countable completeness or preservation assumption is asserted for arbitrary
FinSet; finite stabilization is sufficient in these specific generated chains.

**Source qualification:** the term-algebra discussion on p. 143 also calls the
ordinary term algebra free for `F'(x)=x+F(x)`. Without extra laws on that added
unary operation this is not true in general. For empty operation domain,
F is constantly empty and the ordinary term algebra on X is X. An Id-algebra
also has an arbitrary endomorphism. The singleton with identity cannot be free
on its generator into the two-element swap algebra: neither possible generator
map is a homomorphism. This does not affect the theorem above, whose summand a
is **constant**, not the variable x.

## Exercise 9 — iterated pushouts (p. 151)

Assume finite colimits, omega-colimits and preservation of omega-colimits by F.
Set `a_0=a`, with initial arrows `f_0:0→a_0`, `g_0:0→F(a_0)`.
Their pushout gives `f_1:a_0→a_1` and `g_1:F(a_0)→a_1`. Subsequently push out
`g_n:F(a_(n−1))→a_n` and `F(f_n):F(a_(n−1))→F(a_n)` to obtain
`f_(n+1):a_n→a_(n+1)` and `g_(n+1):F(a_n)→a_(n+1)`.
The square says `g_(n+1) F(f_n)=f_(n+1) g_n`.

For the chain colimit `(l,λ_n)`, these squares make the legs
`λ_(n+1) g_(n+1):F(a_n)→l` compatible. Preservation constructs `α:F(l)→l`
with those legs; the generator is `λ_0`. For `(b,β)` and seed `h:a→b`, set
`ν_0=h`. The pair `(β F(ν_n),ν_n)` factors uniquely through each pushout,
giving `ν_(n+1)`. Compatibility of that pair follows from the previous factor
equation. The chain colimit gives the unique `u:l→b`; comparison on the preserved
F-colimit proves its homomorphism equation. Conversely any homomorphism extending
h forces all these factors, so is u.

Program: `Algebras.Free.pushout`. When `f_(n+1)` becomes invertible it returns
carrier `a_n`, structure `f_(n+1)⁻¹ g_(n+1)`, and the accumulated seed injection.
Future transition arrows are invertible because functors preserve isomorphisms
and a pushout of an isomorphism is an isomorphism. Earlier pushout mediators
compute its factors. Exhaustion is an error, not a successful finite prefix.

## Fixed-node path algebras (pp. 146–149)

`Finite_graphs.Make(F).Fixed` uses graphs on the declared node set and maps
fixing those nodes pointwise. Its colimits are created from edge colimits with
the induced incidence map. For a fixed graph G, `prepend G` maps H to G*H:
edges are composable **witness pairs**, constructed by `Spans.compose` through
the existing pullback. Its arrow action uses the same pullback universal property.
This functor preserves coproducts: each compatible pair with an edge in a
disjoint summand belongs uniquely to that summand. Finite-colimit comparison
checks implement preservation for the finite computations.

`Fixed.free_paths ~bound G` applies the terminating coproduct construction on G.
The summands are nonempty paths of length 1, 2, …; structure prepends one original
edge. The generator includes length-one paths, and the universal fold evaluates
each path in any supplied algebra. Empty paths are **not** added: that would be
the path category rather than this nonempty-path algebra. Empty-edge graphs
terminate immediately, retaining their declared nodes. Finite acyclic graphs
terminate; a directed cycle has paths of arbitrarily large length and reaches the
bound instead. No quotient into endpoint reachability is taken.

Internal tags and nested pullback witnesses are not a public word encoding. The
tests independently enumerate edge words, construct their word algebra, and check
that its universal fold is bijective. Parallel edges retain distinct words. The
polynomial complexity sentence on p. 149 cannot bound this witness-preserving
enumeration: even finite DAGs can have exponentially many distinct paths. No
Warshall-style endpoint bound or general scalability claim is made. For example,
the complete DAG on ordered vertices 1,…,n has 2^(n−2) paths from 1 to n:
each subset of intermediate vertices determines a different ascending path.

## Exercises 10–11: conjugates and composed adjunctions

Exercise 10 is represented by `Universal.Adjunction.mate_left` and
`mate_right`. For adjunctions `F ⊣ G` and `F' ⊣ G'`, a natural family
`α : F ⇒ F'` is sent to the conjugate family
`β_x = G(ε'_x) · G(α_(G' x)) · η_(G' x)`. The inverse uses the transpose
of `β_(F' x) · η'_x`. `check_conjugate` checks the defining equation at a
chosen object; the test suite checks both directions over the exact finite
categories used elsewhere in this chapter.

Exercise 11 is represented by `Universal.Adjunction.compose`. Given
`F ⊣ G` and `F' ⊣ G'`, it constructs `F'F ⊣ GG'` with the composite unit
and counit. The implementation maps the inner unit through the inner right
functor and the outer unit through the composite, and dually maps the inner
counit through the outer left functor. The existing triangle-law admission
therefore remains the single owner of coherence rather than introducing a
second adjunction record.

The focused tests report 506 hom round trips and 11 selected exhaustive
mediators, including conjugate round trips and the composed adjunction.

## Complete wrapped-library example

This single OCaml program demonstrates the two ordered adjunction values and
the shared component, fixed-shape, and slice adapters. It needs only the local
`computational_category` library; no numeric package or installation is needed.

```ocaml
open Computational_category
module C = Foundations.Category
module K = Foundations.Functor
module A = Universal.Adjunction
module D = Universal.Diagrams
module L = Universal.Limits
module E = Constructions.Elementary
module B = Constructions.Algebras
let get = function Ok x -> x | Error _ -> failwith "example admission failed"

module Grid = struct
  let integers = [-2;-1;0;1;2]
  let halves = [-4;-3;-2;-1;0;1;2;3;4] (* k represents k/2 *)
  let arrow values s t =
    if List.mem s values && List.mem t values && s<=t then Ok (s,t)
    else Error (C.Outside_domain "finite ordered chain")
  let category values =
    {C.source=fst;target=snd;ident=(fun x -> x,x);equal_obj=Int.equal;
     equal_arr=(fun a b -> a=b);comp=(fun ((m,t),(s,n)) ->
       if m=n then arrow values s t else Error (C.Non_composable "ordered chain"))}
  let ic = category integers and rc = category halves
  let functor_ dom cod values targets map =
    {K.f_dom=dom;f_cod=cod;
     f_omap=(fun x -> if List.mem x values then Ok (map x)
       else Error (C.Outside_domain "finite ordered chain"));
     f_amap=(fun (s,t) -> match arrow values s t with
       | Error e -> Error e | Ok _ -> arrow targets (map s) (map t))}
  let inclusion = functor_ ic rc integers halves (fun n -> 2*n)
  let floor k = if k<0 && k mod 2<>0 then k/2-1 else k/2
  let ceiling k = if k>0 && k mod 2<>0 then k/2+1 else k/2
  let ceiling_adj = A.of_unit_counit
    ~left:(functor_ rc ic halves integers ceiling) ~right:inclusion
    ~unit:(fun k -> arrow halves k (2*ceiling k))
    ~counit:(fun n -> arrow integers n n)
  let floor_adj = A.of_unit_counit
    ~left:inclusion ~right:(functor_ rc ic halves integers floor)
    ~unit:(fun n -> arrow integers n n)
    ~counit:(fun k -> arrow halves (2*floor k) k)
end

module F = Instances.Finite_sets.Make (struct
  type t = int
  let equal (x:int) y = x=y
end)
module U = Instances.Finite_set_universals.Make (F)
module G = Instances.Finite_graphs.Make (F)
let ints xs = F.carrier_of_list (List.map F.atom xs)
let colimit_adjunction cocomplete shape =
  L.Free.adjunction (L.Free.fixed_colimit cocomplete.L.cc_cat shape cocomplete.L.cc_colimit)

let () =
  ignore (get (A.check_triangles Grid.ceiling_adj (-3) 1));
  ignore (get (A.check_triangles Grid.floor_adj (-1) 3));
  assert (get (A.transpose Grid.ceiling_adj (-3) 1 (-3,2)) = (-1,1));
  assert (get (A.untranspose Grid.ceiling_adj (-3) 1 (-1,1)) = (-3,2));
  assert (get (A.transpose Grid.floor_adj (-1) 3 (-1,1)) = (-2,3));
  assert (get (A.untranspose Grid.floor_adj (-1) 3 (-2,3)) = (-1,1));
  let graph = get (G.graph ~nodes:(ints [1;2;3])
    ~edges:[F.atom 4,F.atom 1,F.atom 2]) in
  let components = get ((A.left G.components_adjunction).K.f_omap graph) in
  assert (F.cardinality components=2);
  let shape = get (D.graph ~nodes:["x"] ~edges:[]) in
  let diagram = get (D.diagram F.cat shape ~objects:["x",ints [1]] ~arrows:[]) in
  let adj = colimit_adjunction U.cocomplete_finset shape in
  let chosen = get (A.universal adj diagram) in
  assert (F.cardinality (D.cocone_apex chosen.A.free_object)=1);
  let h = get (F.morphism (ints [1;2]) (fun _ -> F.atom 1) (ints [1])) in
  let slice_adj = E.slice_postcompose U.complete_finset h in
  let carrier_adj = E.slice_carrier F.cat U.product (ints [1;2]) in
  ignore (A.right slice_adj); ignore (A.right carrier_adj);
  let zero = K.constant F.cat F.cat F.empty in
  let free = get (B.Free.chain ~cocomplete:U.cocomplete_finset
    ~isomorphisms:U.isomorphisms ~bound:3 zero (ints [1;2])) in
  assert (F.cardinality (B.carrier free.A.free_object)=2);
  let g = get (G.graph ~nodes:(ints [1;2;3])
    ~edges:[F.atom 4,F.atom 1,F.atom 2;F.atom 5,F.atom 2,F.atom 3]) in
  let paths = get (G.Fixed.free_paths ~bound:3 g) in
  assert (F.cardinality (G.edges (B.carrier paths.A.free_object))=3);
  assert (match G.Fixed.free_paths ~bound:0 g with
    Error (C.Iteration_limit 0) -> true | _ -> false);
  Printf.printf "ordered round trips checked; components=%d; colimit apex=1\n"
    (F.cardinality components)
```

Expected output: `ordered round trips checked; components=2; colimit apex=1`.
Here `get` is only an example assertion policy; applications should handle `Error`.
Category identities assume admitted objects, as elsewhere in the general API.

## Evidence and remaining limits

[The adjunction suite](../tests/adjunction_test.ml) checks six subject groups:
general capabilities, exact ordered adjunctions, comma/fixed-shape equivalences,
components, slices and preservation. It includes 506 hom round trips and 11
selected independently enumerated unique mediators; nonidentity comma morphisms,
noninjective pullbacks, empty graphs/shapes, naturality, triangles, duality,
wrong endpoints/bases, unchanged errors and supplier exceptions are exercised.
The FinSet adjunction with a nonidentity unit makes the tests sensitive to an
omitted unit composition; thin ordered examples alone could miss that defect.

These finite observations falsify particular implementations, not universal
category-theoretic statements. Chosen quotient/product representations need not
be literally equal across different enumerations. No tests compare arbitrary
functions extensionally, prove a supplier's uniqueness, certify all real numbers,
or establish termination of arbitrary user callbacks. See the
[project verification limits](../README.md#verification-and-limits).

[The algebra suite](../tests/algebras_test.ml) adds four groups and 2,827 law
triples / 34 selected exhaustive unique factors. It covers a product not preserved
by F, the terminal algebra, zero/constant functors, all three terminating free
constructions, both inverse equations, false tail premises, bounds, errors and
exceptions. Its path fixtures have at most five nonempty paths, including distinct
parallel-edge witnesses; cyclic input is refused by exhaustion. These bounds
describe test evidence, not promised workload capacity. Exercises 10–11
are implemented; 13–16 remain bounded research dispositions rather than
production APIs.

## Starred investigations: bounded dispositions

These four items stay deliberately separate from the finite, executable core.
Each requires a model choice that the book leaves open and that would otherwise
turn a convenient example into an accidental library contract.

- **13 — automata and minimal realization.** A useful implementation needs a
  fixed alphabet, a category of finite deterministic automata and a behavior
  functor whose morphisms are defined. Minimality then needs a finite residual
  equivalence and a chosen quotient. The current finite-graph category supplies
  none of those owners, so no right-adjoint/minimization API is claimed.
- **14 — monads and tree processing.** From `F ⊣ G` the induced monad is
  `T = G F`, with unit `η` and multiplication `G ε F`. A production tree API
  still needs a polynomial/tree carrier and explicit operations; the current
  terminating algebra constructors do not provide that owner. The theorem is
  recorded, but no monad implementation is introduced.
- **15 — recursively enumerable sets.** This exercise needs an explicit
  enumerator or recursive-function presentation, together with a fair-stream
  policy. Membership, equality and function equality are not generally
  decidable, so the finite-value interfaces in this repository cannot be reused
  honestly. No r.e. set or stream API is claimed.
- **16 — colimit-based adjunction construction.** A general construction needs
  explicit seed/decomposition data, functoriality proofs and a termination or
  approximation policy. The present limits and free-algebra code only handle
  bounded finite cases and return values up to the chosen representation
  isomorphism. No general recursive-colimit oracle is claimed.
