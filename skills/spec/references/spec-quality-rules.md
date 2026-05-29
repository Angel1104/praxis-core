# Spec Quality Rules

## Purpose

A spec is the contract between intent and implementation. A poor spec wastes engineering effort. These rules define what makes a spec ready to be reviewed and approved.

---

## Required sections

Every spec must contain all of the following. A section may be brief if the CR is simple — but it may not be absent.

| Section | What it must cover |
|---|---|
| Problem statement | What is broken or missing, for whom, and why it matters. Explicit out-of-scope subsection. |
| Scope | Which parts of the system are affected, what boundaries exist, which external systems are involved |
| Interfaces | Operations exposed and consumed. Authentication and authorization requirements where applicable. |
| Implementation contracts | Concrete technical details: endpoints, schemas, data structures, operation ordering for multi-step operations |
| Security considerations | Authentication, authorization, data protection, input validation — as applicable to the project |
| Acceptance criteria | GIVEN/WHEN/THEN format. Testable. Specific. No vague language. |
| Error scenarios | Expected failure modes with defined behavior. Domain-level error descriptions, not transport-specific. |
| Side effects | External effects triggered by the operation: notifications, events, integrations. How failures are handled. |
| Non-functional requirements | Performance targets, throughput, data volume, rate limits — as applicable |
| Contract Impact | CONDITIONAL. If any public contract surface is modified: document the surfaces, breaking yes/no, known dependents, and the compatibility decision. If breaking: consumer CRs must be created and listed. Mark `N/A` with one-sentence justification only when no contract surface is touched. |

---

## Acceptance criteria rules

Every acceptance criterion must be:

- **Specific** — no vague terms: "appropriate", "as needed", "handle gracefully", "relevant data"
- **Measurable** — has a clear pass/fail condition
- **Testable** — can be verified with a deterministic automated test
- **GIVEN/WHEN/THEN format** — precondition, action, and expected outcome are all explicit

Bad: "The system should handle errors gracefully."

Good: "GIVEN a payment attempt fails with a gateway timeout, WHEN the user retries, THEN the system checks idempotency and returns the original response if the first attempt was recorded."

---

## What blocks a spec from being approved

The following are BLOCKER conditions:

- Any required section is absent
- Any `BUSINESS DECISION REQUIRED` marker remains unfilled
- Any acceptance criterion that cannot be verified with a deterministic test
- Any vague language that can be interpreted more than one way
- Security considerations not addressed when the change involves authentication, authorization, or data access
- Error scenarios missing expected failure modes for the operations being changed
- Interface defined with implementation-specific details instead of abstract contracts
- A public contract surface is modified AND no `## Contract Impact` section is present
- `## Contract Impact` records a breaking change AND no consumer CRs have been created
- `## Contract Impact` contains a `BUSINESS DECISION REQUIRED` marker — compatibility decision not yet recorded

---

## Annotation conventions

Authors use these markers to signal review-time state:

| Annotation | Meaning |
|---|---|
| `(default)` | Pre-decided technical default, applied automatically — do not change without documented reason |
| `(inferred — verify)` | Derived from context; needs explicit confirmation |
| `BUSINESS DECISION REQUIRED` | Only the human can fill this in; blocks approval |

A spec with any `BUSINESS DECISION REQUIRED` marker remaining may not be approved.

---

## Proportionality

Spec depth is proportional to CR complexity:

| CR type | Expected depth |
|---|---|
| New module or domain concept | All sections fully populated |
| New endpoint on existing pattern | Problem statement, interfaces, implementation contracts, ACs, errors |
| Security or access control fix | Problem statement, security considerations, ACs, error scenarios |
| Refactor, structural improvement | Problem statement, scope, ACs |
| Incident follow-up | Problem statement, root cause, ACs, errors |

A section that is genuinely not applicable should be marked `N/A — not applicable to this CR type` with a one-sentence justification. It must not be blank.

---

## Spec quality checklist

Before declaring a spec ready for review:

- [ ] No placeholder text (no TBD, TODO, fill in later)
- [ ] No ambiguous language
- [ ] All interfaces defined abstractly, not tied to specific implementations
- [ ] Every AC follows GIVEN/WHEN/THEN
- [ ] Every error scenario has an explicit behavior defined
- [ ] Side effects are decoupled from core logic
- [ ] Security considerations addressed where applicable
- [ ] Authentication and authorization failure scenarios defined where applicable
- [ ] Access control defined for data-returning operations where applicable
- [ ] Operation ordering defined for every multi-step operation
- [ ] Contract Impact section present (populated or explicitly N/A with justification)
- [ ] If breaking change: consumer CRs created and listed with CR-IDs
