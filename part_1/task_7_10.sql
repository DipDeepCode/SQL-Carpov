WITH subquery AS (
  SELECT
    courier_id,
    COUNT(DISTINCT order_id)
  FROM
    courier_actions
  WHERE
    action = 'deliver_order'
    AND DATE_PART('month', time) = 09
    AND DATE_PART('year', time) = 2022
  GROUP BY
    courier_id
  HAVING
    COUNT(DISTINCT order_id) >= 30
)
SELECT
  courier_id,
  birth_date,
  sex
FROM
  couriers
WHERE
  courier_id IN (
    SELECT
      courier_id
    FROM
      subquery
  )
ORDER BY
  courier_id;