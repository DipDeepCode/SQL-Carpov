SELECT
  CONCAT(
    'Заказ № ',
    order_id,
    ' создан ',
    DATE(creation_time)
  ) AS order_info
FROM
  orders
LIMIT
  200;