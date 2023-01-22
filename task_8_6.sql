WITH subquery1 AS (
  SELECT
    birth_date AS users_birth_date,
    COUNT(user_id) AS users_count
  FROM
    users
  WHERE
    birth_date IS NOT NULL
  GROUP BY
    birth_date
),
subquery2 AS (
  SELECT
    birth_date AS couriers_birth_date,
    COUNT(courier_id) AS couriers_count
  FROM
    couriers
  WHERE
    birth_date IS NOT NULL
  GROUP BY
    birth_date
)
SELECT
  *
FROM
  subquery1 FULL
  JOIN subquery2 ON subquery1.users_birth_date = subquery2.couriers_birth_date
ORDER BY
  subquery1.users_birth_date,
  subquery2.couriers_birth_date;