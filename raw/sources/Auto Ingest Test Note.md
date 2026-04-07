---
title: "Auto Ingest Test Note"
source: "controlled-test"
author:
published:
created: 2026-04-07
description: "Disposable note for validating auto-download and auto-ingest."
tags:
  - "clippings"
  - "test/auto-ingest"
---

# Auto Ingest Test Note

This is a controlled test note for the vault watcher.

The note includes one remote image so `editor:download-attachments` has real work to do.

![](https://httpbin.org/image/png)

If the automation works, the watcher should:

1. Detect this new note in `raw/sources/`
2. Open it in Obsidian
3. Run the attachment downloader
4. Ingest the note into the wiki

