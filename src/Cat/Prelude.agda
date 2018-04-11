-- | Custom prelude for this module
module Cat.Prelude where

open import Agda.Primitive public
-- FIXME Use:
open import Agda.Builtin.Sigma public
-- Rather than
open import Data.Product public
  renaming (∃! to ∃!≈)
  using (_×_ ; Σ-syntax ; swap)

open import Function using (_∘_ ; _∘′_ ; _$_ ; case_of_ ; flip) public

idFun : ∀ {a} (A : Set a) → A → A
idFun A a = a

open import Cubical public
-- FIXME rename `gradLemma` to `fromIsomorphism` - perhaps just use wrapper
-- module.
open import Cubical.GradLemma
  using (gradLemma)
  public
open import Cubical.NType
  using (⟨-2⟩ ; ⟨-1⟩ ; ⟨0⟩ ; TLevel ; HasLevel)
  public
open import Cubical.NType.Properties
  using
    ( lemPropF ; lemSig ;  lemSigP ; isSetIsProp
    ; propPi ; propPiImpl ; propHasLevel ; setPi ; propSet
    ; propSig ; equivPreservesNType)
  public

propIsContr : {ℓ : Level} → {A : Set ℓ} → isProp (isContr A)
propIsContr = propHasLevel ⟨-2⟩

open import Cubical.Sigma using (setSig ; sigPresSet ; sigPresNType) public

module _ (ℓ : Level) where
  -- FIXME Ask if we can push upstream.
  -- A redefinition of `Cubical.Universe` with an explicit parameter
  _-type : TLevel → Set (lsuc ℓ)
  n -type = Σ (Set ℓ) (HasLevel n)

  hSet : Set (lsuc ℓ)
  hSet = ⟨0⟩ -type

  Prop : Set (lsuc ℓ)
  Prop = ⟨-1⟩ -type

-----------------
-- * Utilities --
-----------------

-- | Unique existentials.
∃! : ∀ {a b} {A : Set a}
  → (A → Set b) → Set (a ⊔ b)
∃! = ∃!≈ _≡_

∃!-syntax : ∀ {a b} {A : Set a} → (A → Set b) → Set (a ⊔ b)
∃!-syntax = ∃!

syntax ∃!-syntax (λ x → B) = ∃![ x ] B

module _ {ℓa ℓb} {A : Set ℓa} {P : A → Set ℓb} (f g : ∃! P) where
  open Σ (snd f) renaming (snd to u)

  ∃-unique : fst f ≡ fst g
  ∃-unique = u (fst (snd g))

module _ {ℓa ℓb : Level} {A : Set ℓa} {B : A → Set ℓb} {a b : Σ A B}
  (fst≡ : (λ _ → A)            [ fst a ≡ fst b ])
  (snd≡ : (λ i → B (fst≡ i)) [ snd a ≡ snd b ]) where

  Σ≡ : a ≡ b
  fst (Σ≡ i) = fst≡ i
  snd (Σ≡ i) = snd≡ i

import Relation.Binary
open Relation.Binary public using (Preorder ; Transitive ; IsEquivalence ; Rel)

equalityIsEquivalence : {ℓ : Level} {A : Set ℓ} → IsEquivalence {A = A} _≡_
IsEquivalence.refl  equalityIsEquivalence = refl
IsEquivalence.sym   equalityIsEquivalence = sym
IsEquivalence.trans equalityIsEquivalence = trans

IsPreorder
  : {a ℓ : Level} {A : Set a}
  → (_∼_ : Rel A ℓ) -- The relation.
  → Set _
IsPreorder _~_ = Relation.Binary.IsPreorder _≡_ _~_
