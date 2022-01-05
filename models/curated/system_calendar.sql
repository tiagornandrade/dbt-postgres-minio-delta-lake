{{
  config(
    materialized = 'incremental',
    schema = 'curated',
    uniqueKey = ['last_updated','end_month','end_day','start_month','start_day'],
    merge_update_columns = ['last_updated', 'station_id'],
    timestamp_field = 'last_updated',
    partition_by = {
      'field': 'last_updated',
      'data_type': 'timestamp',
      'granularity': 'day'
    }
  )
}}

WITH base AS (
  SELECT
    {{ fieldsSystemCalendar() }}
  FROM
    {{ source('raw','system_calendar') }},
  UNNEST(data.calendars) AS calendars
)

SELECT * FROM base
{% if is_incremental() %}
WHERE DATE(last_updated) > (SELECT max(DATE(last_updated)) FROM {{ this }})
{% endif %}