---
title: Auto-Ingest Validation Fixture
type: synthesis
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - automation/validation
  - operations/testing
derived_from:
  - [[wiki/sources/Auto Ingest Test Note|Auto Ingest Test Note]]
  - [[ops/Vault Operations|Vault Operations]]
question: What does the Auto Ingest Test Note validate about the current auto-ingest workflow?
---

# Auto-Ingest Validation Fixture

## Answer

The fixture validates the intended shape of the markdown auto-ingest path: a new note under `raw/sources/` should be detected, have its remote asset references localized into `raw/assets/`, and then be ingested into the maintained wiki. It is useful as a deterministic test input because it is small, explicit about expected steps, and includes an attachment reference that forces non-trivial preprocessing.

## What The Source Supports Directly

- The raw fixture explicitly states the four expected watcher steps.
- The fixture includes a linked image, so attachment download is part of the test rather than an optional branch.
- [[ops/Vault Operations|Vault Operations]] independently documents the same intended automation path.

## What Remains Uncertain

- The fixture itself does not prove that a run succeeded.
- The current wiki snapshot does not yet include a separate success report sourced from runtime logs or worker state.
- Operational validation still depends on external evidence such as the watcher logs or state files under `~/.local/state/notes-wiki-auto-ingest/`.

## Related Notes

- [[wiki/concepts/Auto-Ingest Workflow|Auto-Ingest Workflow]]
- [[wiki/entities/notes-wiki-auto-ingest|notes-wiki-auto-ingest]]
