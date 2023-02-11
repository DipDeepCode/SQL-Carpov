SELECT MIN(AGE(current_date, birth_date))::VARCHAR AS min_age
FROM couriers
WHERE sex = 'male';