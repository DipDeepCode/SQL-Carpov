WITH courier_action_2 AS (
SELECT MIN(time)::date AS date, courier_id
FROM courier_actions
GROUP BY courier_id
),
user_action_2 AS (
SELECT MIN(time)::date AS date, user_id
FROM user_actions
GROUP BY user_id
)
SELECT courier_action_2.date, COUNT(DISTINCT user_id) AS new_users, COUNT(DISTINCT courier_id) AS new_couriers
FROM courier_action_2 FULL JOIN user_action_2 ON courier_action_2.date = user_action_2.date
GROUP BY courier_action_2.date
ORDER BY courier_action_2.date
LIMIT 100