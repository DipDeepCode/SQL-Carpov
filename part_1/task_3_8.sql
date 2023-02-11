SELECT
  courier_id,
  COALESCE(
    CAST(DATE_PART('year', birth_date) AS VARCHAR),
    'unknown'
  ) AS birth_year
FROM
  couriers
ORDER BY
  birth_year DESC;