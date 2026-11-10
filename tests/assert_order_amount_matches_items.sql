with items_totals as (
    select
        order_id,
        sum(line_amount) as total_line_amount
    from {{ ref('fct_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.order_amount,
    i.total_line_amount
from {{ ref('fct_orders') }} as o
left join items_totals as i
    on o.order_id = i.order_id
where
    i.order_id is null
    or abs(o.order_amount - i.total_line_amount) > 0.01
