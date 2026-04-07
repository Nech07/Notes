---
title: Direct Preference Optimization Your Language Model is Secretly a Reward Model
type: source
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - llm/alignment
  - preference-optimization
  - rlhf
source_kind: paper
source_path: raw/sources/Direct Preference Optimization Your Language Model is Secretly a Reward Model.md
source_url: https://arxiv.org/html/2305.18290v3
authors:
  - Rafael Rafailov
  - Archit Sharma
  - Eric Mitchell
  - Stefano Ermon
  - Christopher D. Manning
  - Chelsea Finn
published:
ingested: 2026-04-07
---

# Summary

This paper introduces [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]] as a way to optimize language models from pairwise preference data without training a separate reward model or running reinforcement learning. Its central move is a change of variables: under the usual KL-constrained RLHF objective, the optimal reward and optimal policy are linked closely enough that the policy can be optimized directly with a binary cross-entropy loss over preferred and dispreferred responses.

## Key Claims

- DPO optimizes the same KL-constrained reward maximization target used in standard RLHF, but does so with a simple classification objective instead of PPO-style reinforcement learning.
- The policy can be interpreted as an implicit reward model through the reparameterization `r(x, y) = beta * log(pi(y|x) / pi_ref(y|x))`.
- Under Bradley-Terry and more general Plackett-Luce preference models, the reward reparameterization does not reduce the class of representable optimal reward functions.
- Empirically, DPO matches or beats PPO-based baselines in controlled sentiment generation, TL;DR summarization, and single-turn dialogue, while being simpler and more stable to train.
- The paper argues that actor-critic RLHF pipelines inherit instability from reward normalization and value estimation, and that DPO avoids those baselines entirely.

## Evidence and Notes

- Section 4 derives the DPO objective by rewriting the KL-constrained RLHF optimum in terms of policy ratios relative to a reference model, then maximizing preference likelihood directly.
- Section 5.1 formalizes the "secretly a reward model" claim by defining reward-equivalence classes and showing the DPO parameterization can represent any reward class consistent with Bradley-Terry / Plackett-Luce preferences.
- Section 5.2 argues PPO-style RLHF is burdened by a normalization term that behaves like a soft value function, which helps explain training instability.
- Section 6 reports that DPO dominates PPO on the reward-vs-KL frontier in controlled sentiment generation and achieves better or similar win rates on TL;DR summarization and Anthropic HH dialogue.
- The evaluation story is promising but not cleanly final: GPT-4 is used as an automatic judge for summarization and dialogue, and the paper includes a limited human validation study rather than relying on human evaluation throughout.

## Linked Concepts

- [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]]

## Linked Entities

- [[wiki/entities/Direct Preference Optimization Your Language Model is Secretly a Reward Model|Direct Preference Optimization Your Language Model is Secretly a Reward Model]]

## Linked Syntheses

- [[wiki/syntheses/DPO as Implicit Reward Modeling|DPO as Implicit Reward Modeling]]

## Open Questions

- How well does DPO generalize out of distribution compared with approaches that learn an explicit reward model?
- How much of DPO's reported advantage comes from optimization stability versus the exact parameterization of the implicit reward?
- The paper validates GPT-4 judgments with a small human study, but stronger evaluation evidence would still be useful for high-stakes alignment claims.
