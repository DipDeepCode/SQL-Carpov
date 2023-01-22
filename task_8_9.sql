SELECT
  user_actions.user_id,
  user_actions.order_id,
  orders.product_ids
FROM
  user_actions
  RIGHT JOIN orders ON user_actions.order_id = orders.order_id
ORDER BY
  user_actions.user_id,
  user_actions.order_id
LIMIT
  1000