module Cat.Category.Product where

open import Agda.Primitive
open import Cubical
open import Data.Product as P hiding (_×_)

open import Cat.Category

open Category

module _ {ℓ ℓ' : Level} (ℂ : Category ℓ ℓ') {A B obj : Object ℂ} where
  IsProduct : (π₁ : ℂ [ obj , A ]) (π₂ : ℂ [ obj , B ]) → Set (ℓ ⊔ ℓ')
  IsProduct π₁ π₂
    = ∀ {X : Object ℂ} (x₁ : ℂ [ X , A ]) (x₂ : ℂ [ X , B ])
    → ∃![ x ] (ℂ [ π₁ ∘ x ] ≡ x₁ P.× ℂ [ π₂ ∘ x ] ≡ x₂)

-- Tip from Andrea; Consider this style for efficiency:
-- record IsProduct {ℓa ℓb : Level} (ℂ : Category ℓa ℓb)
--   {A B obj : Object ℂ} (π₁ : Arrow ℂ obj A) (π₂ : Arrow ℂ obj B) : Set (ℓa ⊔ ℓb) where
--   field
--      issProduct : ∀ {X : Object ℂ} (x₁ : ℂ [ X , A ]) (x₂ : ℂ [ X , B ])
--        → ∃![ x ] (ℂ [ π₁ ∘ x ] ≡ x₁ P.× ℂ [ π₂ ∘ x ] ≡ x₂)

-- open IsProduct

record Product {ℓ ℓ' : Level} {ℂ : Category ℓ ℓ'} (A B : Object ℂ) : Set (ℓ ⊔ ℓ') where
  no-eta-equality
  field
    obj : Object ℂ
    proj₁ : ℂ [ obj , A ]
    proj₂ : ℂ [ obj , B ]
    {{isProduct}} : IsProduct ℂ proj₁ proj₂

  _P[_×_] : ∀ {X} → (π₁ : ℂ [ X , A ]) (π₂ : ℂ [ X , B ])
    → ℂ [ X , obj ]
  _P[_×_] π₁ π₂ = proj₁ (isProduct π₁ π₂)

record HasProducts {ℓ ℓ' : Level} (ℂ : Category ℓ ℓ') : Set (ℓ ⊔ ℓ') where
  field
    product : ∀ (A B : Object ℂ) → Product {ℂ = ℂ} A B

  open Product

  _×_ : (A B : Object ℂ) → Object ℂ
  A × B = Product.obj (product A B)
  -- The product mentioned in awodey in Def 6.1 is not the regular product of arrows.
  -- It's a "parallel" product
  _|×|_ : {A A' B B' : Object ℂ} → ℂ [ A , A' ] → ℂ [ B , B' ]
    → ℂ [ A × B , A' × B' ]
  _|×|_ {A = A} {A' = A'} {B = B} {B' = B'} a b
    = product A' B'
      P[ ℂ [ a ∘ (product A B) .proj₁ ]
      ×  ℂ [ b ∘ (product A B) .proj₂ ]
      ]