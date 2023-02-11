SELECT AGE(MAX(birth_date), MIN(birth_date)) AS age_diff
FROM users
WHERE sex = 'male';