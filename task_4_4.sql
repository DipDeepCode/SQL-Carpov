SELECT
  product_id,
  name,
  price,
  '25%' AS discount,
  (price * 0.75) AS price_discounted
FROM
  products
WHERE
  name LIKE '%чай %' AND price > 60;