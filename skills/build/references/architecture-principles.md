# Architecture Principles

## The central rule

The domain is the centre. It knows nothing about HTTP, databases, queues, or any framework. All external interaction flows through ports and adapters.

This is not a preference. It is the invariant the entire system is built on. A violation of this rule is not a code quality issue — it is an architectural failure.

---

## Layer structure

```
┌─────────────────────────────────────────────────────────┐
│                     INBOUND ADAPTERS                     │
│   FastAPI routers · Event consumers · CLI · Schedulers   │
├─────────────────────────────────────────────────────────┤
│                   APPLICATION LAYER                      │
│          Commands (writes) · Queries (reads)             │
├─────────────────────────────────────────────────────────┤
│                     DOMAIN LAYER                         │
│     Models · Ports · Services · Events · Exceptions      │
├─────────────────────────────────────────────────────────┤
│                    OUTBOUND ADAPTERS                     │
│   Repositories · API clients · Gateways · Publishers     │
└─────────────────────────────────────────────────────────┘
```

---

## Dependency direction — strict

```
domain/      → NOTHING (stdlib and typing only)
application/ → domain/ ONLY
adapters/    → domain/ + application/ + external libraries
config/      → everything (composition root)
```

Any file in `domain/` that imports from `adapters/` or `application/` is an architectural violation. Any file in `application/` that imports from `adapters/` is an architectural violation.

---

## Directory structure

```
src/
├── domain/
│   ├── models/          # Entities, Value Objects, Aggregates
│   ├── ports/
│   │   ├── inbound/     # Operations the outside world calls on us
│   │   └── outbound/    # Operations we call on the outside world
│   ├── services/        # Domain logic orchestrating entities and ports
│   ├── events/          # Domain event definitions (frozen dataclasses)
│   └── exceptions.py    # Domain-specific exceptions (no HTTP codes)
│
├── application/
│   ├── commands/        # Write operations (CQRS)
│   └── queries/         # Read operations (CQRS)
│
├── adapters/
│   ├── inbound/
│   │   ├── api/         # FastAPI routers and schemas
│   │   └── event_handlers/
│   └── outbound/
│       ├── persistence/ # Repositories
│       ├── clients/     # External API adapters
│       └── gateways/    # Gateway wrappers (Bridge pattern)
│
└── config/
    ├── container.py     # Dependency injection wiring
    ├── settings.py      # Environment config
    └── events.py        # Event bus wiring
```

---

## What belongs in each layer

### domain/

- Entities, value objects, aggregates
- Port interfaces (abstract base classes only — no implementations)
- Domain services that orchestrate entities and ports
- Domain events (immutable dataclasses)
- Domain exceptions that describe business failures (not HTTP failures)

Domain code may not import: `fastapi`, `sqlalchemy`, `httpx`, `requests`, `boto3`, any cloud SDK, any database driver, any messaging library.

### application/

- Command handlers: one class per write operation
- Query handlers: one class per read operation
- DTOs used by commands and queries

Application code may not import: anything from `adapters/`.

### adapters/

- FastAPI routers and Pydantic request/response schemas
- Event consumers and publishers
- Repository implementations (translate between domain models and database rows)
- External API adapters (translate between domain ports and external APIs)
- Gateway wrappers (add retry, circuit breaking, rate limiting)

### config/

- Dependency injection container (wires everything together)
- Settings (reads environment variables via Pydantic BaseSettings)
- Event bus wiring

---

## CQRS separation

Every write operation is a **Command** with a **CommandHandler**.
Every read operation is a **Query** with a **QueryHandler**.

Commands and queries are never mixed in the same handler.
A command handler must not return query results — it returns only the created or updated entity or a void acknowledgement.

---

## What these principles protect

These rules exist to ensure:

1. The domain can be unit-tested without any infrastructure
2. Any adapter (database, API, queue) can be replaced without touching domain or application code
3. The system can be reasoned about layer by layer without understanding all of it simultaneously
4. Tenant isolation can be enforced at a single layer boundary (the adapter)
