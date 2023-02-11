WITH orders_creation_time AS (
  SELECT
    order_id,
    time AS order_created_time
  FROM
    user_actions
  WHERE
    action = 'create_order'
),
orders_deliver_time AS (
  SELECT
    order_id,
    time AS order_delivered_time
  FROM
    courier_actions
  WHERE
    action = 'deliver_order'
)
SELECT
  orders_creation_time.order_id
FROM
  orders_creation_time
  JOIN orders_deliver_time ON orders_creation_time.order_id = orders_deliver_time.order_id
ORDER BY
  (order_delivered_time - order_created_time) DESC
LIMIT
  10;