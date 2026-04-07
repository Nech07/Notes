# Research LLM Wiki Agent Contract

This vault follows a three-layer model derived from the LLM wiki pattern:

- `raw/` is the immutable source-of-truth layer.
- `wiki/` is the maintained knowledge layer.
- `AGENTS.md` plus the operational notes define the workflow contract.

## Ownership Rules

- The agent may read everything in the vault.
- The agent must never modify files under `raw/`.
- The agent may create and update notes under `wiki/`, `templates/`, `index.md`, `log.md`, and the operational docs when the workflow itself changes.
- Durable answers belong in the vault. If a query produces something worth keeping, file it as a note instead of leaving it in chat.

## Directory Semantics

- `raw/sources/`: raw markdown, PDFs, clips, transcripts, exports, and other source files
- `raw/assets/`: downloaded images and attachments referenced by source material
- `wiki/sources/`: source summary notes tied to raw materials or external URLs
- `wiki/concepts/`: topic pages, theory pages, and cross-source concept synthesis
- `wiki/entities/`: people, organizations, projects, tools, papers, books, and named artifacts
- `wiki/syntheses/`: comparisons, analyses, answers, reading notes, and evolving theses
- `wiki/outputs/`: canvases, slides, charts, and other presentation artifacts

## Search Tooling

- This vault is indexed in QMD as the `notes-wiki` collection.
- Prefer `qmd query ... -c notes-wiki` or `qmd search ... -c notes-wiki` over raw filesystem grep when searching the maintained wiki.
- After changing markdown in the vault, refresh the index with `qmd update` and refresh embeddings with `qmd embed` when semantic search needs to reflect the new notes.

## Required Frontmatter

All `wiki/` notes should include:

```yaml
---
title: Note Title
type: source|concept|entity|synthesis|output|index|dashboard|ops
status: seed|active|draft|stale|archived
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - area/topic
---
```

Additional fields by note type:

- Source notes: `source_kind`, `source_path` and/or `source_url`, optional `authors`, `published`, `ingested`
- Synthesis notes: `derived_from`, optional `question`
- Entity notes: optional `entity_type`

## Ingest Workflow

When ingesting a new source:

1. Identify the raw source file in `raw/sources/` or the external URL being summarized.
2. Create or update a source summary in `wiki/sources/` using [[templates/Source Template]].
3. Update any affected concept pages in `wiki/concepts/`.
4. Update any affected entity pages in `wiki/entities/`.
5. If the source changes the current synthesis, update or create a note in `wiki/syntheses/`.
6. Add or revise the relevant catalog entries in [[index]].
7. Append a dated entry to [[log]].

A single ingest is expected to touch multiple wiki notes when the source materially changes the knowledge base.

## Query Workflow

When answering a question from the vault:

1. Read [[index]] first to find candidate pages.
2. Read the relevant concept, entity, source, and synthesis notes.
3. Synthesize an answer with explicit links back to supporting notes or raw sources.
4. If the answer has lasting value, save it under `wiki/syntheses/` or `wiki/outputs/`.
5. Add the new page to [[index]] and append a query entry to [[log]].

## Lint Workflow

Periodically run a health check across the wiki and look for:

- stale claims superseded by newer sources
- contradictions between pages
- orphan pages with weak link coverage
- concepts or entities that are referenced often but have no dedicated note
- missing cross-references between obviously related notes
- synthesis notes that should be split or promoted into concept/entity pages

Record meaningful lint passes in [[log]] and update affected pages directly.

## Writing Guidance

- Prefer short sections with clear headings over long prose blocks.
- Use `[[wikilinks]]` for all internal references.
- Preserve uncertainty explicitly instead of flattening conflicting evidence.
- Keep raw-source interpretation separate from your own synthesis when that distinction matters.
- Default to additive, minimally destructive edits. If replacing an old claim, note what changed and why.
