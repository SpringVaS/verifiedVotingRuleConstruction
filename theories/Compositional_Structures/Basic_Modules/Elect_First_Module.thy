(*  File:       Elect_First_Module.thy
    Copyright   2022  Karlsruhe Institute of Technology (KIT)
*)
\<^marker>\<open>creator "Marion Steinriede, Karlsruhe Institute of Technology (KIT)"\<close>

section \<open>Elect First Module\<close>

theory Elect_First_Module
  imports "Component_Types/Electoral_Module"
begin

text \<open>
  TODO.
\<close>

subsection \<open>Definition\<close>

fun elect_first_module :: "'a Electoral_Module" where
  "elect_first_module A p =
    ({a \<in> A. above (p!0) a = {a}},
    {a \<in> A. above (p!0) a \<noteq> {a}},
    {})"

subsection \<open>Soundness\<close>

theorem first_mod_is_em: "electoral_module elect_first_module"
proof (intro electoral_modI)
  fix
    A :: "'a set" and
    p :: "'a Profile"
  have "{a \<in> A. above (p!0) a = {a}} \<union> {a \<in> A. above (p!0) a \<noteq> {a}} = A"
    by blast
  hence "set_equals_partition A (elect_first_module A p)"
    by simp
  moreover have
    "(\<forall> a \<in> A. \<not>(a \<in> {a \<in> A.  above (p!0) a = {a}} \<and>
                 a \<in> {a \<in> A. above (p!0) a \<noteq> {a}}))"
    by simp
  hence "{a \<in> A. above (p!0) a = {a}} \<inter> {a \<in> A. above (p!0) a \<noteq> {a}} = {}"
    by blast
  hence "disjoint3 (elect_first_module A p)"
    by simp
  ultimately show "well_formed A (elect_first_module A p)"
    by auto
qed

end
