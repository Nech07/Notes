---
title: Direct Preference Optimization
type: concept
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - llm/alignment
  - preference-optimization
  - rlhf
---

# Summary

Direct Preference Optimization (DPO) is a preference-learning method for language-model alignment that replaces the usual "fit reward model, then run RL" pipeline with a direct objective on policy log-probability ratios. In this vault, it matters as a foundational alternative to PPO-style RLHF and as a concrete example of implicit reward modeling.

## Current Understanding

- DPO starts from the standard KL-regularized RLHF objective and uses the closed-form optimum of that objective to rewrite reward differences in terms of policy ratios against a reference model.
- Under Bradley-Terry preference assumptions, the partition function cancels when comparing two responses, so preference likelihood can be optimized directly with a logistic loss.
- The resulting update increases the likelihood of preferred responses and decreases the likelihood of dispreferred responses, while weighting examples by how wrongly the current implicit reward orders them.
- The method treats the policy as an implicit reward model, not because rewards disappear, but because reward information is encoded in the log-ratio between the learned policy and the reference policy.
- The paper's empirical case is that DPO is both simpler and stronger than PPO-style RLHF on several tasks, though some evaluation depends on GPT-4-as-judge and leaves room for stronger human verification.

## Supporting Sources

- [[wiki/sources/Direct Preference Optimization Your Language Model is Secretly a Reward Model|Direct Preference Optimization Your Language Model is Secretly a Reward Model]]

## Related Entities

- [[wiki/entities/Direct Preference Optimization Your Language Model is Secretly a Reward Model|Direct Preference Optimization Your Language Model is Secretly a Reward Model]]

## Related Syntheses

- [[wiki/syntheses/DPO as Implicit Reward Modeling|DPO as Implicit Reward Modeling]]

## Open Questions

- How robust is DPO when the preference model assumptions are wrong or when the preference dataset is narrow or noisy?
- Which later alignment methods genuinely extend DPO, and which are mostly implementation variants around the same core derivation?
