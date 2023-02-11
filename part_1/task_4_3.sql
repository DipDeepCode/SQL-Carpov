SELECT
  product_id,
  name
FROM
  products
WHERE
  name LIKE 'с%' AND name NOT LIKE '% %';
  