SELECT
  name AS product_name,
  price AS product_price
FROM
  products
ORDER BY
  price DESC
LIMIT
  5;