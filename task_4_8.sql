SELECT
  order_id,
  time
FROM
  courier_actions
WHERE
  action = 'deliver_order' AND courier_id = 100
ORDER BY
  time DESC
LIMIT
  10;