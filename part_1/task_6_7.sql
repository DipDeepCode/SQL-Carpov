SELECT
  array_length(product_ids, 1) AS order_size,
  COUNT(order_id) AS orders_count
FROM
  orders
GROUP BY
  order_size
HAVING
  COUNT(order_id) > 5000
ORDER BY
  order_size;