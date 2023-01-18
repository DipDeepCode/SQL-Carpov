SELECT
  DATE_TRUNC('month', time) AS month,
  action,
  COUNT(user_id) AS orders_count
FROM
  user_actions
WHERE
  action = 'create_order'
  OR action = 'cancel_order'
GROUP BY
  action,
  month
ORDER BY
  month,
  action;