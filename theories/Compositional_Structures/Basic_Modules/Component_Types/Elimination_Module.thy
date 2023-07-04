(*  File:       Elimination_Module.thy
    Copyright   2021  Karlsruhe Institute of Technology (KIT)
*)
\<^marker>\<open>creator "Stephan Bohr, Karlsruhe Institute of Technology (KIT)"\<close>
\<^marker>\<open>contributor "Michael Kirsten, Karlsruhe Institute of Technology (KIT)"\<close>

section \<open>Elimination Module\<close>

theory Elimination_Module
  imports Evaluation_Function
          Electoral_Module
begin

text \<open>
  This is the elimination module. It rejects a set of alternatives only if
  these are not all alternatives. The alternatives potentially to be rejected
  are put in a so-called elimination set. These are all alternatives that score
  below a preset threshold value that depends on the specific voting rule.
\<close>

subsection \<open>Definition\<close>

type_synonym Threshold_Value = nat

type_synonym Threshold_Relation = "nat \<Rightarrow> nat \<Rightarrow> bool"

type_synonym 'a Electoral_Set = "'a set \<Rightarrow> 'a Profile \<Rightarrow> 'a set"

fun elimination_set :: "'a Evaluation_Function \<Rightarrow> Threshold_Value \<Rightarrow>
                            Threshold_Relation \<Rightarrow> 'a Electoral_Set" where
 "elimination_set e t r A p = {a \<in> A . r (e a A p) t }"

fun elimination_module :: "'a Evaluation_Function \<Rightarrow> Threshold_Value \<Rightarrow>
                            Threshold_Relation \<Rightarrow> 'a Electoral_Module" where
  "elimination_module e t r A p =
      (if (elimination_set e t r A p) \<noteq> A
        then ({}, (elimination_set e t r A p), A - (elimination_set e t r A p))
        else ({}, {}, A))"

subsection \<open>Common Eliminators\<close>

fun less_eliminator :: "'a Evaluation_Function \<Rightarrow> Threshold_Value \<Rightarrow>
                            'a Electoral_Module" where
  "less_eliminator e t A p = elimination_module e t (<) A p"

fun max_eliminator :: "'a Evaluation_Function \<Rightarrow> 'a Electoral_Module" where
  "max_eliminator e A p =
    less_eliminator e (Max {e x A p | x. x \<in> A}) A p"

fun leq_eliminator :: "'a Evaluation_Function \<Rightarrow> Threshold_Value \<Rightarrow> 'a Electoral_Module" where
  "leq_eliminator e t A p = elimination_module e t (\<le>) A p"

fun min_eliminator :: "'a Evaluation_Function \<Rightarrow> 'a Electoral_Module" where
  "min_eliminator e A p =
    leq_eliminator e (Min {e x A p | x. x \<in> A}) A p"

fun average :: "'a Evaluation_Function \<Rightarrow> 'a set \<Rightarrow> 'a Profile \<Rightarrow> Threshold_Value" where
  "average e A p = (\<Sum> x \<in> A. e x A p) div (card A)"

fun less_average_eliminator :: "'a Evaluation_Function \<Rightarrow> 'a Electoral_Module" where
  "less_average_eliminator e A p = less_eliminator e (average e A p) A p"

fun leq_average_eliminator :: "'a Evaluation_Function \<Rightarrow> 'a Electoral_Module" where
  "leq_average_eliminator e A p = leq_eliminator e (average e A p) A p"

subsection \<open>Auxiliary Lemmas\<close>

lemma score_bounded:
  fixes
    e :: "'a \<Rightarrow> nat" and
    A :: "'a set" and
    a :: "'a"
  assumes
    a_in_A: "a \<in> A" and
    fin_A: "finite A"
  shows "e a \<le> Max {e x | x. x \<in> A}"
proof -
  have "e a \<in> {e x |x. x \<in> A}"
    using a_in_A
    by blast
  thus ?thesis
    using fin_A Max_ge
    by simp
qed

lemma max_score_contained:
  fixes
    e :: "'a \<Rightarrow> nat" and
    A :: "'a set" and
    a :: "'a"
  assumes
    A_not_empty: "A \<noteq> {}" and
    fin_A: "finite A"
  shows "\<exists> b \<in> A. e b = Max {e x | x. x \<in> A}"
proof -
  have "finite {e x | x. x \<in> A}"
    using fin_A
    by simp
  hence "Max {e x | x. x \<in> A} \<in> {e x | x. x \<in> A}"
    using A_not_empty Max_in
    by blast
  thus ?thesis
    by auto
qed

lemma elimset_in_alts:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value" and
    r :: "Threshold_Relation" and
    A :: "'a set" and
    p :: "'a Profile"
  shows "elimination_set e t r A p \<subseteq> A"
  unfolding elimination_set.simps
  by safe

subsection \<open>Soundness\<close>

