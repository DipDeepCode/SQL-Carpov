WITH subquery1 AS (
  SELECT
    order_id,
    unnest(product_ids) AS product_id
  FROM
    orders
)
SELECT
  subquery1.order_id,
  SUM(products.price) AS order_price
FROM
  subquery1
  LEFT JOIN products ON subquery1.product_id = products.product_id
GROUP BY
  order_id
ORDER BY
  order_id
LIMIT
  1000;