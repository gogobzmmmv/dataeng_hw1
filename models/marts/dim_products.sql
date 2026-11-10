{{ config(
    materialized='table',
    distributed_replicated=true
) }}

select
    p.product_id,
    p.product_name,
    p.brand,
    h.category_name,
    h.parent_category_name,
    h.root_category_name

from {{ ref('stg_shop__products') }} as p

left join {{ ref('int_category_hierarchy') }} as h
    on p.category = h.category_name
