SELECT
  DATE_PART('year', AGE(birth_date)) AS age,
  COUNT(*) AS users_count
FROM
  users
GROUP BY
  age
ORDER BY
  age;