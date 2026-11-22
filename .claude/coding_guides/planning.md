# Planning

Content only relevant to whichever agent is producing a plan — constrains
what a plan has to look like, not how implementation executes it. An
implementation agent working an already-sliced unit has no use for this;
it just builds what it was handed.

- Prefer vertical slices over horizontal layers: plan a feature as a lean,
  end-to-end slice first — something testable and verifiable running
  start-to-end before adding depth. Simplifying or mocking non-critical
  parts to get there is fine.
- Iterate on the vertical slice to fill in gaps and detail, rather than
  planning complete horizontal layers (schema → services → API → UI) before
  anything is testable.
- Exception: when an individual component carries hard, irreducible
  uncertainty (e.g. performance-critical logic), plan to verify that
  component in isolation before wiring it into the vertical slice — don't
  let the fast-iteration default hide a real risk.
- Keep review units (pull requests, or whatever unit the workflow uses)
  small: 500 lines max.
- Keep review units scoped to one topic or feature — don't mix unrelated
  changes into the same unit.
