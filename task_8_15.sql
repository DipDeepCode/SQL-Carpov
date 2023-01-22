WITH canceled_orders AS (
  SELECT
    order_id AS canceled_order_id
  FROM
    user_actions
  WHERE
    action = 'cancel_order'
),
products_and_times AS (
  SELECT
    unnest(product_ids) AS product_id,
    COUNT(DISTINCT order_id) AS times_purchased
  FROM
    orders
  WHERE
    order_id NOT IN (
      SELECT
        canceled_order_id
      FROM
        canceled_orders
    )
  GROUP BY
    product_id
  ORDER BY
    times_purchased DESC
  LIMIT
    10
)
SELECT
  name,
  times_purchased
FROM
  products_and_times
  LEFT JOIN products ON products_and_times.product_id = products.product_id
ORDER BY
  times_purchased DESC,
  name DESC;