WITH users_first_order_date AS (
  SELECT
    user_id,
    MIN(time)::date AS first_order_date
  FROM
    user_actions
  GROUP BY
    user_id
  ORDER BY
    user_id
)
SELECT
  COUNT(DISTINCT user_id),
  first_order_date
FROM
  users_first_order_date
GROUP BY
  first_order_date
ORDER BY
  first_order_date;