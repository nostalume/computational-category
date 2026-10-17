# Chapter 7: finite exponentials and toposes

## Context

Exponentials and classifiers internalize function spaces and predicates inside
a category. The finite-set model makes the reduction inspectable: function
graphs provide exponential values, evaluation supplies application, and the
classifier turns subobject membership into truth values. Slice, discrete
functor, and directed-graph instances then show how the same deductions change
when the ambient category changes.

This guide covers the definitions on printed pages 155–172 of Rydeheard and
Burstall, *Computational Category Theory*, and records the four exercises. The
supplied PDF uses one-based pages 168–185 for this chapter. The executable model
is the finite-set topos; Set-sized and arbitrary infinite claims remain outside
the repository contract.

## Cartesian closed structure

An exponential `b^a` is an object with an evaluation arrow `a × b^a → b`.
`Universal.Closed` owns the checked `cartesian_closed` capability: an
`exponential_object`, its evaluation arrow and a currying operation. The caller supplies the category,
finite limits and their laws. It does not manufacture a proof of uniqueness.

`Instances.Finite_set_topos.Make(F)` enumerates all functions between two finite
sets. Function graphs are encoded with a fresh library-owned tag, so values are
not confused with ordinary atoms, pairs or terminal values in the admitted
snapshot. Evaluation and currying are checked arrows and preserve the exact
finite endpoints.

The concrete API names these operations `evaluation_morphism`,
`currying_morphism`, `power_object`, and `exists`. `Universal.Topos.topos`
names the complete finite capability record; its classifier and logical
operations remain result-valued and retain their explicit finite premises.

## Subobject classifier and internal logic

`Universal.Topos` packages finite limits, finite colimits, exponentials and a
subobject classifier. The classifier interface accepts a monic arrow as a
mathematical premise and returns its characteristic arrow; monicity is not
pretended to follow from an arbitrary OCaml callback.

The finite-set instance uses two truth values. It provides `false_`, `not_`,
`and_`, `or_`, `imply_`, the universal quantifier from naming a predicate, and
an existential quantifier by finite enumeration. Factorization is built from
the supplied pushout/equalizer capabilities, not from a second image algorithm.

Power objects are represented by the finite exponential `Omega^a`; membership
is the subobject of `a × Omega^a` where the predicate evaluates to true.

## Implemented constructions and boundaries

### Exercise 1 — quantifiers

**Implemented for FinSet.** Universal quantification is the characteristic of
the named constant-true predicate. Existential quantification enumerates the
finite function graph and tests whether at least one value is true. The focused
suite checks constant true/false predicates and the classifier endpoints.

### Exercise 2 — slice toposes

**Implemented for finite slices.** `Instances.Finite_slice_topos.Make(F)` fixes
an anchor `B` and represents an object as a checked projection `X -> B`.
Products are fibre products. For `p : X -> B` and `q : Y -> B`, the exponential
is reduced fibrewise:

```text
(q^p)_b = (q_b)^(p_b)
evaluation (x, f) = f(x)
```

The relative classifier is `B x Omega -> B`; `character` accepts a checked
monomorphism and marks each element by its anchor and membership truth value.
The implementation is finite and result-valued; it does not add a second
general-purpose `Topos` record.

### Exercise 3 — functor categories

**Implemented for discrete finite sources.**
`Instances.Finite_functor_topos.Make(F)` rejects non-discrete source domains
and computes the pointwise model for a discrete finite `B`:

```text
(G^H)(b) = G(b)^(H(b))
Omega(b) = Omega_FinSet
```

Evaluation, currying, the classifier, and characteristic natural
transformations are admitted componentwise. General `FinSet^B` still requires
the book's sieve convention and is intentionally outside this contract.

### Exercise 4 — graph topos

**Implemented for finite directed graphs.**
`Instances.Finite_graph_topos.Make(F)` follows the repository orientation
`incidence : E -> V x V`. A vertex of `G^H` is a finite function
`H.V -> G.V`; an edge is a triple of endpoint functions and an edge function
that preserves incidence. The classifier has two vertices and five edges,
corresponding to

```text
empty, {source}, {target}, {source,target}, {edge,source,target}.
```

Its characteristic morphism requires an injective graph morphism and checks
the incidence square. This is the concrete finite graph exercise, not a claim
about arbitrary presheaf categories or infinite graphs.

## Evidence and limits

The topos suite checks finite-set exponentials, slice exponentials and relative
classifiers, discrete functor-category exponentials/classifiers, and graph
exponentials/the five-edge classifier, in addition to the original finite-set
logic and power-object tests. These are finite observations.
They do not establish arbitrary topos laws, Set completeness, infinite
enumeration, or the unresolved slice/sieve constructions.
