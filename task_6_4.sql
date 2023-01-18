SELECT
  DATE_PART('year', AGE(birth_date)) AS age
  ,sex
  ,COUNT(*) AS users_count
FROM
  users
WHERE
  birth_date IS NOT NULL
GROUP BY
  age, sex
ORDER BY
  age, sex;