# Skillforge consolidated specification

This directory holds the consolidated form of the Skillforge specification. The
source conversations live in `draft/`. This directory is scratch. No
documentation convention governs it yet.

## Documents

| File | Scope |
|---|---|
| `01-vision.md` | What Skillforge is, what it refuses to be, and the principles that decide arguments. |
| `02-architecture.md` | Layers, source of truth, projection, materialization, and the boundary of the Rust CLI. |
| `03-skill-authoring-standard.md` | The method and the house profile that every skill built with Skillforge must satisfy, the `sf-` pack included. |
| `04-script-runtime-profile.md` | Bash and Python runtime policy, lifecycle phases, script contracts, and testing. |
| `05-landscape.md` | Prior art, the competitive matrix, and the positioning conclusion. |
| `06-references.md` | Every external source, with the ranking that applies when they disagree. |
| `07-provenance.md` | Where each document came from, and every position the drafts hold that the documents dropped. |
| `08-open-questions.md` | The queue of unresolved specification questions, one entry per question, plus the closed ones and where their answers landed. |

## Reading order

Read `01-vision.md` first. It defines the terms the other documents use. Read
`02-architecture.md` second. The rest are independent of each other.
`06-references.md` and `07-provenance.md` are lookup tables rather than
documents to read through. `08-open-questions.md` is a work queue, so read it
when you pick up the next question rather than in sequence.

## The relationship to the drafts

These documents hold the latest state. The three files in `draft/` hold the
conversations that produced it, and they stay unedited. If the two disagree,
these documents win, and `07-provenance.md` records why the draft position lost.

## Status

These documents record decisions, not implementation. No code in this
repository implements them yet.
