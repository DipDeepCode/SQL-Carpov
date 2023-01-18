SELECT
  user_id,
  ROUND(
    COUNT(DISTINCT order_id) FILTER (
      WHERE
        action = 'cancel_order'
    ) / COUNT(DISTINCT order_id) :: DECIMAL,
    2
  ) AS cancel_rate
FROM
  user_actions
GROUP BY
  user_id
ORDER BY
  user_id;