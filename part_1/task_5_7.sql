SELECT
  TRUNC(AVG(price), 2) AS avg_price
FROM
  products
WHERE
  (
    name LIKE '%чай%'
    AND name NOT LIKE '%иван-чай%'
    AND name NOT LIKE '%чайный%'
  )
  OR name LIKE '%кофе%';