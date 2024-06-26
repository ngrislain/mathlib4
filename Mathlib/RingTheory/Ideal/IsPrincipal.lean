/-
Copyright (c) 2024 Xavier Roblot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Xavier Roblot
-/
import Mathlib.RingTheory.PrincipalIdealDomain

#align_import ring_theory.ideal.basic from "leanprover-community/mathlib"@"dc6c365e751e34d100e80fe6e314c3c3e0fd2988"

/-!
# Principal Ideals

This file deals with the set of principal ideals of a `CommRing R`.

## Main definitions and results

* `Ideal.isPrincipalSubmonoid`: the submonoid of `Ideal R` formed by the principal ideals of `R`.

* `Ideal.associatesMulEquivIsPrincipal`: the `MulEquiv` between the monoid of `Associates R` and
the submonoid of principal ideals of `R`.

-/

variable {R : Type*} [CommRing R]

namespace Ideal

open Submodule

variable (R) in
/-- The principal ideals of `R` form a submonoid of `Ideal R`. -/
def isPrincipalSubmonoid : Submonoid (Ideal R) where
  carrier := {I | IsPrincipal I}
  mul_mem' := by
    rintro _ _ ⟨x, rfl⟩ ⟨y, rfl⟩
    exact ⟨x * y, Ideal.span_singleton_mul_span_singleton x y⟩
  one_mem' := ⟨1, one_eq_span⟩

theorem mem_isPrincipalSubmonoid_iff {I : Ideal R} :
    I ∈ isPrincipalSubmonoid R ↔ IsPrincipal I := Iff.rfl

theorem span_singleton_mem_isPrincipalSubmonoid (a : R) :
    span {a} ∈ isPrincipalSubmonoid R := mem_isPrincipalSubmonoid_iff.mpr ⟨a, rfl⟩

variable [IsDomain R]

variable (R) in
/-- The equivalence between `Associates R` and the principal ideals of `R` defined by sending the
class of `x` to the principal ideal generated by `x`. -/
noncomputable def associatesEquivIsPrincipal :
    Associates R ≃ {I : Ideal R // IsPrincipal I} where
  toFun := Quotient.lift (fun x ↦ ⟨span {x}, x, rfl⟩)
    (fun _ _ _ ↦ by simpa [span_singleton_eq_span_singleton])
  invFun I := Associates.mk I.2.generator
  left_inv := Quotient.ind fun _ ↦ by simpa using
    Ideal.span_singleton_eq_span_singleton.mp (@Ideal.span_singleton_generator _ _ _ ⟨_, rfl⟩)
  right_inv I := by simp only [Quotient.lift_mk, span_singleton_generator, Subtype.coe_eta]

@[simp]
theorem associatesEquivIsPrincipal_apply (x : R) :
    associatesEquivIsPrincipal R (Associates.mk x) = span {x} := rfl

@[simp]
theorem associatesEquivIsPrincipal_symm_apply {I : Ideal R} (hI : IsPrincipal I) :
    (associatesEquivIsPrincipal R).symm ⟨I, hI⟩ = Associates.mk hI.generator := rfl

theorem associatesEquivIsPrincipal_mul (x y : Associates R) :
    (associatesEquivIsPrincipal R (x * y) : Ideal R) =
      (associatesEquivIsPrincipal R x) * (associatesEquivIsPrincipal R y) := by
  rw [← Associates.quot_out x, ← Associates.quot_out y]
  simp_rw [Associates.mk_mul_mk, ← Associates.quotient_mk_eq_mk, associatesEquivIsPrincipal_apply,
    span_singleton_mul_span_singleton]

@[simp]
theorem associatesEquivIsPrincipal_map_zero :
    (associatesEquivIsPrincipal R 0 : Ideal R) = 0 := by
  rw [← Associates.mk_zero, ← Associates.quotient_mk_eq_mk, associatesEquivIsPrincipal_apply,
    Set.singleton_zero, span_zero, zero_eq_bot]

@[simp]
theorem associatesEquivIsPrincipal_map_one :
    (associatesEquivIsPrincipal R 1 : Ideal R) = 1 := by
  rw [Associates.one_eq_mk_one, ← Associates.quotient_mk_eq_mk, associatesEquivIsPrincipal_apply,
    span_singleton_one, one_eq_top]

variable (R) in
/-- The `MulEquiv` version of `Ideal.associatesEquivIsPrincipal`. -/
noncomputable def associatesMulEquivIsPrincipal :
    Associates R ≃* (isPrincipalSubmonoid R) where
  __ := Ideal.associatesEquivIsPrincipal R
  map_mul' _ _ := by
    erw [Subtype.ext_iff, associatesEquivIsPrincipal_mul]
    rfl
