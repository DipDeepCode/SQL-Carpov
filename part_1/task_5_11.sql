SELECT
  SUM(
    CASE
      WHEN name = 'сухарики' THEN price * 3
      WHEN name = 'чипсы' THEN price * 2
      WHEN name = 'энергетический напиток' THEN price
    END
  ) AS order_price
FROM
  products;