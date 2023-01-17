SELECT
  COUNT(courier_id) AS couriers_count
FROM
  couriers
WHERE
  sex = 'female';