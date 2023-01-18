SELECT
  sex,
  COUNT(courier_id) couriers_count
FROM
  couriers
GROUP BY
  sex
ORDER BY
  couriers_count;