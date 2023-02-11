SELECT
  sex,
  MAX(DATE_PART('year', AGE(birth_date))) AS max_age
FROM
  users
GROUP BY
  sex
ORDER BY
  max_age;