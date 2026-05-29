# Security Compliance Posture

Implementation-level security obligations derived from standard compliance frameworks. These are code-level demands enforced during security review — not process requirements. Apply whichever standards are relevant to the project as declared in the project's `CLAUDE.md` or compliance documentation.

---

## ISO 27001 A.8.28 — Secure Coding

What it demands at the code level:

- All external inputs validated at the system boundary before use in any internal operation
- No raw query construction — parameterised queries or ORM throughout; no string interpolation into queries
- No credentials, tokens, or API keys in source code, configuration files, or committed `.env` files
- Authentication checked before every protected operation
- Authorization checked at the operation level, not only at the API entry point — a user authenticated for one role must not reach operations reserved for another
- No custom cryptographic implementations; vetted library only

---

## ISO 27001 A.8.29 — Security Testing

What it demands at the code level:

- At least one negative-path test per security-relevant behaviour
- Tests cover: unauthorized access (unauthenticated and wrong-role), invalid or boundary input, access boundary violations
- The security review produces test skeletons as a mandatory output — this is the A.8.29 evidence artefact attached to the CR

---

## IEC 62443-4-1 SI — Secure Implementation

What it demands at the code level:

- Inputs from field devices, OT interfaces, or any external system are treated as untrusted regardless of the source
- Error paths fail safely (fail-closed): failed authentication produces a deny response, not a fallback to unauthenticated access or a degraded mode that bypasses checks
- Privileged and state-changing operations produce an audit log entry (see Audit Logging section below)
- Authentication is not assumed from context or session state — it is verified explicitly on each protected call

---

## IEC 62443-4-1 SVV — Security Verification & Validation (ML2)

What it demands at the code level:

- Security tests are documented and consistently executed — not ad-hoc
- Tests cover both positive paths (authorized access succeeds) and negative paths (unauthorized access fails)
- Injection tests present for all inputs that reach a persistence or command layer
- Boundary condition tests for all constrained inputs (length limits, value ranges, character sets)
- Test output is retained as evidence (CI artefact or CR attachment)

---

## GDPR — Personal Data at Implementation Level

What it demands at the code level:

**Log sanitation** — Application logs must not contain:
- Direct identifiers: names, email addresses, phone numbers, user or account IDs that map to a natural person
- Contextual identifiers: combinations of timestamp + location + event that could identify an individual in context (e.g., footage timestamp + camera ID + event type)
- Sanitization is applied in the code path before log writes — not as post-processing or log-sink filtering

**Access control on personal data** — Endpoints or operations that return personal data:
- Must be access-controlled and role-restricted
- Unauthenticated requests return 401; wrong-role requests return 403
- No personal data returned in error responses

**Encryption** — Personal data encrypted in transit (TLS 1.2+ minimum) and at rest; no plaintext personal data written to storage

**Retention** — System supports configurable retention limits; no indefinite storage of personal data

**Right to erasure** — System supports deletion of personal data records on request where technically feasible

---

## Audit Logging

Required for privileged and state-changing operations:

- Every privileged operation (permission changes, deletions, administrative actions) produces a structured log entry
- Log entry must include: operation name, timestamp, actor identity (system or user reference), outcome (success / failure)
- Log entries must not contain personal data (see GDPR log sanitation above)
- Structured format (e.g., JSON) — not free-text strings

---

## NIS2 / CRA — Precautionary Baseline

Apply when the project operates in a regulated sector or delivers software with digital elements. Until applicability is confirmed, treat the following as a required baseline:

- No unauthenticated write access on any interface
- Encryption in transit on all external interfaces
- No known CRITICAL vulnerability shipped — dependency scanning in CI
- Security findings tracked with mandatory severity field, assigned, and time-boxed to resolution
- Evidence of security measures producible on request (CI artefacts, review output)

---

## Compliance-Keyed Test Templates

When the security review generates tests, select templates based on what the CR touches. Each template produces one test skeleton in the review output.

| If CR touches | Test name | What it verifies | Pass criterion |
|---|---|---|---|
| Data access / queries | `test_cross_boundary_isolation` | Request from entity A cannot access entity B's data | Returns 404 or equivalent; no entity B data present in response |
| Logging / observability | `test_log_sanitation` | No identifiers in log output for the operation | Log entries contain no fields matching the project's PII pattern list |
| Personal data endpoints | `test_personal_data_access_control` | Unauthenticated and wrong-role requests blocked | 401 for unauthenticated; 403 for wrong role; no personal data in error body |
| Secrets loading | `test_no_plaintext_secrets` | Config loaded from secret manager, not from env or file | No credentials in environment variables, config files, or process arguments |
| Privileged / state-changing operations | `test_audit_log_presence` | Operation produces a structured log entry | Log entry exists with required fields: operation, timestamp, actor, outcome |
| External connections | `test_transport_security` | Plaintext connections rejected; invalid certificates rejected | TLS-only; certificate validation enforced; no fallback to plaintext |
| State-changing operations with auth | `test_fail_closed_on_auth_failure` | Failed authentication produces deny, not degraded access | Auth failure returns deny response; no partial state change occurs |
| OT / field device inputs | `test_untrusted_input_handling` | Malformed or adversarial input from field interface rejected safely | Input rejected at boundary; no crash; no data corruption; no privilege escalation |
