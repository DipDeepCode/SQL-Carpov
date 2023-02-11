WITH subquery1 AS (
  SELECT
    order_id
  FROM
    user_actions
  WHERE
    action = 'cancel_order'
),
subuery2 AS (
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
        subquery1
    )
)
SELECT
  user_actions.user_id,
  subuery2.order_id,
  subuery2.product_ids
FROM
  user_actions
  RIGHT JOIN subuery2 ON user_actions.order_id = subuery2.order_id
ORDER BY
  user_actions.user_id,
  subuery2.order_id
LIMIT
  1000;