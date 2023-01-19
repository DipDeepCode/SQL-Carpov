WITH subqery AS (
  SELECT
    MAX(time) :: DATE
  FROM
    courier_actions
)
SELECT
  MIN(
    AGE(
      (
        SELECT
          *
        FROM
          subqery
      ),
      birth_date
    )
  ) :: VARCHAR AS min_age
FROM
  couriers
WHERE
  sex = 'male';