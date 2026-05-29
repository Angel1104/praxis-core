# Testing Quality Rules

## Purpose

Tests are the enforcement mechanism for acceptance criteria. These rules define what makes a test suite adequate — not just present.

---

## Test structure

Tests should be organized by level, following the project's conventions:

| Level | What it validates | Infrastructure needed |
|-------|------------------|----------------------|
| **Unit** | Core logic, business rules, data validation, state machines | None — no IO, no external services |
| **Integration** | Component interaction, data access, external service adapters | Real or containerized dependencies |
| **End-to-end / API** | Full request-response cycles, user-facing behavior | Full running system or test server |

The specific directory layout and test runner are determined by the project's stack and conventions.

**Before creating new test files, scan the existing test structure.** If tests for the affected component already exist, add new test cases to those files. Create new test files only for genuinely new components with no existing coverage. See `proportionality-rules.md` for the full test placement rules.

---

## Coverage requirements

### Mandatory for every CR that touches acceptance criteria

- One test skeleton per acceptance criterion
- One happy-path test per operation
- One error-path test per error scenario in the spec

### Mandatory for every CR that touches data access (where applicable)

- Data isolation tests where the project enforces access boundaries (e.g., multi-tenant, role-based, organization-scoped)
- A test that verifies one actor cannot access another actor's data through the code path under test

### Mandatory for every CR that adds or modifies authentication or authorization

- Unauthenticated request is rejected
- Insufficient permissions are rejected
- Unauthorized access does not reveal whether the resource exists

---

## Test naming convention

Test names should follow the pattern: `<action>_<condition>_<expected_result>`

Every test must document which acceptance criterion or error scenario it covers.

---

## Fixture and setup rules

- Prefer fake implementations (in-memory, stub) over mocking internal components
- Core logic objects should be constructed directly, not mocked
- Shared test setup should be centralized and reusable across test files
- Test state must be isolated — no shared mutable state between tests

---

## Test skeleton design rules

Test skeletons are designed to fail until the implementation exists. A skeleton that passes before implementation is not a valid skeleton.

Every skeleton must have:
- A name that maps to an acceptance criterion or error scenario
- GIVEN / WHEN / THEN structure in the test body (as comments or sections)
- A mechanism to force failure (e.g., `raise NotImplementedError`, `fail()`, `assert false`) that is removed when the test is implemented during Build

---

## Data isolation test pattern

Where the project enforces access boundaries (multi-tenant, organization-scoped, role-based), isolation tests must verify:

1. **Direct access** — Actor B cannot read, update, or delete Actor A's resource. The system returns "not found", not "forbidden" (do not reveal existence).
2. **List/enumeration** — Actor A listing resources returns only their own data, never another actor's.

---

## What makes a test inadequate (finding triggers)

| Condition | Severity |
|---|---|
| Acceptance criterion with no corresponding test | HIGH |
| Data access path with no isolation test (where project enforces access boundaries) | HIGH |
| Test that passes before implementation exists | HIGH |
| Error scenario from the spec with no corresponding test | MEDIUM |
| Test that does not follow GIVEN/WHEN/THEN structure | LOW |
| Missing auth failure test for an authenticated endpoint | MEDIUM |
| Test with shared mutable state between test cases | MEDIUM |

---

## Adversarial checklist

For every feature, verify these edge cases are considered where applicable:

- [ ] Rate limiting triggers and rejects excess requests
- [ ] Concurrent writes don't corrupt state (optimistic locking if applicable)
- [ ] Idempotent operations with duplicate input return original response, no duplicate side effects
- [ ] Invalid identifiers in input are rejected with a clear error
- [ ] Expired or invalid credentials are rejected
- [ ] Restricted operations cannot be performed by unauthorized actors
- [ ] Restricted data is not visible to unauthorized actors
- [ ] Empty collections return an empty list, not an error or null
