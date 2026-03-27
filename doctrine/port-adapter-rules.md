# Port and Adapter Rules

## Three mandatory patterns

All inter-layer communication follows one of three patterns depending on the direction and nature of the interaction.

---

## Pattern 1: Port → Adapter (standard)

Every dependency that crosses a layer boundary must go through a port (abstract interface in `domain/ports/`) and be satisfied by an adapter implementation.

The domain defines what it needs. The adapter provides it. The domain never knows which adapter is active.

```python
# domain/ports/outbound/user_repository.py
from abc import ABC, abstractmethod

class UserRepository(ABC):
    @abstractmethod
    async def get_by_id(self, tenant_uid: str, user_id: str) -> Optional[User]: ...

    @abstractmethod
    async def save(self, tenant_uid: str, user: User) -> User: ...
```

```python
# adapters/outbound/persistence/user_repository_impl.py
class PostgresUserRepository(UserRepository):
    async def get_by_id(self, tenant_uid: str, user_id: str) -> Optional[User]:
        row = await self._db.execute(
            select(UserRow)
            .where(UserRow.tenant_uid == tenant_uid)
            .where(UserRow.id == user_id)
        )
        ...
```

---

## Pattern 2: Bridge — Port → Adapter → Gateway

Use the Bridge pattern for all external API integrations. The Adapter handles pure API translation. The Gateway wraps the Adapter with cross-cutting concerns: rate limiting, circuit breaking, retries, timeouts.

This keeps Adapter code clean (one responsibility: translate) and keeps the Gateway concerns out of domain logic.

```python
# domain/ports/outbound/payment_client.py
class PaymentClient(ABC):
    @abstractmethod
    async def charge(self, tenant_uid: str, amount: Decimal) -> PaymentResult: ...
```

```python
# adapters/outbound/clients/stripe_adapter.py
class StripeAdapter(PaymentClient):
    """Pure translation — no retry or rate-limit logic here."""
    async def charge(self, tenant_uid: str, amount: Decimal) -> PaymentResult:
        result = await stripe.PaymentIntent.create(...)
        return PaymentResult(id=result.id, status=result.status)
```

```python
# adapters/outbound/gateways/payment_gateway.py
class PaymentGateway(PaymentClient):
    """Cross-cutting concerns only — delegates to the adapter."""
    def __init__(self, adapter: StripeAdapter, rate_limiter, circuit_breaker):
        ...

    async def charge(self, tenant_uid: str, amount: Decimal) -> PaymentResult:
        await self._rate_limiter.acquire(tenant_uid)
        async with self._circuit_breaker:
            return await self._adapter.charge(tenant_uid, amount)
```

In the DI container: bind `PaymentClient` → `PaymentGateway(StripeAdapter(...))`.

**Bridge is required** whenever the external service has: rate limits, retry semantics, circuit breaking needs, or timeout requirements. A direct Adapter-without-Gateway is acceptable only for internal services with no such concerns.

---

## Pattern 3: NEL — No direct side Effects from Logic

Side effects (email, notifications, webhooks, audit logs) must never be called directly from domain or application layers. They are triggered by domain events consumed by adapters.

```python
# domain/events/user_events.py
@dataclass(frozen=True)
class UserRegistered:
    tenant_uid: str
    user_id: str
    email: str
    registered_at: datetime
```

```python
# application/commands/register_user.py
class RegisterUserHandler:
    async def execute(self, command: RegisterUser) -> User:
        user = User.create(...)
        await self._repo.save(command.tenant_uid, user)
        await self._event_bus.publish(UserRegistered(
            tenant_uid=command.tenant_uid,
            user_id=user.id,
            email=user.email,
            registered_at=user.created_at,
        ))
        return user
        # No email call here. No notification here.
```

```python
# adapters/inbound/event_handlers/welcome_email_handler.py
class WelcomeEmailHandler:
    async def handle(self, event: UserRegistered):
        await self._email_client.send_welcome(event.email, event.user_id)
```

**NEL is required** whenever a use case has a side effect. The side effect handler lives in `adapters/inbound/event_handlers/` and implements an inbound port.

---

## DAL — Data Access Layer rules

Repositories implement outbound ports. They translate between domain models and database rows, and they always scope every query by `tenant_uid`.

```python
# Correct
async def get_by_id(self, tenant_uid: str, user_id: str) -> Optional[User]:
    row = await self._db.execute(
        select(UserRow)
        .where(UserRow.tenant_uid == tenant_uid)   # always first
        .where(UserRow.id == user_id)
    )
```

```python
# Wrong — missing tenant scope
async def get_by_id(self, user_id: str) -> Optional[User]:
    row = await self._db.execute(select(UserRow).where(UserRow.id == user_id))
```

Every repository method signature must take `tenant_uid: str` as its first parameter after `self`. A repository method without `tenant_uid` is a BLOCKER finding.

---

## Port naming rules

- Inbound ports (what the outside world calls on us): `<UseCase>Port` — e.g., `RegisterUserPort`
- Outbound ports (what we call on the outside world): descriptive noun — e.g., `UserRepository`, `PaymentClient`, `NotificationService`
- Port files: `<port_name_snake_case>.py` in the appropriate `ports/inbound/` or `ports/outbound/` directory

---

## When the Bridge pattern is not needed

A plain Port → Adapter is sufficient when:

- The external call is internal (e.g., to another microservice in the same trust boundary)
- No rate limiting, retry, or circuit breaking is required
- The integration is simple and stable

When in doubt, use Bridge. Adding a Gateway later requires no domain changes — it is a pure adapter-layer refactor.
