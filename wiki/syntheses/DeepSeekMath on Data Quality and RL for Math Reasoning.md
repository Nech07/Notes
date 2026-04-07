---
title: DeepSeekMath on Data Quality and RL for Math Reasoning
type: synthesis
status: draft
created: 2026-04-07
updated: 2026-04-07
tags:
  - math/llm
  - synthesis
  - rl/grpo
derived_from:
  - wiki/sources/DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models
  - wiki/concepts/Group Relative Policy Optimization
question: What does DeepSeekMath say matters most for open mathematical reasoning?
---

# Question

What does DeepSeekMath say matters most for open mathematical reasoning?

## Short Answer

The paper's answer is mostly data and training procedure, not raw scale alone. Its core recipe is: start from a code-capable base model, continue pretraining on a large high-quality multilingual math corpus mined from the web, then use GRPO-style RL to reshape the output distribution. The paper's own diagnostics suggest the RL stage mostly improves robustness and answer selection rather than creating entirely new mathematical capability.

## Evidence

- [[wiki/sources/DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models|DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models]] reports that the 120B-token DeepSeekMath Corpus substantially outperforms smaller open math corpora in the paper's benchmark suite.
- The same source argues that code pretraining is a useful precursor for math reasoning, especially when tool use or program synthesis matters.
- [[wiki/concepts/Group Relative Policy Optimization|Group Relative Policy Optimization]] captures the post-training lesson: critic-free relative-reward RL can produce meaningful gains on top of strong instruction tuning without the full PPO memory burden.
- The paper's discussion section adds an important caveat: RL improves Maj@K more than Pass@K, which is evidence for better ranking and distribution shaping rather than a clean jump in fundamental ability.
- The source also reports a counterintuitive negative result: arXiv-only corpora do not help much on the tested math benchmarks, so "more formal text" is not automatically "better pretraining data."

## Tensions and Uncertainty

- The arXiv result is explicitly limited by task choice, data mixture, and model scale. It should not be read as a general proof that arXiv is unhelpful for mathematical language models.
- The RL conclusion is strong on benchmark gains but weaker on mechanism. If Pass@K barely changes, the method may be improving policy calibration or search over existing capabilities more than reasoning depth itself.
- The paper still trails the strongest closed models in some areas, especially geometry, theorem proving, and few-shot improvement.

## Follow-Ups

- Compare GRPO with DPO and PPO once the vault contains a PPO-focused source note.
- Add a dedicated note on math-data construction if more sources about corpus mining or web filtering are ingested.
