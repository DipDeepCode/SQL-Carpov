WITH subqery AS (
  SELECT
    order_id
  FROM
    user_actions
  WHERE
    action = 'cancel_order'
)
SELECT
  order_id
FROM
  user_actions
WHERE
  order_id NOT IN (
    SELECT
      *
    FROM
      subqery
  )
ORDER BY
  order_id;