WITH user_id_cancel_rate AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) FILTER (
      WHERE
        action = 'cancel_order'
    ) :: DECIMAL / COUNT(DISTINCT order_id) AS cancel_rate
  FROM
    user_actions
  GROUP BY
    user_id
  ORDER BY
    user_id
)
SELECT
  COALESCE(sex, 'unknown') AS sex,
  ROUND(AVG(cancel_rate), 3) AS avg_cancel_rate
FROM
  user_id_cancel_rate
  LEFT JOIN users ON user_id_cancel_rate.user_id = users.user_id
GROUP BY
  sex
ORDER BY
  sex