SELECT
  name,
  price,
  ROUND(price * 1.05, 1) AS new_price
FROM
  products
ORDER BY
  new_price DESC;