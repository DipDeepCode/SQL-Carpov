SELECT
  user_actions.user_id AS user_id_left, users.user_id AS user_id_right,  order_id, time, action, sex, birth_date
FROM
  user_actions
  LEFT JOIN users 
  ON user_actions.user_id = users.user_id
WHERE
  users.user_id IS NOT NULL
ORDER BY 
  user_actions.user_id
LIMIT 1000;