WITH subquery1 AS (
  SELECT
    order_id,
    unnest(product_ids) AS product_id
  FROM
    orders
)
SELECT
  subquery1.order_id,
  subquery1.product_id,
  products.price
FROM
  subquery1
  LEFT JOIN products ON subquery1.product_id = products.product_id
ORDER BY
  order_id,
  product_id
LIMIT
  1000;