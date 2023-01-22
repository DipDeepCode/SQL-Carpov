WITH unnest_orders AS (
  SELECT
    order_id,
    unnest(product_ids) AS product_id
  FROM
    orders
)
SELECT
  unnest_orders.order_id,
  array_agg(name) AS product_names
FROM
  unnest_orders
  LEFT JOIN products ON unnest_orders.product_id = products.product_id
GROUP BY
  unnest_orders.order_id
ORDER BY
  unnest_orders.order_id
LIMIT
  1000;