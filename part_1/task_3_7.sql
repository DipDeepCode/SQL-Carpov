SELECT
  courier_id,
  DATE_PART('year', birth_date) AS birth_year
FROM
  couriers
ORDER BY
  birth_year ASC;