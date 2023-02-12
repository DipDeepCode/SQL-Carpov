-- my solution
SELECT start_date as date
    , new_users
    , new_couriers
    , total_users
    , total_couriers
    , ROUND((absolute_new_users_change::numeric / new_users_lag) * 100, 2) AS new_users_change
    , ROUND((absolute_new_couriers_change::numeric / new_couriers_lag) * 100, 2) AS new_couriers_change
    , ROUND((absolute_total_users_change::numeric / total_users_lag) * 100, 2) AS total_users_growth
    , ROUND((absolute_total_couriers_change::numeric / total_couriers_lag) * 100, 2) AS total_couriers_growth
FROM (
    SELECT start_date
        , new_users
        , new_couriers
        , total_users
        , total_couriers
        , new_users_lag
        , new_couriers_lag
        , new_users - new_users_lag AS absolute_new_users_change
        , new_couriers - new_couriers_lag AS absolute_new_couriers_change
        , LAG(total_users,1) OVER (ORDER BY start_date) AS total_users_lag
        , total_users - LAG(total_users,1) OVER (ORDER BY start_date) AS absolute_total_users_change
        , LAG(total_couriers,1) OVER (ORDER BY start_date) AS total_couriers_lag
        , total_couriers - LAG(total_couriers,1) OVER (ORDER BY start_date) AS absolute_total_couriers_change
    FROM (
        SELECT start_date
            , new_users
            , new_couriers
            , (sum(new_users) OVER (ORDER BY start_date))::int AS total_users
            , (sum(new_couriers) OVER (ORDER BY start_date))::int AS total_couriers
            , LAG(new_users,1) OVER (ORDER BY start_date) AS new_users_lag
            , LAG(new_couriers,1) OVER (ORDER BY start_date) AS new_couriers_lag
        FROM (  
                SELECT start_date, count(courier_id) as new_couriers
                FROM   (SELECT courier_id, min(time::date) as start_date
                        FROM   courier_actions
                        GROUP BY courier_id) t1
                GROUP BY start_date) t2
        LEFT JOIN (
                SELECT start_date, count(user_id) as new_users
                FROM   (SELECT user_id, min(time::date) as start_date
                        FROM   user_actions
                        GROUP BY user_id) t3
                GROUP BY start_date) t4 USING (start_date)
        ) t5
    ) t6
ORDER BY start_date

-- right solution
SELECT date,
       new_users,
       new_couriers,
       total_users,
       total_couriers,
       round(100 * (new_users - lag(new_users, 1) OVER (ORDER BY date)) / lag(new_users, 1) OVER (ORDER BY date)::decimal,
             2) as new_users_change,
       round(100 * (new_couriers - lag(new_couriers, 1) OVER (ORDER BY date)) / lag(new_couriers, 1) OVER (ORDER BY date)::decimal,
             2) as new_couriers_change,
       round(100 * new_users::decimal / lag(total_users, 1) OVER (ORDER BY date),
             2) as total_users_growth,
       round(100 * new_couriers::decimal / lag(total_couriers, 1) OVER (ORDER BY date),
             2) as total_couriers_growth
FROM   (SELECT start_date as date,
               new_users,
               new_couriers,
               (sum(new_users) OVER (ORDER BY start_date))::int as total_users,
               (sum(new_couriers) OVER (ORDER BY start_date))::int as total_couriers
        FROM   (SELECT start_date,
                       count(courier_id) as new_couriers
                FROM   (SELECT courier_id,
                               min(time::date) as start_date
                        FROM   courier_actions
                        GROUP BY courier_id) t1
                GROUP BY start_date) t2
            LEFT JOIN (SELECT start_date,
                              count(user_id) as new_users
                       FROM   (SELECT user_id,
                                      min(time::date) as start_date
                               FROM   user_actions
                               GROUP BY user_id) t3
                       GROUP BY start_date) t4 using (start_date)) t5