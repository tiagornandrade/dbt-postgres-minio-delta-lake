{{
  config(
    materialized = 'incremental',
    schema = 'analytics',
    uniqueKey = ['last_updated'],
    merge_update_columns = ['last_updated', 'station_id'],
    timestamp_field = 'last_updated',
    partition_by = {
      'field': 'last_updated',
      'data_type': 'timestamp',
      'granularity': 'day'
    }
  )
}}

SELECT
  *
FROM
  {{ source('curated','system_hours') }}
{% if is_incremental() %}
WHERE DATE(last_updated) > (SELECT max(DATE(last_updated)) FROM {{ this }})
{% endif %}