SELECT
  *,
  unnest(product_ids) AS product_id
FROM
  orders
LIMIT
  100;