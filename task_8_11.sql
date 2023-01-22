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
  AVG(array_length(subuery2.product_ids, 1)) :: numeric(10, 2) AS avg_order_size
FROM
  user_actions
  RIGHT JOIN subuery2 ON user_actions.order_id = subuery2.order_id
GROUP BY
  user_actions.user_id
ORDER BY
  user_actions.user_id
LIMIT
  1000;