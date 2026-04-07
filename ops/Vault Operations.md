---
title: Vault Operations
type: ops
status: active
created: 2026-04-07
updated: 2026-04-07
tags:
  - operations
  - research/wiki
---

# Vault Operations

This note defines the repeatable workflows for maintaining the vault.

## Ingest

1. Put source files in `raw/sources/` and attachments in `raw/assets/`.
2. Create a summary note in `wiki/sources/` from [[templates/Source Template|Source Template]].
3. Update related notes in `wiki/concepts/` and `wiki/entities/`.
4. File any durable synthesis in `wiki/syntheses/`.
5. Update [[index]] and append an `ingest` entry to [[log]].
6. Run `qmd update` so keyword search sees the new notes.
7. Run `qmd embed` if semantic search should include the new material immediately.

### Auto-Ingest

- A user-level `systemd` watcher is installed for this vault:
  - `notes-wiki-auto-ingest.path`
  - `notes-wiki-auto-ingest.service`
- When a new note or source file appears in `raw/sources/`, the service:
  - waits for the file to finish writing
  - opens markdown notes in Obsidian
  - runs `editor:download-attachments`
  - ingests the source through Codex using the `wiki-ingest` skill
- State and logs live under `~/.local/state/notes-wiki-auto-ingest/`.

## Query

1. Start with [[index]].
2. Prefer `qmd query ... -c notes-wiki` for discovery, then read the most relevant source, concept, entity, and synthesis notes.
3. Answer from the maintained wiki rather than rediscovering from raw files when possible.
4. Save durable answers to `wiki/syntheses/` or `wiki/outputs/`.
5. Append a `query` entry to [[log]] when the answer becomes part of the vault.

## Lint

1. Scan for stale claims, contradictions, orphan notes, and missing pages.
2. Add missing cross-links and create missing concept or entity notes when repeated references justify them.
3. Update [[index]] if the note set changed.
4. Append a `lint` entry to [[log]] for meaningful maintenance passes.
5. Run `qmd update` and `qmd embed` if the lint pass materially changed the wiki graph.

## Metadata Rules

- Every `wiki/` note keeps `title`, `type`, `status`, `created`, `updated`, and `tags`.
- Use slash-style topic tags when useful, for example `ml/agents` or `biology/neuroscience`.
- Keep `updated` current when making substantive edits.

## Optional Power-User Layer

- The frontmatter schema is designed for Dataview and Bases, but the vault remains readable without them.
- Put generated canvases, slides, and visual deliverables in `wiki/outputs/`.
