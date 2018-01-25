module Cat.Categories.Sets where

open import Cubical.PathPrelude
open import Agda.Primitive
open import Data.Product
open import Data.Product renaming (proj₁ to fst ; proj₂ to snd)

open import Cat.Category
open import Cat.Functor
open Category

module _ {ℓ : Level} where
  Sets : Category (lsuc ℓ) ℓ
  Sets = record
    { Object = Set ℓ
    ; Arrow = λ T U → T → U
    ; 𝟙 = id
    ; _⊕_ = _∘′_
    ; isCategory = record { assoc = refl ; ident = funExt (λ _ → refl) , funExt (λ _ → refl) }
    }
    where
      open import Function

  private
    module _ {X A B : Set ℓ} (f : X → A) (g : X → B) where
      _&&&_ : (X → A × B)
      _&&&_ x = f x , g x
    module _ {X A B : Set ℓ} (f : X → A) (g : X → B) where
      _S⊕_ = Sets ._⊕_
      lem : proj₁ S⊕ (f &&& g) ≡ f × snd S⊕ (f &&& g) ≡ g
      proj₁ lem = refl
      proj₂ lem = refl
    instance
      isProduct : {A B : Sets .Object} → IsProduct Sets {A} {B} fst snd
      isProduct f g = f &&& g , lem f g

    product : (A B : Sets .Object) → Product {ℂ = Sets} A B
    product A B = record { obj = A × B ; proj₁ = fst ; proj₂ = snd ; isProduct = isProduct }

  instance
    SetsHasProducts : HasProducts Sets
    SetsHasProducts = record { product = product }

-- Covariant Presheaf
Representable : {ℓ ℓ' : Level} → (ℂ : Category ℓ ℓ') → Set (ℓ ⊔ lsuc ℓ')
Representable {ℓ' = ℓ'} ℂ = Functor ℂ (Sets {ℓ'})

-- The "co-yoneda" embedding.
representable : ∀ {ℓ ℓ'} {ℂ : Category ℓ ℓ'} → Category.Object ℂ → Representable ℂ
representable {ℂ = ℂ} A = record
  { func* = λ B → ℂ .Arrow A B
  ; func→ = ℂ ._⊕_
  ; ident = funExt λ _ → snd ident
  ; distrib = funExt λ x → sym assoc
  }
  where
    open IsCategory (ℂ .isCategory)

-- Contravariant Presheaf
Presheaf : ∀ {ℓ ℓ'} (ℂ : Category ℓ ℓ') → Set (ℓ ⊔ lsuc ℓ')
Presheaf {ℓ' = ℓ'} ℂ = Functor (Opposite ℂ) (Sets {ℓ'})

-- Alternate name: `yoneda`
presheaf : {ℓ ℓ' : Level} {ℂ : Category ℓ ℓ'} → Category.Object (Opposite ℂ) → Presheaf ℂ
presheaf {ℂ = ℂ} B = record
  { func* = λ A → ℂ .Arrow A B
  ; func→ = λ f g → ℂ ._⊕_ g f
  ; ident = funExt λ x → fst ident
  ; distrib = funExt λ x → assoc
  }
  where
    open IsCategory (ℂ .isCategory)