lemma elim_mod_sound[simp]:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value" and
    r :: "Threshold_Relation"
  shows "electoral_module (elimination_module e t r)"
  unfolding electoral_module_def
  by auto

lemma less_elim_sound[simp]:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value"
  shows "electoral_module (less_eliminator e t)"
  unfolding electoral_module_def
  by auto

lemma leq_elim_sound[simp]:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value"
  shows "electoral_module (leq_eliminator e t)"
  unfolding electoral_module_def
  by auto

lemma max_elim_sound[simp]:
  fixes e :: "'a Evaluation_Function"
  shows "electoral_module (max_eliminator e)"
  unfolding electoral_module_def
  by auto

lemma min_elim_sound[simp]:
  fixes e :: "'a Evaluation_Function"
  shows "electoral_module (min_eliminator e)"
  unfolding electoral_module_def
  by auto

lemma less_avg_elim_sound[simp]:
  fixes e :: "'a Evaluation_Function"
  shows "electoral_module (less_average_eliminator e)"
  unfolding electoral_module_def
  by auto

lemma leq_avg_elim_sound[simp]:
  fixes e :: "'a Evaluation_Function"
  shows "electoral_module (leq_average_eliminator e)"
  unfolding electoral_module_def
  by auto

subsection \<open>Non-Blocking\<close>

lemma elim_mod_non_blocking:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value" and
    r :: "Threshold_Relation"
  shows "non_blocking (elimination_module e t r)"
  unfolding non_blocking_def
  by auto

lemma less_elim_non_blocking:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value"
  shows "non_blocking (less_eliminator e t)"
  unfolding less_eliminator.simps
  using elim_mod_non_blocking
  by auto

lemma leq_elim_non_blocking:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value"
  shows "non_blocking (leq_eliminator e t)"
  unfolding leq_eliminator.simps
  using elim_mod_non_blocking
  by auto

lemma max_elim_non_blocking:
  fixes e :: "'a Evaluation_Function"
  shows "non_blocking (max_eliminator e)"
  unfolding non_blocking_def
  using electoral_module_def
  by auto

lemma min_elim_non_blocking:
  fixes e :: "'a Evaluation_Function"
  shows "non_blocking (min_eliminator e)"
  unfolding non_blocking_def
  using electoral_module_def
  by auto

lemma less_avg_elim_non_blocking:
  fixes e :: "'a Evaluation_Function"
  shows "non_blocking (less_average_eliminator e)"
  unfolding non_blocking_def
  using electoral_module_def
  by auto

lemma leq_avg_elim_non_blocking:
  fixes e :: "'a Evaluation_Function"
  shows "non_blocking (leq_average_eliminator e)"
  unfolding non_blocking_def
  using electoral_module_def
  by auto

subsection \<open>Non-Electing\<close>

lemma elim_mod_non_electing:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value" and
    r :: "Threshold_Relation"
  shows "non_electing (elimination_module e t r)"
  unfolding non_electing_def
  by simp

lemma less_elim_non_electing:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value"
  shows "non_electing (less_eliminator e t)"
  using elim_mod_non_electing less_elim_sound
  unfolding non_electing_def
  by simp

lemma leq_elim_non_electing:
  fixes
    e :: "'a Evaluation_Function" and
    t :: "Threshold_Value"
  shows "non_electing (leq_eliminator e t)"
  unfolding non_electing_def
  by simp

lemma max_elim_non_electing:
  fixes e :: "'a Evaluation_Function"
  shows "non_electing (max_eliminator e)"
  unfolding non_electing_def
  by simp

lemma min_elim_non_electing:
  fixes e :: "'a Evaluation_Function"
  shows "non_electing (min_eliminator e)"
  unfolding non_electing_def
  by simp

lemma less_avg_elim_non_electing:
  fixes e :: "'a Evaluation_Function"
  shows "non_electing (less_average_eliminator e)"
  unfolding non_electing_def
  by auto

lemma leq_avg_elim_non_electing:
  fixes e :: "'a Evaluation_Function"
  shows "non_electing (leq_average_eliminator e)"
  unfolding non_electing_def
  by simp

subsection \<open>Inference Rules\<close>

text \<open>
  If the used evaluation function is Condorcet rating,
    max-eliminator is Condorcet compatible.
\<close>

theorem cr_eval_imp_ccomp_max_elim[simp]:
  fixes e :: "'a Evaluation_Function"
  assumes "condorcet_rating e"
  shows "condorcet_compatibility (max_eliminator e)"
proof (unfold condorcet_compatibility_def, safe)
  show "electoral_module (max_eliminator e)"
    by simp
next
  fix
    A :: "'a set" and
    p :: "'a Profile" and
    a :: "'a"
  assume
    c_win: "condorcet_winner A p a" and
    rej_a: "a \<in> reject (max_eliminator e) A p"
  have "e a A p = Max {e b A p | b. b \<in> A}"
    using c_win cond_winner_imp_max_eval_val assms
    by fastforce
  hence "a \<notin> reject (max_eliminator e) A p"
    by simp
  thus "False"
    using rej_a
    by linarith
