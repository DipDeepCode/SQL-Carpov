SELECT
  array_length(product_ids, 1) AS order_size,
  COUNT(order_id) AS orders_count
FROM
  orders
GROUP BY
  order_size
ORDER BY
  order_size;