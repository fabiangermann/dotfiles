# Documentation

What to document and where: README, ARCHITECTURE.md, decision records, and
the wording rules for all of them, including docstrings and comments.

- Maintain documentation that covers the whole project, not just recently
  changed parts.
- Beyond its conventional purpose, documentation exists to facilitate
  review: a documentation change should summarize the corresponding code
  change, so a reviewer can read it at the start of a review to ease
  comprehension of the code that follows.
- Write documentation alongside the code changes it describes, not after
  the fact — the review-facilitation purpose above depends on it staying
  current.

## Wording (all documentation, docstrings and comments)

- **Plain words over compressed ones.** Use the conventional term, not an
  idiom or a shortened phrase ("depends on", not "sits on"). If a sentence
  only makes sense once you've read the code, it is too compressed.
- **Say who acts on what.** "Assigns each log line's User-Agent to a
  crawler", not "attributes a User-Agent to a crawler": the reader must not
  have to guess the direction.
- **Define a project term where its mechanism is described.** Once, in the
  place that explains what the term belongs to. Text before that point says
  the same thing in plain words, without the term.
- **Lists for parallel items.** When the content is a set of parallel items,
  write a list, not one sentence joining them with commas.

## User-facing documentation (README, guides)

Document what a reader must know or do: how to install or enable a feature,
non-obvious output or behavior, edge cases that require action, and failure
modes. Cut anything that only confirms what a reader already expects — sensible
defaults, opt-in wiring a code example already shows, or internal robustness
the library handles transparently and the user never touches. Same litmus as
docstrings: if a line earns its place only because you know the design history,
cut it. Let a code example carry the mechanics rather than restating them
in prose.

## Architecture documentation (`docs/ARCHITECTURE.md`)

Strongly based on Alex Kladov's (matklad)
["ARCHITECTURE.md"](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html),
2021 (worked example: rust-analyzer's
`docs/book/src/contributing/architecture.md`), but optimized for a workflow
where agents write the code and update this document in the same change.
Where the rules below differ from the source, they take precedence.

A map for a reader who needs to find *where* to change something, not an
explanation of how the code works. Write one when I ask for it, following
the rules below; keep an existing one current in whatever format it already
uses — other section names or order, a different marker convention, no
codemap at all. For a document already in the repo these rules are a source
of ideas, not a reformatting mandate: extend it in its own idiom, and
propose a restructuring separately if you think it is worth doing.

**Keep it current.** Update it in the same change that adds or removes a
component, moves a boundary between components, or invalidates an invariant
it states. Routine work inside an existing component leaves it alone — if
ordinary changes keep forcing edits, the entry was written at too fine a
grain.

**Structure:**

1. **Bird's eye view** — the problem the project solves, what goes in, and
   what comes out, in a few paragraphs. Enough that a reader who knows the
   domain but not the code can already guess roughly where things live.
2. **Entry points** — where execution starts, and the path from there to the
   codemap's components, in a few lines.
