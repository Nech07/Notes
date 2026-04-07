---
title: Auto-Ingest Workflow
type: concept
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - automation/auto-ingest
  - operations/workflow
---

# Auto-Ingest Workflow

## Definition

The auto-ingest workflow is the vault-maintenance path that turns a new item under `raw/sources/` into maintained wiki notes. Markdown sources may be normalized first so remote assets become local files under `raw/assets/`.

## Current Flow

1. A new source appears in `raw/sources/`.
2. The `[[wiki/entities/notes-wiki-auto-ingest|notes-wiki-auto-ingest]]` automation queues and later processes the item.
3. For markdown sources, the worker downloads remote asset URLs directly into `raw/assets/` and rewrites the note to reference those local files.
4. The source is ingested into the wiki as a source note with linked concept, entity, and synthesis updates.
5. `qmd` state is refreshed so keyword and semantic discovery reflect the new wiki material.

## Supporting Sources

- [[ops/Vault Operations|Vault Operations]] defines the intended automation and the supporting `systemd` units.
- [[wiki/sources/Auto Ingest Test Note|Auto Ingest Test Note]] is a controlled fixture designed to exercise this workflow.

## Constraints

- PDFs and other non-markdown raw files remain immutable throughout the process.
- Markdown notes in `raw/sources/` are allowed to change only for local asset normalization.
- The workflow is only partially evidenced by documentation and test fixtures in the current vault snapshot.
- A source note describing expected behavior is not the same as a runtime success record.

## Related Notes

- [[wiki/syntheses/Auto-Ingest Validation Fixture|Auto-Ingest Validation Fixture]]
