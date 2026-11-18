-- deals: one row per limited deal
CREATE TABLE deals (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    total_stock INT NOT NULL,
    available   INT NOT NULL CHECK (available >= 0),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- orders: one row per order, each for a deal
CREATE TABLE orders (
    id              BIGSERIAL PRIMARY KEY,
    deal_id         BIGINT NOT NULL REFERENCES deals(id),
    user_id         BIGINT NOT NULL,
    status          VARCHAR(16) NOT NULL,
    idempotency_key VARCHAR(64) NOT NULL,
    expires_at      TIMESTAMPTZ NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, idempotency_key)
);

-- a user can only have one live order per deal
-- the pair of (deal_id, user_id) must be unique for
-- status PENDING or PAID. Otherwise, rejected.
CREATE UNIQUE INDEX unique_active_order_per_user
    ON orders (deal_id, user_id)
    WHERE status IN ('PENDING', 'PAID');

-- payments: one row per payment, each for an order
CREATE TABLE payments (
    id              BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES orders(id),
    provider_ref    VARCHAR(64) NOT NULL UNIQUE,
    status          VARCHAR(16) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO deals (name, total_stock, available)
VALUES ('Limited OFFER: T-SHIRT!', 100, 100);