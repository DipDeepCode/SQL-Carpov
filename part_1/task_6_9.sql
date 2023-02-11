SELECT
  courier_id,
  COUNT(order_id) AS delivered_orders
FROM
  courier_actions
WHERE
  action = 'deliver_order'
  AND DATE_PART('month', time) = 09
  AND DATE_PART('year', time) = 2022
GROUP BY
  courier_id
HAVING 
  COUNT(order_id) = 1
ORDER BY
  courier_id;