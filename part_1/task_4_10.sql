SELECT
  courier_id
FROM
  couriers
WHERE
  DATE_PART('year', birth_date) BETWEEN '1990' AND '1995'
ORDER BY
  courier_id;