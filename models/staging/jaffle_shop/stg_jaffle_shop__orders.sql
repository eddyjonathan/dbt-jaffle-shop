-- Staging model: one row per order.
select
    id as order_id,
    user_id as customer_id, -- renamed so it matches the key in stg_jaffle_shop__customers
    order_date,
    status

from raw.jaffle_shop.orders