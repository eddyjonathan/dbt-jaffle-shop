-- Staging model: one row per customer, columns renamed to clear business names.
-- Staging = light cleanup only (rename, cast). No joins, no business logic.
select
    id as customer_id,      -- "id" is ambiguous once joined, so make it explicit
    first_name,
    last_name

--from raw.jaffle_shop.customers  -- catalog.schema.table in Databricks
from {{ source('jaffle_shop','customers') }}