-- my solution
SELECT
    date
    , revenue
    , costs::int
    , tax
    , revenue - costs - tax AS gross_profit
    , sum(revenue) OVER (ORDER BY date) AS total_revenue
    , sum(costs) OVER (ORDER BY date) AS total_costs
    , sum(tax) OVER (ORDER BY date) AS total_tax
    , sum(revenue - costs - tax) OVER (ORDER BY date) AS total_gross_profit
    , round(100*(revenue - costs - tax)::numeric / revenue, 2) AS gross_profit_ratio
    , round(100*(sum(revenue - costs - tax) OVER (ORDER BY date))/ sum(revenue) OVER (ORDER BY date), 2) AS total_gross_profit_ratio
FROM (  SELECT
            date
            , revenue
            , CASE 
                WHEN date < '2022-09-01'::date THEN 120000::numeric + 140*number_of_orders + 150*number_of_delivered_orders + 400*total_bonus
                WHEN date >= '2022-09-01'::date THEN 150000::numeric + 115*number_of_orders + 150*number_of_delivered_orders + 500*total_bonus
                ELSE 0 
              END AS costs
            , tax
        FROM (  SELECT 
                    date
                    , count(distinct order_id) AS number_of_orders
                    , sum(price) AS revenue 
                    , sum(  CASE 
                                WHEN name IN (  'сахар', 'сухарики', 'сушки', 'семечки', 
                                                'масло льняное', 'виноград', 'масло оливковое', 
                                                'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
                                                'овсянка', 'макароны', 'баранина', 'апельсины', 
                                                'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 
                                                'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
                                                'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 
                                                'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 
                                                'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') THEN round(price/11, 2) 
                                ELSE round(price/6, 2) 
                            END) AS tax
                FROM (  SELECT
                            creation_time::date AS date
                            , unnest(product_ids) AS product_id
                            , order_id
                        FROM orders 
                        WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS t1
                LEFT JOIN products using (product_id)
                GROUP BY date) AS t2
        LEFT JOIN ( SELECT
                        time::date AS date
                        , count(distinct order_id) AS number_of_delivered_orders
                    FROM courier_actions
                    WHERE action = 'deliver_order'
                    GROUP BY time::date) AS t3 using (date)
        LEFT JOIN ( SELECT 
                        date
                        , sum(number_of_bonus) AS total_bonus
                    FROM (  SELECT 
                                time::date AS date
                                , courier_id
                                , CASE
                                    WHEN count(distinct order_id) >= 5 THEN 1
                                    ELSE 0 
                                  END AS number_of_bonus
                            FROM courier_actions
                            WHERE action = 'deliver_order'
                            GROUP BY time::date, courier_id) AS t4
                    GROUP BY date) AS t5 using (date)) AS t6
ORDER BY date


-- right solution
SELECT date,
       revenue,
       costs,
       tax,
       gross_profit,
       total_revenue,
       total_costs,
       total_tax,
       total_gross_profit,
       round(gross_profit / revenue * 100, 2) as gross_profit_ratio,
       round(total_gross_profit / total_revenue * 100, 2) as total_gross_profit_ratio
FROM   (SELECT date,
               revenue,
               costs,
               tax,
               revenue - costs - tax as gross_profit,
               sum(revenue) OVER (ORDER BY date) as total_revenue,
               sum(costs) OVER (ORDER BY date) as total_costs,
               sum(tax) OVER (ORDER BY date) as total_tax,
               sum(revenue - costs - tax) OVER (ORDER BY date) as total_gross_profit
        FROM   (SELECT date,
                       orders_packed,
                       orders_delivered,
                       couriers_count,
                       revenue,
                       case when date_part('month', date) = 8 then 120000 + 140 * coalesce(orders_packed, 0) + 150 * coalesce(orders_delivered, 0) + 400 * coalesce(couriers_count, 0)
                            when date_part('month',date) = 9 then 150000 + 115 * coalesce(orders_packed, 0) + 150 * coalesce(orders_delivered, 0) + 500 * coalesce(couriers_count, 0) end as costs,
                       tax
                FROM   (SELECT creation_time::date as date,
                               count(distinct order_id) as orders_packed,
                               sum(price) as revenue,
                               sum(tax) as tax
                        FROM   (SELECT order_id,
                                       creation_time,
                                       product_id,
                                       name,
                                       price,
                                       case when name in ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 'овсянка', 'макароны', 'баранина', 'апельсины', 'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') then round(price/110*10,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         2)
                                            else round(price/120*20, 2) end as tax
                                FROM   (SELECT order_id,
                                               creation_time,
                                               unnest(product_ids) as product_id
                                        FROM   orders
                                        WHERE  order_id not in (SELECT order_id
                                                                FROM   user_actions
                                                                WHERE  action = 'cancel_order')) t1
                                    LEFT JOIN products using (product_id)) t2
                        GROUP BY date) t3
                    LEFT JOIN (SELECT time::date as date,
                                      count(distinct order_id) as orders_delivered
                               FROM   courier_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                                  and action = 'deliver_order'
                               GROUP BY date) t4 using (date)
                    LEFT JOIN (SELECT date,
                                      count(courier_id) as couriers_count
                               FROM   (SELECT time::date as date,
                                              courier_id,
                                              count(distinct order_id) as orders_delivered
                                       FROM   courier_actions
                                       WHERE  order_id not in (SELECT order_id
                                                               FROM   user_actions
                                                               WHERE  action = 'cancel_order')
                                          and action = 'deliver_order'
                                       GROUP BY date, courier_id having count(distinct order_id) >= 5) t5
                               GROUP BY date) t6 using (date)) t7) t8