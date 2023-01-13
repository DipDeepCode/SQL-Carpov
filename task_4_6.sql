SELECT
  user_id,
  birth_date
FROM
  users
WHERE
  sex = 'male' AND birth_date IS NOT NULL
ORDER BY
  birth_date
LIMIT
  50;