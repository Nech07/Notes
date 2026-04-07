---
title: DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models
type: source
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - ml/reasoning
  - math/llm
  - rl/grpo
source_kind: paper
source_path: raw/sources/DeepSeekMath Pushing the Limits of Mathematical Reasoning in Open Language Models.md
source_url: https://arxiv.org/html/2402.03300v3
authors:
  - Zhihong Shao
  - Peiyi Wang
  - Qihao Zhu
  - Runxin Xu
  - Junxiao Song
  - Xiao Bi
  - Haowei Zhang
  - Mingchuan Zhang
  - Y.K. Li
  - Y. Wu
  - Daya Guo
published: 2024
ingested: 2026-04-07
---

# Summary

This paper presents [[wiki/entities/DeepSeekMath|DeepSeekMath]] as a strong open 7B math-reasoning system built from three main ingredients: a large web-mined multilingual math corpus, initialization from a code model, and reinforcement learning with [[wiki/concepts/Group Relative Policy Optimization|Group Relative Policy Optimization]]. It argues that open mathematical reasoning performance is highly sensitive to data selection and training procedure, not just parameter count.

## Key Claims

- A carefully engineered Common Crawl mining pipeline can produce a high-quality 120B-token math corpus that materially outperforms prior open math corpora in both English and Chinese math benchmarks.
- Initializing math training from a code model helps mathematical reasoning, especially for tool-using and program-aided settings.
- [[wiki/concepts/Group Relative Policy Optimization|Group Relative Policy Optimization]] improves mathematical reasoning while reducing PPO-style training cost by removing the separate critic model and estimating advantages from within-group relative rewards.
- In the paper's experiments, arXiv-heavy math corpora do not noticeably improve the targeted math benchmarks, which pushes against a common assumption that formal academic text is the most useful math pretraining source.
- The paper's own RL evidence suggests much of the gain comes from improving response distribution and selection robustness rather than fundamentally expanding the model's latent capability.

## Evidence and Notes

- The paper reports that DeepSeekMath-Base 7B reaches 64.2% on GSM8K and 36.2% on MATH, outperforming much larger open and some closed baselines in the paper's evaluation setup.
- DeepSeekMath-Instruct 7B reaches 46.8% on MATH, while DeepSeekMath-RL 7B reaches 51.7%, with additional gains on Chinese math benchmarks.
- The reported RL setup trains only on chain-of-thought GSM8K and MATH instruction data, yet improves across all listed evaluation metrics, including some out-of-domain benchmarks.
- Section 5 argues that code pretraining improves math reasoning and that mixed code-plus-math training helps preserve tool-use capability, though the exact tradeoff depends on scale and training schedule.
- The arXiv result is narrower than it may sound. The paper explicitly limits the claim to the tasks, mixtures, and scales they tested, and leaves open whether arXiv helps at larger scales or in other task families.
- The paper places [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]], RFT, PPO, and GRPO in a unified view where methods differ mainly in data source, reward function, and gradient-coefficient construction.

## Linked Concepts

- [[wiki/concepts/Group Relative Policy Optimization|Group Relative Policy Optimization]]
- [[wiki/concepts/Direct Preference Optimization|Direct Preference Optimization]]

## Linked Entities

- [[wiki/entities/DeepSeekMath|DeepSeekMath]]

## Linked Syntheses

- [[wiki/syntheses/DeepSeekMath on Data Quality and RL for Math Reasoning|DeepSeekMath on Data Quality and RL for Math Reasoning]]

## Open Questions

- How much of DeepSeekMath's gain comes from corpus quality versus the decision to start from a code model?
- Does GRPO transfer as cleanly outside mathematical reasoning, where correctness is harder to score and reward models are less grounded?
- The paper claims arXiv data looks weak for these benchmarks, but would that still hold at larger model scales or in mixtures designed around formal mathematics?
