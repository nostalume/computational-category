# Chapter 8: categorical unification

## Context

Unification is an application of a universal construction, not merely a term
rewriting trick. A pair of substitutions is a parallel pair; a most-general
unifier is its coequalizer. The implementation keeps that deduction while
choosing a dense, mutable solver state internally and a frozen substitution at
the public boundary.

This guide implements the two Chapter 8 exercises while separating the book's
categorical derivation from the representation used by the executable solver.
The model is first-order, finite, and syntactic: equations are solved by an
occurs-checking most-general unifier, not by assuming infinite terms.

## Terms and equations

The book treats a substitution `X -> TΣ(Y)` as a record containing a finite set,
a function, and another finite set. That is mathematically direct but not an
efficient execution representation: repeated variable lookup is linear and
substitution application repeatedly rebuilds list-shaped terms.

`Instances.Term_unification` keeps the same meaning while changing the
computational boundary:

```text
compile variables to dense ids
store operator arguments in arrays
maintain variable aliases with union-find/path compression
bind an unbound representative to a term after occurs-checking
reify the frozen substitution only at the result boundary
```

The existing `Instances.Terms` API remains an adapter through `from_terms` and
`to_terms`; it is not duplicated or silently redefined.

## Unification reduction

For a parallel pair of substitutions `f,g : A -> B`, a unifier is an arrow
`q : B -> C` with `q f = q g`. A most-general unifier is exactly a
coequalizer of `f` and `g`. The implementation reports clashes and occurs-check
cycles as `Malformed_term` errors and returns a frozen substitution on success.

## Factorized coequalizers

The first exercise is implemented by
`Constructions.Coequalizer_reduction.factorized_coequalizer`.
If `f = h g`, form the pushout of `g` and `f'`:

```text
A --g--> A'       A' --p--> P
|        |        B  --p'-> P
f'       B        p g = p' f'
```

Then compute `q = coequalizer(p, p' h)` and return `q p'`. Endpoint and
composition checks are delegated to the supplied category and universal
capabilities. The construction is generic; no finite-set-specific quotient is
embedded in it.

## Generalization

`Term_unification.generalize s t` computes a greatest common instance using
memoized pair reduction:

```text
generalize(s,t) = (s,t)                 if s = t
generalize(f(sᵢ), f(tᵢ)) = f(generalize(sᵢ,tᵢ))
generalize(s,t) = fresh variable       otherwise
```

Repeated unequal pairs share one fresh variable. The returned pattern and two
substitutions satisfy the instance equations for the finite input terms.

## Limits and evidence

The implementation covers finite first-order terms and finite equation sets.
It does not claim higher-order, equational-theory, rational-tree, or infinite
term unification. The focused suite checks successful bindings, propagation,
clash and cyclic rejection, memoized generalization, and the factorized
coequalizer construction. The full project build and test suite remains the
completion gate.
