{{ config(
    materialized='table',
    distributed_replicated=true
) }}

with confirmed_orders as (
    select
        order_id,
        customer_id,
        ordered_at,
        order_amount,
        row_number() over (
            partition by customer_id
            order by ordered_at, order_id
        ) as rn

    from {{ ref('fct_orders') }}
    where is_confirmed
),

customer_metrics as (
    select
        customer_id,
        count(*) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue,
        max(
            case when rn = 1 then order_id end
        ) as first_confirmed_order_id,
        max(
            case when rn = 1 then ordered_at end
        ) as first_confirmed_at

    from confirmed_orders
    group by customer_id
)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,

    m.first_confirmed_order_id,
    m.first_confirmed_at,

    coalesce(m.confirmed_orders_count, 0)
        as confirmed_orders_count,
    coalesce(m.confirmed_revenue, 0)
        as confirmed_revenue,
    coalesce(m.confirmed_orders_count, 0) > 0
        as is_buyer

from {{ ref('stg_shop__customers') }} as c

left join customer_metrics as m
    on c.customer_id = m.customer_id
