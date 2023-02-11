SELECT
  name,
  price,
  (price * 1.05) AS new_price
FROM
  products
ORDER BY 
  new_price DESC;