SELECT
  CASE
    WHEN DATE_PART('year', AGE(birth_date)) BETWEEN 19 AND 24 THEN '19-24'
    WHEN DATE_PART('year', AGE(birth_date)) BETWEEN 25 AND 29 THEN '25-29'
    WHEN DATE_PART('year', AGE(birth_date)) BETWEEN 30 AND 35 THEN '30-35'
    WHEN DATE_PART('year', AGE(birth_date)) BETWEEN 36 AND 41 THEN '36-41'
  END AS group_age,
  COUNT(*) AS users_count
FROM
  users
WHERE 
  birth_date IS NOT NULL
GROUP BY
  group_age
ORDER BY
  group_age;