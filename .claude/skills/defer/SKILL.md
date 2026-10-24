---
name: defer
description: Use when the user asks to add, note, park or write down an item on the session backlog (SESSION_BACKLOG.md) to handle later, or reports a backlog item as done.
---

# Add to session backlog

The session backlog, `SESSION_BACKLOG.md` in the repository root, is a
short-lived list of items the user has deliberately deferred. Recording the
item is the whole task. Handling it happens later, when the user picks it up.
A question inside an item is part of the item: it is recorded, not answered.

## Steps

1. If `SESSION_BACKLOG.md` does not exist, create it with this content:

   ```markdown
   # Session backlog

   Short-lived and not committed. Delete this file once every item is resolved.
   ```

   Leave it out of `.gitignore` and `.git/info/exclude`: the file showing up
   in `git status` is the reminder that items are still open.

2. Check that the item can be located without this conversation. Imagine a
   reader in a new session with only the repository. If the item refers to
   code that reader could not find, ask the user which code is meant and add
   the item only after they answer. Typical cases are "that function", "the
   test above", or a description that matches several places.

3. Append the item as the next numbered entry, after the last open item and
   before the `## Resolved` section if one exists, in this shape:

   ```markdown
   N. <the user's text, unchanged except for references resolved in step 2>
      - *Session context (added by agent):* <facts from this session that
        would otherwise be lost>
   ```

   Session context holds only facts: decisions made in this session, related
   findings, pointers to files, functions, tests or `BACKLOG.md` entries.
   Leave the sub-item out when this session adds nothing beyond the user's
   text.

4. Reply with one line: `Added as item N.`

## Resolving an item

When the user reports an item as done, do not delete it: move it to a
`## Resolved` section at the end of the file, reduced to its number and a
one-line title.

```markdown
## Resolved

3. Rename `parse_row` to `_parse_row`.
```

Keep the original number — open items may refer to it — and never renumber
the open list, so gaps in the numbering are expected. Drop the session
context and the body; keep only what makes a reference from an open item
readable. Create the section when the first item resolves.
