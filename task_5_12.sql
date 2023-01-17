SELECT
  COUNT(DISTINCT(user_id)) - COUNT(DISTINCT(user_id)) FILTER(
    WHERE
      action = 'cancel_order'
  ) AS users_count
FROM
  user_actions;