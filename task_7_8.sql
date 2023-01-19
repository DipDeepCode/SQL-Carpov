WITH subquery AS (
  SELECT
    ROUND(
      COUNT(DISTINCT order_id) / COUNT (DISTINCT user_id) :: DECIMAL,
      2
    )
  FROM
    user_actions
)
SELECT
  user_id,
  COUNT(DISTINCT order_id) AS orders_count,
  (
    SELECT
      *
    FROM
      subquery
  ) AS orders_avg,
  COUNT(DISTINCT order_id) - (
    SELECT
      *
    FROM
      subquery
  ) AS orders_diff
FROM
  user_actions
GROUP BY
  user_id
ORDER BY
  user_id