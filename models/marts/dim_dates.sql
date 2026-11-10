{{ config(
    materialized='table',
    distributed_replicated=true
) }}

{% set orders_relation = ref('fct_orders') %}

{% set start_date =
    "(select min(order_date) from " ~ orders_relation ~ ")"
%}

{% set end_date =
    "(select max(order_date) + interval '1 day' from "
    ~ orders_relation ~ ")"
%}

with calendar as (

    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date=start_date,
            end_date=end_date
        )
    }}

)

select
    date_day::date as date_day,
    extract(year from date_day)::int as year,
    extract(quarter from date_day)::int as quarter,
    extract(month from date_day)::int as month,
    extract(day from date_day)::int as day_of_month,
    extract(isodow from date_day)::int as day_of_week,
    case
        when extract(isodow from date_day) in (6, 7)
        then true
        else false
    end as is_weekend

from calendar
