---
title: Direct Preference Optimization Your Language Model is Secretly a Reward Model
type: entity
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - paper
  - llm/alignment
  - preference-optimization
entity_type: paper
---

# Summary

This paper is the canonical source for DPO as an RL-free preference-optimization method for language models. It frames DPO as a reparameterization of the usual KL-constrained RLHF objective rather than as an unrelated heuristic.

## Relevance

- Establishes the core DPO objective and the "implicit reward model" interpretation that later work builds on.
- Provides both the main derivation and the theoretical argument that the reward reparameterization preserves the relevant reward equivalence classes.
- Supplies the early empirical case that DPO can outperform PPO-based RLHF while being easier to implement and tune.

## Related Concepts

- [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]]

## Related Sources

- [[wiki/sources/Direct Preference Optimization Your Language Model is Secretly a Reward Model|Direct Preference Optimization Your Language Model is Secretly a Reward Model]]

## Notes

- Authors: Rafael Rafailov, Archit Sharma, Eric Mitchell, Stefano Ermon, Christopher D. Manning, and Chelsea Finn.
- The source note captures the paper's argument structure; the synthesis note captures the specific claim that the policy is an implicit reward model.
