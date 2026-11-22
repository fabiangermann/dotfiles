# Guidelines

Forward-feeding guides for the agentic coding harness: standing rules for
software-engineering work only. General Claude Code behavior that isn't
coding-specific (communication style, effort proportionality, etc.) belongs
in the top-level `CLAUDE.md` instead; codebase facts and one-off project
decisions belong in that project's own `CLAUDE.md`, not here.

@planning.md
@fastapi.md

## Output Minimization

Less written → less to review, maintain, and document. Applies at multiple
levels — how you implement something you've decided to build, and how much
you decide to build in the first place:

### Dependency Policy

Custom code carries a maintenance burden on two fronts: a higher assessment
cost upfront, since unfamiliar code has no track record to lean on, and the
entire ongoing burden afterward — bug fixes, security patches, keeping pace
with the ecosystem — which a well-maintained package's maintainers absorb
instead. The preference order below — standard library > well-maintained
third-party package > custom implementation — reflects that: only custom
code leaves both costs on you.

1. **Stdlib first.** If stdlib covers the need with a little glue code, use
   it — a dependency that delivers no benefit over that isn't worth adding.
2. **Package over custom, once stdlib falls short.** If closing the gap
   yourself would take more than a little glue code, default to a
   well-maintained, focused package over writing it from scratch. Package
   size alone is not a reason to prefer custom here.
3. **Exceptions — write it yourself instead when:**
   - stdlib already covers it (→ rule 1)
   - the package looks unmaintained, or has unresolved security issues /
     unresponsive maintainers on critical bugs
   - its API is unstable enough to likely force a migration
   - using it safely requires understanding its internals as deeply as
     writing it yourself would
   - it pulls in a framework/ecosystem the project doesn't otherwise use
   - its dependency footprint is disproportionate to the actual need — a
     sign stdlib+glue was probably enough after all

Reusing the same libraries across projects is deliberate — familiarity
reduces review load.

#### Preferred libraries

- Python-specific:
  - `structlog`
  - `pydantic` — including, but not exclusively, for dataclass persistence
  - `typer`
  - `httpx2` — over `httpx`

### Scope Discipline

- Build only what the current, stated requirement needs. Speculative
  flexibility, unused configuration options, or handling for cases nobody
  has confirmed will occur are out of scope.
- A valid reason to add scope beyond the immediate requirement is a
  concrete, already-known need — not "might be useful later."

## Code Review

When summarizing a code review, separate findings that need my decision from findings that are minor polish — but always list them all by category. Never roll ten polish items into "and some other minor findings". I might want the full list even if none block merge.

When reviewing code, check the diff against these guides rule by rule and list
each violation. Code that a plan or brief supplied gets the same check:
matching the plan does not make it compliant.

## Code Style

### Naming

A name states what kind of value it holds, so a reader never has to guess
whether `rows` is a list or a number.

- **Booleans:** `is_` or `has_` prefix on fields and properties that hold or
return a boolean (`is_active`, `has_children`). Where neither prefix reads
sensibly, start the name with a verb instead (`skip_validation`).
- **Counts:** `_count` suffix on the singular noun (`row_count`,
`crawler_count`). A bare plural (`rows`) holds the collection itself.
- **Datetimes:** `_at` suffix (`created_at`, `last_seen_at`). For the end of a state that lasts until then, `_until` may be used (`snoozed_until`, `valid_until`).
- **Dates:** `_on` suffix (`published_on`, `closed_on`).
- **Quantities with a unit:** unit suffix (`duration_s`, `window_days`,
`size_bytes`).
- **Applies everywhere:** variables, fields, and log keys alike.

A name also states which value it holds among its neighbours. A name that is
accurate in isolation can still be ambiguous in its scope.

- **Qualify against neighbours:** when values in scope share a noun, the name
carries the qualifier that tells them apart: this run vs. in total
(`imported_row_count` vs. `row_count`), before vs. after a transformation
(`raw_body`, `parsed_body`), measured vs. derived (`weighted_tokens`).
- **Don't reuse a domain value as a name:** a variable named after a status
or enum value (`pending`, `analysed`) reads as "the things with that
status", whatever it actually holds.
- **Test:** a reviewer who sees only the diff hunk, not the whole function,
can tell what the value holds. If they would have to scroll up, rename it.

#### Entity classes and their representations

