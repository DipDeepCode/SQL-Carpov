SELECT
  ROUND(AVG(a),2) AS orders_avg
FROM
  (
    SELECT
      user_id,
      COUNT(DISTINCT order_id) AS a
    FROM
      user_actions
    GROUP BY
      user_id
  ) AS subquery;