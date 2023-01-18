SELECT
  courier_id,
  COUNT(order_id) AS delivered_orders
FROM
  courier_actions
WHERE
  action = 'deliver_order'
  AND DATE_PART('month', time) = 09
GROUP BY
  courier_id
ORDER BY
  delivered_orders DESC
LIMIT
  3;