3. **Codemap** — the coarse-grained components in dependency order, every
   entry built from the same elements, in this order:
   - **Purpose** — always: at most three sentences, the first starting with
     a verb, saying what the component does for the project ("Identifies
     which crawler, if any, made a request."). Not a noun phrase naming what
     it holds or produces.
   - **Design note** — only where an unexpected design choice shapes the
     component: one or two sentences naming that choice ("a hand-written
     parser that emits events instead of building a tree").
   - **Responsibilities** — only where the component covers several things:
     a list of what it is responsible for, one item each. Where one name
     handles the responsibility, start the item with it (`` `CrawlerMatcher`:
     assigns each log line's User-Agent to a crawler ``); otherwise describe
     it without one. Prose only where the entry describes a single role. Only
     what a reader needs to find their way in: a map of the country, not an
     atlas of its states.
   - **Depends on** — only where it depends on anything: a line naming the
     modules it depends on, with what it uses from each (`Depends on models
     (Crawler).`), plus the external packages or binaries it pulls in.
   - **Invariants and boundaries** — only where it has any: the markers
     described below.
   - **See also** — only where other documentation goes deeper: a closing
     pointer to it, by name.

   Name the files, modules and types a reader should search for; don't link
   them — links go stale, symbol search doesn't. Stop at the grain where the
   reader can open the right file; how that file works is the docstrings' job.
4. **Cross-cutting concerns** — what no single component owns: code
   generation, error handling, testing strategy, logging, configuration
   loading, cancellation.

**Mark invariants and boundaries inline in the codemap, where they apply, in
a greppable form:**

- `**Architecture Invariant:** the parser never sees the concrete tree type.`
  Only for a rule the design depends on, never for something that merely
  happens to be true of the current code. Absences ("the model layer
  imports nothing from the view layer", "nothing below the storage boundary
  opens a socket") are the most valuable kind, because a reader cannot
  discover them by reading the code. They are also the easiest to
  over-collect: most missing imports are incidental.
  - **Test each candidate:** name the purpose it serves — what would break
    or get worse (layering, testability, swapping an implementation) if a
    future change violated it. If you cannot name one, leave it out: an
    invariant forbids future work, so a spurious one has a cost.
  - **If in doubt, ask.** When you can name a plausible purpose but are not
    sure the design actually relies on it, don't write it in. List it as an
    open question for me when you hand over the document.
- `**API Boundary:** everything outside this subtree goes through the facade
  module.` A boundary says which parts are interchangeable and which are
  contracts — invisible in a directory listing.

**Keep it short.** A page or two. Every recurring contributor rereads it,
and every extra sentence is one more thing a future change can falsify.
Write only what is unlikely to churn: where part of the system is still
moving, say so in one line rather than describing its current shape in five
— in the component's entry, or at the top of the codemap when it concerns
several.
Revisit the whole document a couple of times a year instead of syncing it
per commit.

**Out of scope:** per-function detail, anything the directory listing or
`--help` already says, and the history of designs considered and dropped
(that belongs in the decision records, see below; same litmus as
docstrings — if a paragraph only makes sense to someone who saw the
discussion, cut it).

**Writing one for an existing codebase:** derive it from the structure that
is actually there — read the tree and the dependency edges first. Where the
real structure contradicts an invariant that ought to hold, document what is
true and flag the contradiction to me rather than describing the intended
design as if it were in place.

## Decision records (`docs/decision_logs/`)

Record a decision when a later reader needs its reason and can't get it from
the code. There are two logs:

- **`docs/decision_logs/architecture/`, the Architecture Decision Log:**
  decisions that matter for the architecture, in Michael Nygard's sense
  (["Documenting Architecture Decisions"](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
  2011): those that affect the structure, non-functional characteristics,
  dependencies, interfaces or construction techniques.
- **`docs/decision_logs/implementation/`:** every other decision that passes
  the test below.

**Test for a record.** All three must hold:

1. There was a real alternative: one someone could reasonably have chosen,
   not a straw man.
2. The code doesn't show why this one was chosen.
3. Not knowing would cost something: someone changing the code later would
   probably undo the decision or redo the investigation, and that would break
   something or waste the effort.

A decision that fails only the third condition (cheap to change later, or
relevant only to the lines it touches) goes in the commit message. One that
only matters for reviewing the change goes in the PR description. One that
fails the first or second condition isn't recorded.

**Who writes it, and when.** The session in which the decision is made writes
the record at that point, not at the end of the work. That can be the spec
session, implementation, or answering an implementer's question. A subagent's
report lists the decisions it made on its own, so the orchestrator can record
them. Specs and PRs link to records; they don't copy them.

**Changing who decided, or which log.** When a record with `decided-by: agent`
comes up in a discussion with me, ask whether to change it to
`decided-by: owner`. When a record in `implementation/` turns out to matter
for the architecture, ask whether to move it to `architecture/`. Don't do
either without asking.

**Replacing a decision.** Don't edit a record to say something else. Write a
new record; the old one gets `status: superseded by <filename>` and stays.

**Format.** One file per decision, named `YYYYMMDD-slug.md` after the day the
decision was made. There is no counter, so records created on parallel
branches don't collide. Frontmatter:

```yaml
status: accepted     # or: superseded by 20261201-slug.md
decided-by: owner    # or: agent
```

The body is a page at most:

- **Context:** the situation, and what made a decision necessary.
- **Decision:** what was decided, in active voice ("Forager creates and
  upgrades its database through Alembic migrations.").
- **Alternatives considered:** each alternative, with the reason it lost.
- **Consequences:** what becomes easier, harder or required. This includes
  any `**Architecture Invariant:**` the decision adds or invalidates; in that
  case ARCHITECTURE.md changes in the same change (see above).

**Existing records.** If a repository already keeps decision records in a
different place or format, extend those in their own idiom.
