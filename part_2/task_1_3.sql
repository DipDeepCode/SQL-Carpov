-- my solution 1
WITH paing_active AS (
    SELECT 
        date
        , paying_users
        , active_couriers
    FROM (
        SELECT 
            time::date AS date
            , COUNT(DISTINCT user_id) AS paying_users
        FROM user_actions
        WHERE order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action LIKE 'cancel_order'
            )
        GROUP BY date
        ) a1
    LEFT JOIN (
        SELECT 
            time::DATE AS date
            , COUNT(DISTINCT courier_id) AS active_couriers
        FROM courier_actions
        WHERE order_id IN (
            SELECT order_id
            FROM courier_actions
            WHERE action LIKE 'deliver_order'
            )
        GROUP BY date
        ) a2 USING (date)
), total AS (
    SELECT 
        start_date as date
        , (sum(new_users) OVER (ORDER BY start_date))::int as total_users
        , (sum(new_couriers) OVER (ORDER BY start_date))::int as total_couriers
    FROM (
        SELECT 
            start_date
            , count(courier_id) as new_couriers
        FROM (
            SELECT 
                courier_id
                , min(time::date) as start_date
            FROM courier_actions
            GROUP BY courier_id
            ) t1
        GROUP BY start_date) t2
    LEFT JOIN (
        SELECT 
            start_date
            , count(user_id) as new_users
        FROM (
            SELECT 
                user_id
                , min(time::date) as start_date
            FROM user_actions
            GROUP BY user_id
            ) t3
        GROUP BY start_date) t4 using (start_date)
)
SELECT 
    date
    , paying_users
    , active_couriers
    , ROUND((paying_users::NUMERIC / total_users) * 100, 2) AS paying_users_share
    , ROUND((active_couriers::NUMERIC / total_couriers) * 100, 2) AS active_couriers_share
FROM paing_active
LEFT JOIN total USING (date)
ORDER BY date

-- my solution 2
SELECT 
    start_date AS date
    , paying_users
    , active_couriers
    , ROUND(100 * paying_users::NUMERIC / total_users, 2) AS paying_users_share
    , ROUND(100 * active_couriers::NUMERIC / total_couriers, 2) AS active_couriers_share
FROM (
    SELECT 
        start_date
        , new_users
        , new_couriers
        , (sum(new_users) OVER (ORDER BY start_date))::int as total_users
        , (sum(new_couriers) OVER (ORDER BY start_date))::int as total_couriers
    FROM (
        SELECT 
            start_date
            , count(courier_id) as new_couriers
        FROM (
            SELECT 
                courier_id
                , min(time::date) as start_date
            FROM courier_actions
            GROUP BY courier_id
            ) t1
        GROUP BY start_date
        ) t2
    LEFT JOIN (
        SELECT 
            start_date
            , count(user_id) as new_users
        FROM (
            SELECT 
                user_id
                , min(time::date) as start_date
            FROM user_actions
            GROUP BY user_id
            ) t3
        GROUP BY start_date
        ) t4 using (start_date)
    ) t5
LEFT JOIN (
    SELECT 
        time::date AS start_date
        , COUNT(DISTINCT user_id) AS paying_users
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action LIKE 'cancel_order'
        )
    GROUP BY start_date
    ) t6 USING (start_date)
LEFT JOIN (
    SELECT 
        time::DATE AS start_date
        , COUNT(DISTINCT courier_id) AS active_couriers
    FROM courier_actions
    WHERE order_id IN (
        SELECT order_id
        FROM courier_actions
        WHERE action LIKE 'deliver_order'
        )
    GROUP BY start_date
    ) t7 USING (start_date)
ORDER BY date

-- right solution
SELECT date,
       paying_users,
       active_couriers,
       round(100 * paying_users::decimal / total_users, 2) as paying_users_share,
       round(100 * active_couriers::decimal / total_couriers, 2) as active_couriers_share
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
    LEFT JOIN (SELECT time::date as date,
                      count(distinct courier_id) as active_couriers
               FROM   courier_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t6 using (date)
    LEFT JOIN (SELECT time::date as date,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t7 using (date)
    