WITH unnested_orders AS (
  SELECT
    order_id,
    unnest(product_ids) AS product_id
  FROM
    orders
),
biggest_orders AS (
  SELECT
    order_id
  FROM
    unnested_orders
  GROUP BY
    order_id
  ORDER BY
    COUNT(product_id) DESC,
    order_id
  LIMIT
    5
), last_date_in_user_actions AS (
  SELECT
    DATE(MAX(time)) AS last_date
  FROM
    user_actions
)
SELECT
  DISTINCT biggest_orders.order_id,
  user_actions.user_id,
  DATE_PART(
    'year',
    AGE(
      (
        SELECT
          last_date
        FROM
          last_date_in_user_actions
      ),
      users.birth_date
    )
  ) AS user_age,
  courier_actions.courier_id,
  DATE_PART(
    'year',
    AGE(
      (
        SELECT
          last_date
        FROM
          last_date_in_user_actions
      ),
      couriers.birth_date
    )
  ) AS courier_age
FROM
  biggest_orders
  LEFT JOIN user_actions ON biggest_orders.order_id = user_actions.order_id
  LEFT JOIN users ON user_actions.user_id = users.user_id
  LEFT JOIN courier_actions ON biggest_orders.order_id = courier_actions.order_id
  LEFT JOIN couriers ON courier_actions.courier_id = couriers.courier_id