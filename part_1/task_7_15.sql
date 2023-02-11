WITH last_user_action_date AS (
  SELECT
    MAX(DATE(time)) AS last_date
  FROM
    user_actions
),
avg_age AS (
  SELECT
    ROUND(
      AVG(
        DATE_PART(
          'year',
          AGE(
            (
              SELECT
                last_date
              FROM
                last_user_action_date
            ),
            birth_date
          )
        )
      ) :: DECIMAL,
      0
    ) AS age
  FROM
    users
  WHERE
    birth_date IS NOT NULL
)
SELECT
  user_id,
  CASE
    WHEN birth_date IS NOT NULL THEN DATE_PART(
      'year',
      AGE(
        (
          SELECT
            last_date
          FROM
            last_user_action_date
        ),
        birth_date
      )
    )
    ELSE (
      SELECT
        age
      FROM
        avg_age
    )
  END AS age
FROM
  users
ORDER BY
  user_id;