WITH subquery AS (
  SELECT
    COUNT(DISTINCT order_id)
  FROM
    user_actions
  WHERE
    time >= (
      SELECT
        MAX(time) - INTERVAL '1 week'
      FROM
        user_actions
    )
  GROUP BY
    user_id
)
SELECT
  COUNT(*) AS users_count
FROM
  subquery;