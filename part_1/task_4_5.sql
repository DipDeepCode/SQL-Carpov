SELECT
  user_id,
  order_id,
  action,
  time
FROM
  user_actions
WHERE
  user_id IN (170, 200, 230)
  AND time BETWEEN '2022-08-25'
  AND '2022-09-05'
ORDER BY
  time DESC;