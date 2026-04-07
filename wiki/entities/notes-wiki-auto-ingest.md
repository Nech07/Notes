---
title: notes-wiki-auto-ingest
type: entity
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - automation/service
  - operations/systemd
entity_type: project
---

# notes-wiki-auto-ingest

## Identity

`notes-wiki-auto-ingest` is the named automation bundle responsible for watching `raw/sources/` and orchestrating queued ingestion work for the research wiki vault.

## Components

- `notes-wiki-auto-ingest.path`
- `notes-wiki-auto-ingest.service`
- `notes-wiki-auto-ingest-drain.service`
- `notes-wiki-auto-ingest-drain.timer`

## Responsibilities

- Detect new source material in `raw/sources/`.
- For markdown notes, download remote asset URLs into `raw/assets/` and rewrite the source note to point at those local files.
- Hand the prepared source off for wiki ingestion without depending on the Obsidian CLI.

## Evidence

- [[ops/Vault Operations|Vault Operations]] describes the installed units and their roles.
- [[wiki/sources/Auto Ingest Test Note|Auto Ingest Test Note]] is a dedicated fixture meant to validate this automation path.

## Open Questions

- Where should successful runs be summarized inside the wiki beyond operational logs?
- If the workflow grows more complex, should this entity be split into separate notes for the watcher and drain worker?
