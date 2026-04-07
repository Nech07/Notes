---
title: Auto Ingest Test Note
type: source
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - source/test
  - automation/auto-ingest
source_kind: note
source_path: raw/sources/Auto Ingest Test Note.md
authors: []
published:
ingested: 2026-04-07
---

# Auto Ingest Test Note

## Summary

`raw/sources/Auto Ingest Test Note.md` is a controlled markdown fixture for validating the vault's auto-ingest path. It is written to exercise three pieces of the pipeline together: raw-source detection, direct asset localization into `raw/assets/`, and downstream wiki ingestion through the `wiki-ingest` workflow.

## Key Claims

- The note is intentionally disposable and exists to validate the auto-ingest system rather than to carry research content.
- The source includes one image reference so the asset-localization step has real work to perform before ingestion.
- The expected workflow is: detect the new source, download remote assets, rewrite the note to local paths, and ingest it into the wiki.

## Evidence and Notes

- The raw note states that it is a "controlled test note for the vault watcher."
- The source references a local asset path after normalization, which gives the asset-localization step a concrete target.
- The numbered list in the raw note describes the intended four-step watcher behavior.
- This source specifies expected behavior, not observed success. Runtime confirmation still belongs in logs or a follow-up synthesis.

## Linked Concepts

- [[wiki/concepts/Auto-Ingest Workflow|Auto-Ingest Workflow]]

## Linked Entities

- [[wiki/entities/notes-wiki-auto-ingest|notes-wiki-auto-ingest]]

## Linked Syntheses

- [[wiki/syntheses/Auto-Ingest Validation Fixture|Auto-Ingest Validation Fixture]]

## Open Questions

- Which log or state artifact should be treated as the authoritative proof that the end-to-end pipeline completed successfully for this fixture?
