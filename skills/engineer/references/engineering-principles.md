# Engineering Principles

Universal quality principles that apply regardless of technology stack, architecture pattern, or project type. These are the guardrails that every skill applies during plan, build, and review.

---

## Separation of concerns

Core logic must be separate from infrastructure. Business rules should not depend on frameworks, databases, transport layers, or external services. This separation makes code testable, replaceable, and understandable in isolation.

- Core logic depends on nothing external — only language primitives and abstractions
- Infrastructure code (databases, APIs, queues, file systems) lives at the boundary
- Swapping an infrastructure component must not require changes to core logic

---

## Dependencies point inward

Code should be organized so that dependencies flow from outer layers (infrastructure, UI, transport) toward inner layers (core logic, domain rules). Inner layers define abstract interfaces. Outer layers implement them.

- Inner code defines what it needs (interfaces, contracts)
- Outer code provides it (implementations, adapters)
- Inner code never imports from outer code

---

## Decouple side effects

Operations that produce side effects (sending email, publishing events, calling external services) should be decoupled from the core operation that triggers them. This keeps core logic fast, testable, and independent of infrastructure reliability.

- Core operations complete their primary task without waiting for side effects
- Side effects are triggered through events, callbacks, or message passing
- Failure of a side effect does not fail the core operation (unless business rules require it)

---

## Explicit over implicit

Dependencies, context, and configuration are passed explicitly — not discovered through global state, ambient context, or magic. This makes code predictable and testable.

- No hidden dependencies
- No global mutable state
- No ambient context that changes behavior silently

---

## Errors are part of the design

Error handling is intentional, not an afterthought. The system defines its failure modes, gives them meaningful names, and handles them at the appropriate layer.

- Core logic raises errors that describe business failures, not infrastructure failures
- Infrastructure errors are translated at the boundary into terms the core understands
- Transport-specific error representations (HTTP status codes, gRPC codes) live at the boundary, not in core logic

---

## Test at the right level

Each test level has a purpose. Testing at the wrong level produces slow, brittle, or meaningless tests.

| Level | Purpose | What it covers |
|-------|---------|---------------|
| **Unit** | Validate core logic in isolation | Business rules, data validation, state machines — no IO |
| **Integration** | Validate component interaction | Data access, external service adapters — real or containerized dependencies |
| **End-to-end** | Validate user-facing behavior | Full request-response cycles, critical paths |

- Unit tests are fast and cover business rules exhaustively
- Integration tests verify that components work together correctly
- End-to-end tests cover critical paths, not every permutation
- A test that requires infrastructure to verify a business rule is testing at the wrong level

---

## Data access boundaries

Every data access operation should respect the access boundaries defined by the project (e.g., multi-tenant isolation, role-based access, organization scoping). These boundaries are enforced at the data access layer, not scattered across the codebase.

- Access boundaries are applied consistently at the data access layer
- Unauthorized access returns "not found", not "forbidden" (do not reveal existence)
- Access boundary enforcement is verified by tests

---

## Interfaces over implementations

Code that depends on external capabilities should depend on abstract interfaces, not concrete implementations. This makes the system adaptable and testable.

- Define what you need as an interface
- Implement it separately
- Wire them together at the composition root
- Name interfaces by capability (what they do), not by implementation (how they do it)

---

## What these principles protect

These principles exist to ensure:

1. Core logic can be tested without infrastructure
2. Infrastructure components can be replaced without touching core logic
3. The system can be reasoned about layer by layer
4. Access boundaries are enforced consistently
5. Side effects are manageable and observable
6. Code is predictable — no hidden behavior
