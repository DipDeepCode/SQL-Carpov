SELECT
  product_id,
  name,
  price
FROM
  products
WHERE
  price <= 100
ORDER BY
  price DESC;