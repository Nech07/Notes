---
title: DeepSeekMath
type: entity
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - project
  - math/llm
  - ml/reasoning
entity_type: project
---

# Summary

DeepSeekMath is a math-specialized open language-model project centered on a 7B model family, a large web-mined math corpus, and the GRPO reinforcement-learning recipe introduced in the corresponding paper. In this vault it is the main example of a data-centric, relatively small open model approaching closed-model performance on several math benchmarks.

## Relevance

- Demonstrates that a 7B open model can become highly competitive on MATH and related benchmarks when paired with targeted data selection, code-initialized pretraining, and post-training RL.
- Provides the main source in this vault for [[wiki/concepts/Group Relative Policy Optimization|Group Relative Policy Optimization]].
- Argues for a broader lesson that web-mined mathematical text may be more useful than expected, while arXiv-heavy corpora may be less useful than commonly assumed for the tested benchmarks.
- Connects mathematical RL to a unified view that also includes [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]] and rejection-sampling style methods.

## Related Concepts

- [[wiki/concepts/Group Relative Policy Optimization|Group Relative Policy Optimization]]
- [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]]

## Related Sources

- [[wiki/sources/DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models|DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models]]

## Notes

- The paper distinguishes DeepSeekMath-Base, DeepSeekMath-Instruct, and DeepSeekMath-RL as successive stages rather than unrelated models.
- The paper's strongest performance story is on competition-style math benchmarks, while it explicitly notes weaker geometry and theorem-proving performance relative to the best closed models.
