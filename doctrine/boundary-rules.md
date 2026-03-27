# Boundary Rules

## What a boundary violation is

A boundary violation is any import, dependency, or coupling that crosses the architectural layer structure in the wrong direction.

Boundary violations are BLOCKER findings. They are not style issues or warnings. A build containing a boundary violation must not be approved.

---

## Hard violations — always BLOCKER

| Violation | Example | Why it breaks the architecture |
|---|---|---|
| Domain imports from adapters | `from adapters.outbound import PostgresUserRepository` in `domain/` | Domain becomes coupled to infrastructure — untestable without the database |
| Domain imports from application | `from application.commands import RegisterUser` in `domain/` | Creates a circular dependency; domain must not know about use cases |
| Application imports from adapters | `from adapters.inbound.api import UserSchema` in `application/` | Application becomes coupled to the transport layer |
| Framework types in domain | `HTTPException`, `Request`, `Response`, `AsyncSession` in `domain/` | Domain must be framework-agnostic |
| HTTP status codes in domain or application | `raise HTTPException(status_code=404)` in `domain/` or `application/` | Domain exceptions must be business concepts, not HTTP concepts |
| Direct side effects in domain or application | `await email_client.send(...)` called directly from a command handler | Side effects must be decoupled through domain events |
| Global or ambient tenant context | Reading a global `current_tenant` variable anywhere | Tenant context must be passed explicitly through every layer |

---

## Correct domain exception pattern

Domain raises a domain exception. The adapter maps it to an HTTP response.

```
# Correct
# domain/exceptions.py
class EntityNotFound(DomainError): ...

# adapters/inbound/api/user_router.py
@router.get("/{user_id}")
async def get_user(...):
    try:
        return await handler.execute(query)
    except EntityNotFound:
        raise HTTPException(status_code=404)
```

```
# Wrong
# domain/services/user_service.py
from fastapi import HTTPException
raise HTTPException(status_code=404)   # ← BLOCKER
```

---

## Correct side effect pattern

Domain publishes an event. Adapter handles the side effect.

```
# Correct
# application/commands/register_user.py
await event_bus.publish(UserRegistered(tenant_uid=..., user_id=...))

# adapters/inbound/event_handlers/welcome_email_handler.py
async def handle(self, event: UserRegistered):
    await self._email_client.send_welcome(event.email)
```

```
# Wrong
# application/commands/register_user.py
await email_client.send_welcome(user.email)   # ← BLOCKER — direct side effect
```

---

## Port interface placement rule

Port interfaces belong in `domain/ports/`. Implementations belong in `adapters/`.

If a port interface file imports from `adapters/`, it is misplaced.
If an implementation file is in `domain/`, it is misplaced.

---

## Config layer exception

`config/` may import from all layers. It is the composition root — its job is to wire everything together. Imports from `config/` into any other layer are still violations.

---

## How to detect violations

When reviewing code:

1. For every file in `domain/`: check all import statements. Any import from `adapters/`, `application/`, or any external framework is a violation.
2. For every file in `application/`: check all import statements. Any import from `adapters/` is a violation.
3. For every exception raised in `domain/` or `application/`: it must be a domain exception, not an HTTP exception.
4. For every external service call in `application/`: it must go through a port interface, not a direct call.
5. For every side effect (email, notification, webhook): it must be triggered by a domain event consumer in `adapters/`, not called directly.
