WITH subquery1 AS (
  SELECT
    user_id
  FROM
    users
  LIMIT
    100
), subquery2 AS (
  SELECT
    name
  FROM
    products
)
SELECT
  *
FROM
  subquery1
  CROSS JOIN subquery2
ORDER BY
  user_id,
  name