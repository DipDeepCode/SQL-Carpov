WITH subquery AS(
  SELECT
    product_id
  FROM
    products
  ORDER BY
    price DESC
  LIMIT
    5
), subquery2 AS(
  SELECT
    order_id,
    unnest(product_ids),
    product_ids
  FROM
    orders
)
SELECT
  DISTINCT subquery2.order_id,
  subquery2.product_ids
FROM
  subquery2
WHERE
  subquery2.unnest IN (
    SELECT
      product_id
    FROM
      subquery
  )
ORDER BY
  subquery2.order_id