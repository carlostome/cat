-- | The category of homotopy sets
{-# OPTIONS --allow-unsolved-metas --cubical #-}
module Cat.Categories.Sets where

open import Agda.Primitive
open import Data.Product
open import Function using (_∘_)

-- open import Cubical using (funExt ; refl ; isSet ; isProp ; _≡_ ; isEquiv ; sym ; trans ; _[_≡_] ; I ; Path ; PathP)
open import Cubical hiding (_≃_)
open import Cubical.Univalence using (univalence ; con ; _≃_ ; idtoeqv ; ua)
open import Cubical.GradLemma
open import Cubical.NType.Properties

open import Cat.Category
open import Cat.Category.Functor
open import Cat.Category.Product
open import Cat.Wishlist
open import Cat.Equivalence as Eqv renaming (module NoEta to Eeq) using (AreInverses ; module Equiv≃)

module Equivalence = Eeq.Equivalence′

_⊙_ : {ℓa ℓb ℓc : Level} {A : Set ℓa} {B : Set ℓb} {C : Set ℓc} → (A ≃ B) → (B ≃ C) → A ≃ C
eqA ⊙ eqB = Equivalence.compose eqA eqB

sym≃ : ∀ {ℓa ℓb} {A : Set ℓa} {B : Set ℓb} → A ≃ B → B ≃ A
sym≃ = Equivalence.symmetry

infixl 10 _⊙_

module _ {ℓ : Level} {A : Set ℓ} {a : A} where
  id-coe : coe refl a ≡ a
  id-coe = begin
    coe refl a                 ≡⟨⟩
    pathJ (λ y x → A) _ A refl ≡⟨ pathJprop {x = a} (λ y x → A) _ ⟩
    _ ≡⟨ pathJprop {x = a} (λ y x → A) _ ⟩
    a ∎

module _ {ℓ : Level} {A B : Set ℓ} {a : A} where
  inv-coe : (p : A ≡ B) → coe (sym p) (coe p a) ≡ a
  inv-coe p =
    let
      D : (y : Set ℓ) → _ ≡ y → Set _
      D _ q = coe (sym q) (coe q a) ≡ a
      d : D A refl
      d = begin
        coe (sym refl) (coe refl a) ≡⟨⟩
        coe refl (coe refl a)       ≡⟨ id-coe ⟩
        coe refl a                  ≡⟨ id-coe ⟩
        a ∎
    in pathJ D d B p
  inv-coe' : (p : B ≡ A) → coe p (coe (sym p) a) ≡ a
  inv-coe' p =
    let
      D : (y : Set ℓ) → _ ≡ y → Set _
      D _ q = coe (sym q) (coe q a) ≡ a
      k : coe p (coe (sym p) a) ≡ a
      k = pathJ D (trans id-coe id-coe) B (sym p)
    in k

module _ (ℓ : Level) where
  private
    open import Cubical.Universe using (hSet) public

    SetsRaw : RawCategory (lsuc ℓ) ℓ
    RawCategory.Object SetsRaw = hSet {ℓ}
    RawCategory.Arrow  SetsRaw (T , _) (U , _) = T → U
    RawCategory.𝟙      SetsRaw = Function.id
    RawCategory._∘_    SetsRaw = Function._∘′_

    open RawCategory SetsRaw hiding (_∘_)

    isIdentity : IsIdentity Function.id
    proj₁ isIdentity = funExt λ _ → refl
    proj₂ isIdentity = funExt λ _ → refl

    open Univalence (λ {A} {B} {f} → isIdentity {A} {B} {f})

    arrowsAreSets : ArrowsAreSets
    arrowsAreSets {B = (_ , s)} = setPi λ _ → s

    isIso = Eqv.Isomorphism
    module _ {hA hB : hSet {ℓ}} where
      open Σ hA renaming (proj₁ to A ; proj₂ to sA)
      open Σ hB renaming (proj₁ to B ; proj₂ to sB)
      lem1 : (f : A → B) → isSet A → isSet B → isProp (isIso f)
      lem1 f sA sB = res
        where
        module _ (x y : isIso f) where
          module x = Σ x renaming (proj₁ to inverse ; proj₂ to areInverses)
          module y = Σ y renaming (proj₁ to inverse ; proj₂ to areInverses)
          module xA = AreInverses x.areInverses
          module yA = AreInverses y.areInverses
          -- I had a lot of difficulty using the corresponding proof where
          -- AreInverses is defined. This is sadly a bit anti-modular. The
          -- reason for my troubles is probably related to the type of objects
          -- being hSet's rather than sets.
          p : ∀ {f} g → isProp (AreInverses {A = A} {B} f g)
          p {f} g xx yy i = record
            { verso-recto = ve-re
            ; recto-verso = re-ve
            }
            where
            module xxA = AreInverses xx
            module yyA = AreInverses yy
            ve-re : g ∘ f ≡ Function.id
            ve-re = arrowsAreSets {A = hA} {B = hA} _ _ xxA.verso-recto yyA.verso-recto i
            re-ve : f ∘ g ≡ Function.id
            re-ve = arrowsAreSets {A = hB} {B = hB} _ _ xxA.recto-verso yyA.recto-verso i
          1eq : x.inverse ≡ y.inverse
          1eq = begin
            x.inverse                   ≡⟨⟩
            x.inverse ∘ Function.id     ≡⟨ cong (λ φ → x.inverse ∘ φ) (sym yA.recto-verso) ⟩
            x.inverse ∘ (f ∘ y.inverse) ≡⟨⟩
            (x.inverse ∘ f) ∘ y.inverse ≡⟨ cong (λ φ → φ ∘ y.inverse) xA.verso-recto ⟩
            Function.id ∘ y.inverse     ≡⟨⟩
            y.inverse                   ∎
          2eq : (λ i → AreInverses f (1eq i)) [ x.areInverses ≡ y.areInverses ]
          2eq = lemPropF p 1eq
          res : x ≡ y
          res i = 1eq i , 2eq i
    module _ {ℓa ℓb : Level} {A : Set ℓa} {P : A → Set ℓb} where
      lem2 : ((x : A) → isProp (P x)) → (p q : Σ A P)
        → (p ≡ q) ≃ (proj₁ p ≡ proj₁ q)
      lem2 pA p q = Eeq.fromIsomorphism iso
        where
        f : p ≡ q → proj₁ p ≡ proj₁ q
        f e i = proj₁ (e i)
        g : proj₁ p ≡ proj₁ q → p ≡ q
        g = lemSig pA p q
        ve-re : (e : p ≡ q) → (g ∘ f) e ≡ e
        -- QUESTION Why does `h` not satisfy the constraint here?
        ve-re e i j = qq0 j , {!h!}
          where
          -- qq : ? [ proj₂ ((g ∘ f) e) ≡ proj₂ e ]
          qq0 : proj₁ p ≡ proj₁ q
          qq0 i = proj₁ (e i)
          qq : (λ i → P (qq0 i)) [ proj₂ p ≡ proj₂ q ]
          qq = lemPropF pA qq0
          h : P (qq0 j)
          h = qq j
        re-ve : (e : proj₁ p ≡ proj₁ q) → (f ∘ g) e ≡ e
        re-ve e = refl
        inv : AreInverses f g
        inv = record
          { verso-recto = funExt ve-re
          ; recto-verso = funExt re-ve
          }
        iso : (p ≡ q) Eqv.≅ (proj₁ p ≡ proj₁ q)
        iso = f , g , inv

      lem3 : {Q : A → Set ℓb}
        → ((a : A) → P a ≃ Q a) → Σ A P ≃ Σ A Q
      lem3 {Q} eA = res
        where
        P→Q : ∀ {a} → P a ≡ Q a
        P→Q = ua (eA _)
        Q→P : ∀ {a} → Q a ≡ P a
        Q→P = sym P→Q
        f : Σ A P → Σ A Q
        f (a , pA) = a , coe P→Q pA
        g : Σ A Q → Σ A P
        g (a , qA) = a , coe Q→P qA
        ve-re : (x : Σ A P) → (g ∘ f) x ≡ x
        ve-re x i = proj₁ x , eq i
          where
          eq : proj₂ ((g ∘ f) x) ≡ proj₂ x
          eq = begin
            proj₂ ((g ∘ f) x) ≡⟨⟩
            coe Q→P (proj₂ (f x))        ≡⟨⟩
            coe Q→P (coe P→Q (proj₂ x))  ≡⟨ inv-coe P→Q ⟩
            proj₂ x ∎
        re-ve : (x : Σ A Q) → (f ∘ g) x ≡ x
        re-ve x i = proj₁ x , eq i
          where
          eq = begin
            proj₂ ((f ∘ g) x)                 ≡⟨⟩
            coe P→Q (coe Q→P (proj₂ x))       ≡⟨⟩
            coe P→Q (coe (sym P→Q) (proj₂ x)) ≡⟨ inv-coe' P→Q ⟩
            proj₂ x                           ∎
        inv : AreInverses f g
        inv = record
          { verso-recto = funExt ve-re
          ; recto-verso = funExt re-ve
          }
        iso : Σ A P Eqv.≅ Σ A Q
        iso = f , g , inv
        res : Σ A P ≃ Σ A Q
        res = Eeq.fromIsomorphism iso

    module _ {ℓa ℓb : Level} {A : Set ℓa} {B : Set ℓb} where
      lem4 : isSet A → isSet B → (f : A → B)
        → isEquiv A B f ≃ isIso f
      lem4 sA sB f =
        let
          obv : isEquiv A B f → isIso f
          obv = Equiv≃.toIso A B
          inv : isIso f → isEquiv A B f
          inv = Equiv≃.fromIso A B
          re-ve : (x : isEquiv A B f) → (inv ∘ obv) x ≡ x
          re-ve = Equiv≃.inverse-from-to-iso A B
          ve-re : (x : isIso f)       → (obv ∘ inv) x ≡ x
          ve-re = Equiv≃.inverse-to-from-iso A B
          iso : isEquiv A B f Eqv.≅ isIso f
          iso = obv , inv ,
            record
              { verso-recto = funExt re-ve
              ; recto-verso = funExt ve-re
              }
        in Eeq.fromIsomorphism iso

    module _ {hA hB : Object} where
      private
        A = proj₁ hA
        sA = proj₂ hA
        B = proj₁ hB
        sB = proj₂ hB


      -- lem3 and the equivalence from lem4
      step0 : Σ (A → B) isIso ≃ Σ (A → B) (isEquiv A B)
      step0 = lem3 (λ f → sym≃ (lem4 sA sB f))
      -- univalence
      step1 : Σ (A → B) (isEquiv A B) ≃ (A ≡ B)
      step1 = hh ⊙ h
        where
          h : (A ≃ B) ≃ (A ≡ B)
          h = sym≃ (univalence {A = A} {B})
          obv : Σ (A → B) (isEquiv A B) → A ≃ B
          obv = Eqv.deEta
          inv : A ≃ B → Σ (A → B) (isEquiv A B)
          inv = Eqv.doEta
          re-ve : (x : _) → (inv ∘ obv) x ≡ x
          re-ve x = refl
          -- Because _≃_ does not have eta equality!
          ve-re : (x : _) → (obv ∘ inv) x ≡ x
          ve-re (con eqv isEqv) i = con eqv isEqv
          areInv : AreInverses obv inv
          areInv = record { verso-recto = funExt re-ve ; recto-verso = funExt ve-re }
          eqv : Σ (A → B) (isEquiv A B) Eqv.≅ (A ≃ B)
          eqv = obv , inv , areInv
          hh : Σ (A → B) (isEquiv A B) ≃ (A ≃ B)
          hh = Eeq.fromIsomorphism eqv

      -- lem2 with propIsSet
      step2 : (A ≡ B) ≃ (hA ≡ hB)
      step2 = sym≃ (lem2 (λ A → isSetIsProp) hA hB)

      -- Go from an isomorphism on sets to an isomorphism on homotopic sets
      trivial? : (hA ≅ hB) ≃ Σ (A → B) isIso
      trivial? = sym≃ (Eeq.fromIsomorphism res)
        where
        fwd : Σ (A → B) isIso → hA ≅ hB
        fwd (f , g , inv) = f , g , inv.toPair
          where
          module inv = AreInverses inv
        bwd : hA ≅ hB → Σ (A → B) isIso
        bwd (f , g , x , y) = f , g , record { verso-recto = x ; recto-verso = y }
        res : Σ (A → B) isIso Eqv.≅ (hA ≅ hB)
        res = fwd , bwd , record { verso-recto = refl ; recto-verso = refl }
      conclusion : (hA ≅ hB) ≃ (hA ≡ hB)
      conclusion = trivial? ⊙ step0 ⊙ step1 ⊙ step2
      t : (hA ≡ hB) ≃ (hA ≅ hB)
      t = sym≃ conclusion
      -- TODO Is the morphism `(_≃_.eqv conclusion)` the same as
      -- `(id-to-iso (λ {A} {B} → isIdentity {A} {B}) hA hB)` ?
      res : isEquiv (hA ≡ hB) (hA ≅ hB) (_≃_.eqv t)
      res = _≃_.isEqv t
    module _ {hA hB : hSet {ℓ}} where
      univalent : isEquiv (hA ≡ hB) (hA ≅ hB) (Univalence.id-to-iso (λ {A} {B} → isIdentity {A} {B}) hA hB)
      univalent = let k = _≃_.isEqv (sym≃ conclusion) in {!k!}

    SetsIsCategory : IsCategory SetsRaw
    IsCategory.isAssociative SetsIsCategory = refl
    IsCategory.isIdentity    SetsIsCategory {A} {B} = isIdentity    {A} {B}
    IsCategory.arrowsAreSets SetsIsCategory {A} {B} = arrowsAreSets {A} {B}
    IsCategory.univalent     SetsIsCategory = univalent

  𝓢𝓮𝓽 Sets : Category (lsuc ℓ) ℓ
  Category.raw 𝓢𝓮𝓽 = SetsRaw
  Category.isCategory 𝓢𝓮𝓽 = SetsIsCategory
  Sets = 𝓢𝓮𝓽

module _ {ℓ : Level} where
  private
    𝓢 = 𝓢𝓮𝓽 ℓ
    open Category 𝓢
    open import Cubical.Sigma

    module _ (hA hB : Object) where
      open Σ hA renaming (proj₁ to A ; proj₂ to sA)
      open Σ hB renaming (proj₁ to B ; proj₂ to sB)

      private
        productObject : Object
        productObject = (A × B) , sigPresSet sA λ _ → sB

        module _ {X A B : Set ℓ} (f : X → A) (g : X → B) where
          _&&&_ : (X → A × B)
          _&&&_ x = f x , g x

        module _ (hX : Object) where
          open Σ hX renaming (proj₁ to X)
          module _ (f : X → A ) (g : X → B) where
            ump : proj₁ Function.∘′ (f &&& g) ≡ f × proj₂ Function.∘′ (f &&& g) ≡ g
            proj₁ ump = refl
            proj₂ ump = refl

        rawProduct : RawProduct 𝓢 hA hB
        RawProduct.object rawProduct = productObject
        RawProduct.proj₁  rawProduct = Data.Product.proj₁
        RawProduct.proj₂  rawProduct = Data.Product.proj₂

        isProduct : IsProduct 𝓢 _ _ rawProduct
        IsProduct.ump isProduct {X = hX} f g
          = (f &&& g) , ump hX f g

      product : Product 𝓢 hA hB
      Product.raw       product = rawProduct
      Product.isProduct product = isProduct

  instance
    SetsHasProducts : HasProducts 𝓢
    SetsHasProducts = record { product = product }

module _ {ℓa ℓb : Level} (ℂ : Category ℓa ℓb) where
  open Category ℂ

  -- Covariant Presheaf
  Representable : Set (ℓa ⊔ lsuc ℓb)
  Representable = Functor ℂ (𝓢𝓮𝓽 ℓb)

  -- Contravariant Presheaf
  Presheaf : Set (ℓa ⊔ lsuc ℓb)
  Presheaf = Functor (opposite ℂ) (𝓢𝓮𝓽 ℓb)

  -- The "co-yoneda" embedding.
  representable : Category.Object ℂ → Representable
  representable A = record
    { raw = record
      { omap = λ B → ℂ [ A , B ] , arrowsAreSets
      ; fmap = ℂ [_∘_]
      }
    ; isFunctor = record
      { isIdentity     = funExt λ _ → leftIdentity
      ; isDistributive = funExt λ x → sym isAssociative
      }
    }

  -- Alternate name: `yoneda`
  presheaf : Category.Object (opposite ℂ) → Presheaf
  presheaf B = record
    { raw = record
      { omap = λ A → ℂ [ A , B ] , arrowsAreSets
      ; fmap = λ f g → ℂ [ g ∘ f ]
    }
    ; isFunctor = record
      { isIdentity     = funExt λ x → rightIdentity
      ; isDistributive = funExt λ x → isAssociative
      }
    }
