with orders as(
    select * from {{ ref('stg_jaffle_shop__orders') }}
),
payments as (
    select * from {{ ref('stg_stripe__payments') }} 
),
order_payments as(
        select
                order_id,
                sum(amount) / 100 as amount                   -- cents -> dollars
            from payments
            where status = 'success'                          -- failed payments brought in no money
            group by order_id
),
final as (
    select 
        o.order_id,
        o.customer_id,
        coalesce(op.amount, 0)  as amount
    from  orders as o 
    left join order_payments as op using(order_id)
)

select * from final 