Name an entity's classes the way the stack's own documentation does (for
FastAPI, see `fastapi.md`). Where the stack sets no convention, the class
that persists the entity carries its plain name (`Collection`), and every
other class for the same entity carries a suffix naming its role
(`CollectionCreate`, `CollectionPublic`).

- **Name what it is, not how it arrived:** a class or field is named after
the data it holds, not after the caller or the act that delivered it
(`ItemReport`, `ScrapedItem`); data delivered another way later would
otherwise need a second name for the same thing.

### Module-private names (Python)

Prefix functions and constants that are only used inside their module with
an underscore (`_get_condition`), so a reader sees the module's public API at
a glance. Tests importing a name don't make it public. Classes keep their
names.

### Keyword-only parameters (Python)

Make parameters keyword-only (after `*`), optional ones always. A call then
names what each value means (`limit=50`, not a bare `50`), and parameters can
be added or reordered without breaking callers. Leave a parameter positional
only where its meaning is obvious from the call without a name (the first one
or two, such as `session` or the object a function acts on), or where a
caller's protocol requires it (callbacks, `key=` functions, dunder methods).

### Enums for fixed sets of values

A value that can only be one of a fixed set of states or options is an enum,
not a string or a `Literal`. A typo in a string comparison is silently false;
a typo in an enum member fails as soon as the line runs.

Use a `Literal` only where something checks the strings: a schema validating
external data (Pydantic reading a file), or a type checker the project
actually runs. Strings that are written out as they are, such as log values,
stay strings.

### Comments

#### Docstrings

Give every new function, method, and class a short docstring stating its
purpose: what it's for, why it matters, and any non-obvious contract,
assumption, or gotcha a future reader (reviewer, maintainer, or the author
returning later) would want to know.

- **Capture the why.** When the mechanics read plainly but the reason behind
them doesn't (the requirement served, what breaks at runtime if the
contract is violated), that why is the part worth writing down. For tests
especially, state why the behavior matters rather than restating what is
asserted.
- **Keep it short.** One or two lines is enough; don't restate the signature
or parameter list.
- **When to skip.** Only where the code is trivial and its name already says
everything, judged by whether anything non-obvious remains, not by line
count. A name conveys the what, not the why, so a readable name alone
doesn't justify omitting a non-obvious intent.
- **Existing code.** Add docstrings when you're already modifying that
function; don't do sweeping retroactive passes.

#### Inline comments

Keep these rare. Don't comment self-explanatory code. Add one only where the
logic needs clarification or context that isn't obvious from the code itself,
preferring a non-obvious *why* (a tradeoff, an external constraint, a
workaround) over narrating *what* the code does. Don't remove existing
comments that meet this bar.

#### Which "why" belongs (docstrings and inline comments)

Only the why that is still operative: the contract, constraint, or failure
mode a caller or future editor must respect.

