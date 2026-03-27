# Orchestration vs Domain

## The core distinction

**Domain logic** expresses business rules. It is what the system *knows* about the problem.

**Orchestration logic** coordinates the execution of domain logic and adapters to carry out a use case. It is what the system *does* in response to a request.

These are fundamentally different. Mixing them produces code that is hard to test, hard to change, and fragile under extension.

---

## Where each type of logic lives

| Logic type | Location | Example |
|---|---|---|
| Business rules and invariants | `domain/models/` or `domain/services/` | "An order can only be cancelled if it is in PENDING state" |
| Domain event definitions | `domain/events/` | `OrderCancelled` dataclass |
| Domain exceptions | `domain/exceptions.py` | `OrderAlreadyShipped` |
| Use case orchestration | `application/commands/` or `application/queries/` | Load the order, call cancel(), publish event, save |
| Infrastructure coordination | `adapters/` | Write to DB, call external API, publish to queue |
| Side effect handling | `adapters/inbound/event_handlers/` | Send cancellation email on `OrderCancelled` |

---

## Application layer: orchestrator, not business logic owner

Command and query handlers orchestrate. They do not contain business rules.

```python
# Correct — orchestration in application, rules in domain
class CancelOrderHandler:
    async def execute(self, command: CancelOrder) -> Order:
        order = await self._repo.get_by_id(command.tenant_uid, command.order_id)
        order.cancel(reason=command.reason)     # ← business rule lives in Order.cancel()
        await self._repo.save(command.tenant_uid, order)
        await self._event_bus.publish(OrderCancelled(...))
        return order
```

```python
# Wrong — business rule leaking into application layer
class CancelOrderHandler:
    async def execute(self, command: CancelOrder) -> Order:
        order = await self._repo.get_by_id(command.tenant_uid, command.order_id)
        if order.status != OrderStatus.PENDING:    # ← business rule, belongs in Order
            raise ValueError("Cannot cancel a non-pending order")
        order.status = OrderStatus.CANCELLED
        ...
```

---

## Domain services: when to use them

A domain service is appropriate when:

- The business rule involves multiple entities and does not naturally belong to any one of them
- The operation requires collaborating ports (defined in `domain/ports/`) but no infrastructure

A domain service must not:

- Call adapters directly
- Import from `application/` or `adapters/`
- Produce side effects — it may publish domain events through an `EventBus` port

---

## Event-driven side effects

Side effects are never triggered directly from domain or application code. They are triggered by consuming domain events in adapter-layer event handlers.

This keeps the core use case fast, testable, and independent of infrastructure concerns. It also makes side effects easy to add or remove without touching domain logic.

The `EventBus` in application handlers is an outbound port defined in `domain/ports/outbound/`. The implementation lives in `adapters/`.

---

## How to identify misplaced logic during review

**Business rule in the wrong place:**
- An `if` statement in a command handler that checks an entity's state → move to the entity
- Validation logic in an adapter schema that checks a business constraint → move to the domain model
- A query handler that computes a domain-meaningful result → move the computation to a domain service or model

**Orchestration in the wrong place:**
- A domain service that calls a repository directly without going through a port → violation
- A domain model that loads related entities from a database → violation
- A domain event handler that contains business rule logic → violation (handler should only react, not decide)

---

## The test signal

If a domain class cannot be unit-tested without mocking infrastructure, it contains orchestration that does not belong there.

Domain logic must be testable with plain Python objects and no infrastructure setup. If you find yourself needing a database session to test a business rule, the rule is in the wrong place.
