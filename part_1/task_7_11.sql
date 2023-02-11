WITH subquery AS (
  SELECT
    ROUND(AVG(price), 2)
  FROM
    products
)
SELECT
  product_id,
  name,
  price,
  CASE
    WHEN price - (
      SELECT
        *
      FROM
        subquery
    ) >= 50 THEN ROUND(price * 0.85, 2)
    WHEN (
      SELECT
        *
      FROM
        subquery
    ) - price >= 50 THEN ROUND(price * 0.9, 2)
    ELSE price
  END AS new_price
FROM
  products
ORDER BY
  price DESC,
  product_id