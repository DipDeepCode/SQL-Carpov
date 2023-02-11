SELECT
  *,
  COUNT(*) AS times_purchased
FROM
  (
    SELECT
      unnest (product_ids) AS product_id
    FROM
      orders
  ) AS sqr
GROUP BY
  product_id
ORDER BY
  times_purchased DESC
LIMIT
  10;