next
  fix
    A :: "'a set" and
    p :: "'a Profile" and
    a :: "'a"
  assume "a \<in> elect (max_eliminator e) A p"
  moreover have "a \<notin> elect (max_eliminator e) A p"
    by simp
  ultimately show False
    by linarith
next
  fix
    A :: "'a set" and
    p :: "'a Profile" and
    a :: "'a" and
    a' :: "'a"
  assume
    "condorcet_winner A p a" and
    "a \<in> elect (max_eliminator e) A p"
  thus "a' \<in> reject (max_eliminator e) A p"
    using condorcet_winner.elims(2) empty_iff max_elim_non_electing
    unfolding non_electing_def
    by metis
qed

lemma cr_eval_imp_dcc_max_elim_helper:
  fixes
    A :: "'a set" and
    p :: "'a Profile" and
    e :: "'a Evaluation_Function" and
    a :: "'a"
  assumes
    "finite_profile A p" and
    "condorcet_rating e" and
    "condorcet_winner A p a"
  shows "elimination_set e (Max {e b A p | b. b \<in> A}) (<) A p = A - {a}"
proof (safe, simp_all, safe)
  assume "e a A p < Max {e b A p | b. b \<in> A}"
  thus False
    using cond_winner_imp_max_eval_val assms
    by fastforce
next
  fix a' :: "'a"
  assume
    "a' \<in> A" and
    "\<not> e a' A p < Max {e b A p | b. b \<in> A}"
  thus "a' = a"
    using non_cond_winner_not_max_eval assms
    by (metis (mono_tags, lifting))
qed

text \<open>
  If the used evaluation function is Condorcet rating, max-eliminator
  is defer-Condorcet-consistent.
\<close>

theorem cr_eval_imp_dcc_max_elim[simp]:
  fixes e :: "'a Evaluation_Function"
  assumes "condorcet_rating e"
  shows "defer_condorcet_consistency (max_eliminator e)"
proof (unfold defer_condorcet_consistency_def, safe, simp)
  fix
    A :: "'a set" and
    p :: "'a Profile" and
    a :: "'a"
  assume
    winner: "condorcet_winner A p a" and
    finite: "finite A"
  hence profile: "finite_profile A p"
    by simp
  let ?trsh = "Max {e b A p | b. b \<in> A}"
  show
    "max_eliminator e A p =
      ({},
        A - defer (max_eliminator e) A p,
        {b \<in> A. condorcet_winner A p b})"
  proof (cases "elimination_set e (?trsh) (<) A p \<noteq> A")
    have elim_set: "(elimination_set e ?trsh (<) A p) = A - {a}"
      using profile assms winner cr_eval_imp_dcc_max_elim_helper
      by (metis (mono_tags, lifting))
    case True
    hence
      "max_eliminator e A p =
        ({},
          (elimination_set e ?trsh (<) A p),
          A - (elimination_set e ?trsh (<) A p))"
      by simp
    also have "... = ({}, A - {a}, {a})"
      using elim_set winner
      by auto
    also have "... = ({},A - defer (max_eliminator e) A p, {a})"
      using calculation
      by simp
    also have "... = ({}, A - defer (max_eliminator e) A p, {b \<in> A. condorcet_winner A p b})"
      using cond_winner_unique_3 winner Collect_cong
      by (metis (no_types, lifting))
    finally show ?thesis
      using finite winner
      by metis
  next
    case False
    moreover have "?trsh = e a A p"
      using assms winner
      by (simp add: cond_winner_imp_max_eval_val)
    ultimately show ?thesis
      using winner
      by auto
  qed
qed

section \<open>Aux lemmas for constructing established voting rules as max eliminator\<close>

lemma score_bounded:
  fixes f:: "'a \<Rightarrow> nat"
  fixes A :: "'a set"
  fixes alt :: 'a
  assumes aA: "alt \<in> A" and fina: "finite A"
  shows "f alt \<le> Max {f x |x. x \<in> A}"
proof -
  from aA have "f alt \<in> {f x |x. x \<in> A}" by blast
  from fina this show ?thesis using Max_ge by auto
qed

lemma max_score_in:
  fixes f:: "'a \<Rightarrow> nat"
  fixes alt :: 'a
  fixes A :: "'a set"
  assumes aA: "A \<noteq> {}" and fina: "finite A"
  shows "(\<exists> alt \<in> A. f alt = Max {f x |x. x \<in> A})"
proof -
  from aA have nemp: " {f x |x. x \<in> A} \<noteq> {}" by simp
  from fina have "finite {f x |x. x \<in> A}" by simp
  from nemp this Max_in[where A = "{f x |x. x \<in> A}"]  have "Max {f x |x. x \<in> A} \<in> {f x |x. x \<in> A}"
    by blast
  from this show ?thesis by auto
qed


end
