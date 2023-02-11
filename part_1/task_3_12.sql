SELECT
  name,
  price,
  CASE
    WHEN name = 'икра' THEN price
    WHEN price > 100 THEN price * 1.05
    ELSE price
  END AS new_price
FROM
  products
ORDER BY
  new_price DESC;