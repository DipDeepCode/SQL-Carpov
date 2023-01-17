SELECT
  SUM(
    CASE
      WHEN name IN ('сухарики', 'чипсы', 'энергетический напиток') THEN price
    END
  ) AS order_price
FROM
  products;