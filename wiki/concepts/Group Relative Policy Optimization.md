---
title: Group Relative Policy Optimization
type: concept
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - rl/grpo
  - ml/reasoning
  - llm/alignment
---

# Summary

Group Relative Policy Optimization (GRPO) is a PPO-style reinforcement-learning method for language models that removes the separate value model and estimates advantage from relative scores within a group of sampled outputs for the same prompt. In this vault, it matters as DeepSeekMath's main RL contribution and as a bridge between outcome-based RL and comparison-based alignment methods.

## Current Understanding

- GRPO samples multiple responses per prompt, scores them, normalizes those scores within the group, and uses the relative signal as the advantage for policy updates.
- The main systems claim is efficiency: by avoiding a learned critic, GRPO reduces memory and compute overhead compared with actor-critic PPO.
- The main learning claim is that group-relative rewards align naturally with comparative supervision, because reward models often judge multiple candidate responses to the same question.
- In the DeepSeekMath paper, GRPO outperforms online rejection sampling fine-tuning and improves the already-strong instruction-tuned model on both in-domain and some out-of-domain math benchmarks.
- The paper also reports that process supervision works better than outcome-only supervision inside the GRPO framework, and that iterative RL helps further.
- The paper's own diagnostic is narrower than a generic "RL makes the model smarter" story: RL mostly improves Maj@K, not Pass@K, suggesting better distribution shaping and answer ranking rather than a large jump in underlying capability.

## Supporting Sources

- [[wiki/sources/DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models|DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models]]

## Related Concepts

- [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]]

## Related Entities

- [[wiki/entities/DeepSeekMath|DeepSeekMath]]

## Related Syntheses

- [[wiki/syntheses/DeepSeekMath on Data Quality and RL for Math Reasoning|DeepSeekMath on Data Quality and RL for Math Reasoning]]

## Open Questions

- How robust is GRPO when the reward model is noisy, weakly calibrated, or asked to evaluate outputs far outside its training distribution?
- Does the critic-free design remain advantageous when tasks require richer token-level credit assignment than math-answer correctness provides?
