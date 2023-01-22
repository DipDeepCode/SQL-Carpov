WITH subquery1 AS (
  SELECT
    order_id,
    unnest(product_ids) AS product_id
  FROM
    orders
),
subuery2 AS (
  SELECT
    subquery1.order_id,
    SUM(products.price) AS order_price,
    COUNT(products.price) AS products_count
  FROM
    subquery1
    LEFT JOIN products ON subquery1.product_id = products.product_id
  GROUP BY
    order_id
),
subquery3 AS (
  SELECT
    order_id
  FROM
    user_actions
  WHERE
    action = 'cancel_order'
),
subuery4 AS (
  SELECT
    order_id,
    product_ids
  FROM
    orders
  WHERE
    order_id NOT IN (
      SELECT
        *
      FROM
        subquery3
    )
)
SELECT
  user_actions.user_id,
  COUNT(subuery4.order_id) AS orders_count,(
    SUM(subuery2.products_count) / COUNT(subuery4.order_id)
  ) :: numeric(10, 2) AS avg_order_size,
  SUM(subuery2.order_price) AS sum_order_value,(
    SUM(subuery2.order_price) / COUNT(subuery4.order_id)
  ) :: numeric(10, 2) AS avg_order_value,
  MIN(subuery2.order_price) AS min_order_value,
  MAX(subuery2.order_price) AS max_order_value
FROM
  user_actions
  RIGHT JOIN subuery4 ON user_actions.order_id = subuery4.order_id
  LEFT JOIN subuery2 ON subuery4.order_id = subuery2.order_id
GROUP BY
  user_actions.user_id
ORDER BY
  user_actions.user_id
LIMIT
  1000;