- **Keep guards against the obvious alternative.** Name the change a
maintainer would plausibly make as a cleanup (a pydantic model "for
consistency", a `list()` around a generator) and what it would break.
- **Cut history.** What an earlier version did, which drafts were tried, what
a review or conversation concluded. That belongs in the commit message or
PR; in code it misleads, because a reader assumes everything described is
load-bearing.
- **Test:** would a reader who never saw the discussion think of the
alternative on their own? If yes, it's a guard: keep it. If the sentence
only makes sense to someone who saw the discussion, cut it.
- **Tell-phrases are prompts, not verdicts.** "instead of", "rather than",
"is preferable to", "we chose", "used to", "this could lead to" mean: run
the test. "used to" and "we chose" almost always fail it; "rather than"
often passes.
- **Exception: external quirks.** When code exists to work around a
concretely named external quirk or bug (issue, version, vendor behaviour),
name it; don't recount the debate.

## Documentation

- Maintain documentation that covers the whole project, not just recently
  changed parts.
- Beyond its conventional purpose, documentation exists to facilitate
  review: a documentation change should summarize the corresponding code
  change, so a reviewer can read it at the start of a review to ease
  comprehension of the code that follows.
- Write documentation alongside the code changes it describes, not after
  the fact — the review-facilitation purpose above depends on it staying
  current.

### Wording (all documentation, docstrings and comments)

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

### User-facing documentation (README, guides)

Document what a reader must know or do: how to install or enable a feature, non-obvious output or behavior, edge cases that require action, and failure modes. Cut anything that only confirms what a reader already expects — sensible defaults, opt-in wiring a code example already shows, or internal robustness the library handles transparently and the user never touches. Same litmus as docstrings: if a line earns its place only because you know the design history, cut it. Let a code example carry the mechanics rather than restating them in prose.

### Architecture documentation (`docs/ARCHITECTURE.md`)

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
(same litmus as docstrings — if a paragraph only makes sense to someone who
saw the discussion, cut it).

**Writing one for an existing codebase:** derive it from the structure that
is actually there — read the tree and the dependency edges first. Where the
real structure contradicts an invariant that ought to hold, document what is
true and flag the contradiction to me rather than describing the intended
design as if it were in place.

## Git

### Reading history

**CRITICAL**: When discussing commits, history, or what changed — run the actual commands. Never infer facts from commit message wording alone.

- To determine when something was introduced: `git log --oneline -- <path>`
- To determine what actually changed in a range: `git diff <range> -- <path>`
- Commit messages are summaries written by humans under time pressure. They are not evidence. A message saying "add X" does not mean X didn't exist before; "setup Y" does not mean Y is new.
- Any claim of the form "X was built for this campaign", "X is new here", or "X didn't exist before" requires `git log -- <path>` showing the first commit falls within the range in question.

### Reading current state

**CRITICAL**: Working-tree and branch state is volatile. I commit, push, merge
PRs and delete branches myself, between your turns and outside this session.
An observation from earlier in the conversation is not evidence about now —
re-run the check in the turn you make the claim, and report what the command
just printed, not what you remember.

- **Uncommitted work:** `git status --short`.
- **Unpushed commits:** `git log --oneline @{u}..HEAD`.
- **Merged or not:** `git branch --merged <main>`, or `gh pr view <branch>`.
- **Fetch first** for anything involving a remote (`git fetch --prune`) — a
  merge or branch deletion done on the remote is invisible to a stale
  remote-tracking ref. It only updates those refs, so it doesn't fall under
  the rule against state-modifying git commands.

A branch that has disappeared, or a diff that has shrunk to nothing, is the
expected outcome of a merged PR. Treat it as that first, not as an anomaly to
report or recover from.

### Stacked branches for sliced work

When implementing a plan sliced into separate units (see `planning.md`),
put each slice on its own branch, based on the branch of the slice before
it. One branch per review unit. Each slice's pull request targets the branch
of the slice before it, never the default branch by assumption.

When the repository is on GitHub, manage the stack with `gh stack` (the
`github/gh-stack` extension): `gh stack link` with the branches from bottom
to top creates the stacked PRs and sets each base, instead of one
`gh pr create` per branch.

### Changing unmerged work

Until a unit is merged into the main branch, fix things where they were
introduced instead of adding corrections on top. A reviewer should see the
unit as it should have been written, not the history of getting there. Which
side of that line a unit is on is a current-state question — check it (see
above) before applying this rule, don't carry forward what was true earlier.

- **Review fixes:** apply each fix on the branch that introduced the code,
  then restack the branches built on it (`git rebase --update-refs`). If
  the restack hits conflicts that need judgment rather than mechanical
  resolution, stop and ask.
- **Migrations:** change an unmerged migration in place instead of adding
  another one. Afterwards the schema and the migrations must agree
  (Django: `makemigrations --check` reports no changes).

## Testing

### Test Scope

**Every test must be able to fail because of code in this repository.**
Do not write tests that only assert behavior owned by the standard library,
a third-party framework, or the language itself.

Litmus test: if you deleted or broke our code and the test would *still* pass,
it isn't testing us — delete it.

Examples of tests NOT to write:
- That `json.dumps(None)` produces `null`, or that a dataclass round-trips —
  that's stdlib behavior.
- That Django's ORM saves and reloads a field unchanged — that's the framework
  (Django-specific example; the same principle applies to any ORM/framework).
- Re-asserting a fact another test already covers (e.g. field presence when a
  separate test already checks the exact field set).

Test our logic instead: transformations, branching, ordering, edge cases,
and the glue between components.

When delegating implementation to a subagent with TDD, include these
instructions in the task so it doesn't pad the suite with
framework-behavior or redundant tests.

### Rejected Drafts

**Don't test your own rejected drafts**. Test behavior the spec or my request
asks for. A test whose only purpose is to pin down a variant you wrote and I
rejected is deliberation in test form: it makes a non-requirement look like a
requirement, and the next person to touch the code will preserve it. Same
litmus as docstrings — if the test only makes sense to someone who saw the
discussion, don't write it. Corollary: after I reject an approach, delete its
tests too; don't invert them into assertions that it stays gone.

### Test Data

**Don't draw behavior-test inputs from shipped data or default config.**
Reference files, seed data and bundled config are designed to change; a test
coupled to one fails on the wrong axis — "case insensitive" breaking because a
vendor renamed an entry. Build the inputs the test needs. Cover the real
artifact separately with a couple of tests asserting *properties* ("no disabled
entry survives loading"), not contents ("`Applebot-Extended` is absent").

Litmus test: if editing the data file the way its own docs tell you to breaks
the test, it tests data, not behavior.

First ask whether the check belongs at runtime instead — data-file validation
is usually cheap enough to run on every load, where it also covers the files
users supply themselves, which no test can reach.

## Code Organization

- Physically separate code by blast radius — this contains the effect of a
  change to the part of the system it actually touches.
- Core:
  - Schema/types — models, dataclasses, etc., including config and state
  - Core logic — the actual project value
  - Public API / MCP surface
  - Authentication
  - Interface contract
- Supporting:
  - Interface implementation details
  - Persistence — the code that stores/loads, not the schema/config/state
    itself

## Preferred Patterns

### Interface

- Prefer a CLI over a graphical interface in almost every case. Even when a
  GUI is the end goal, starting with a CLI gets something running and
  testable faster.
- Build CLI tools to be installed with `uv tool install .` and run from any
  directory, not from inside the repository:
  - Resolve path arguments against the current directory; never depend on
    paths relative to the repository checkout or the package source.
  - Keep configuration, state and logs in the home-directory locations under
    Configuration below, never in the checkout (no `.env` in the repo).
  - The README's installation section uses `uv tool install .` (with
    `--reinstall` to pick up changes); `uv sync` and `uv run` belong in its
    development section.

### Configuration

- For tools and apps that run outside their repository (distributed ones,
  and personal CLI tools installed with `uv tool install`), prefer
  configuration via files in the user's home directory over other
  mechanisms — this keeps setup inspectable and editable without relying on
  environment state that isn't visible in the filesystem:
  - `~/.config/<app>/config` — main configuration file
  - `~/.config/<app>/.env` — if the app uses environment variables; a file
    is often easier to manage than real environment variables, e.g. during
    development
  - `~/.local/share/<app>` — state files and logs

### Logging

- Log extensively — observability depends on it.
- Use canonical log lines where possible.

### Errors

- Raise user-facing errors as a project exception that carries an error code
  (an enum member), not as a bare message. Tests assert on the code, so
  rewording or reformatting a message never breaks them.
- Where the framework has an exception type it already turns into an exit
  code or response, subclass that rather than catching and converting at the
  entry point.

---

## Extending this file

Add a new `##` section per topic as standing rules emerge. Before adding an
entry, check it's:

- **Coding-specific** — matters only when Claude Code is doing
  software-engineering work (writing, reviewing, or testing code). If it
  holds for any agentic task regardless of domain (e.g. Basecamp work,
  research, browser automation), it belongs in the top-level CLAUDE.md
  instead, not here — even if it's otherwise general.
- **General across projects** — a fact or preference true regardless of
  codebase. If it's specific to one project, it belongs in that project's
  own CLAUDE.md instead.
- **This file vs. `planning.md`** — this file holds rules useful regardless
  of stage. Content only useful to whichever agent is producing a plan
  (unit sizing, slicing strategy) goes in `planning.md` instead.
- **This file vs. a stack guide** — this file holds rules that apply
  whatever the stack. A rule that only applies to one framework or stack,
  across all projects using it, goes in that stack's own file
  (`fastapi.md`), included with `@` at the top of this file.
- **A standing rule, not a procedure** — a single checkable instruction, not
  a multi-step process. A multi-step procedure belongs in a Skill
  (`~/.claude/skills/`) instead, so it only loads when the task type matches.
- **Resolved, not open** — something you've actually decided, not a
  question you're still weighing. Keep undecided ideas in a separate notes
  file until they're settled.
