WITH unnested_ids AS (
  SELECT
    order_id,
    unnest(product_ids) AS product_id
  FROM
    orders
  WHERE
    order_id NOT IN (
      SELECT
        order_id
      FROM
        user_actions
      WHERE
        action = 'cancel_order'
    )
    AND array_length(product_ids, 1) > 1
),
unnested_names AS (
  SELECT
    order_id,
    name
  FROM
    unnested_ids
    JOIN products ON unnested_ids.product_id = products.product_id
)
SELECT
  ARRAY [LEAST(t1.name, t2.name), GREATEST(t1.name, t2.name)] AS pair,
  COUNT(DISTINCT t1.order_id) AS count_pair
FROM
  unnested_names t1
  JOIN unnested_names t2 ON t1.order_id = t2.order_id
WHERE
  t1.name <> t2.name
GROUP BY
  pair
ORDER BY
  count_pair DESC,
  pair