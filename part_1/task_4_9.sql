SELECT
  order_id
FROM
  user_actions
WHERE
  action = 'create_order'
  AND DATE_PART('month', time) = '08'
ORDER BY
  order_id;