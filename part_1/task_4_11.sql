SELECT
  user_id,
  order_id,
  action,
  time
FROM
  user_actions
WHERE
  action = 'cancel_order'
  AND DATE_PART('year', time) = '2022'
  AND DATE_PART('month', time) = '08'
  AND DATE_PART('dow', time) = 3
  AND DATE_PART('hour', time) BETWEEN '12' AND '15'
ORDER BY
  time DESC;