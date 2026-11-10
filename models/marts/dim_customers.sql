-- Mart model: one row per customer, enriched with order stats.
-- ref() points to another dbt model (not a raw table). dbt uses it to:
--   1. resolve the real name (raw.dbt_eddy.stg_...)
--   2. know the build order (staging first, then this model)

with customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }}
),

orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

payments as (
    select * from {{ ref('fct_orders') }}
),

-- aggregate orders to customer level: one row per customer
customer_orders as (
   select
        orders.customer_id,
        min(orders.order_date)   as first_order_date,
        max(orders.order_date)   as most_recent_order_date,
        count(orders.order_id)   as number_of_orders,
        sum(payments.amount)     as lifetime_value
    from orders
    left join payments
        on orders.order_id = payments.order_id   -- 1 order ↔ 1 fct_orders row: no fan-out
    group by orders.customer_id                     -- 1 = first column in the select (customer_id)
),

final as (
    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        coalesce(customer_orders.lifetime_value, 0)   as lifetime_value   -- last column: no comma
    from customers
    left join customer_orders using (customer_id)
)

select * from final