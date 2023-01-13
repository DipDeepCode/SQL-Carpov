SELECT
  product_id,
  name,
  price,
  CASE
    WHEN name IN (
      'сахар',
      'сухарики',
      'сушки',
      'семечки',
      'масло льняное',
      'виноград',
      'масло оливковое',
      'арбуз',
      'батон',
      'йогурт',
      'сливки',
      'гречка',
      'овсянка',
      'макароны',
      'баранина',
      'апельсины',
      'бублики',
      'хлеб',
      'горох',
      'сметана',
      'рыба копченая',
      'мука',
      'шпроты',
      'сосиски',
      'свинина',
      'рис',
      'масло кунжутное',
      'сгущенка',
      'ананас',
      'говядина',
      'соль',
      'рыба вяленая',
      'масло подсолнечное',
      'яблоки',
      'груши',
      'лепешка',
      'молоко',
      'курица',
      'лаваш',
      'вафли',
      'мандарины'
    ) THEN ROUND(price / 11, 2)
    ELSE ROUND(price / 6, 2)
  END AS tax,
  CASE
    WHEN name IN (
      'сахар',
      'сухарики',
      'сушки',
      'семечки',
      'масло льняное',
      'виноград',
      'масло оливковое',
      'арбуз',
      'батон',
      'йогурт',
      'сливки',
      'гречка',
      'овсянка',
      'макароны',
      'баранина',
      'апельсины',
      'бублики',
      'хлеб',
      'горох',
      'сметана',
      'рыба копченая',
      'мука',
      'шпроты',
      'сосиски',
      'свинина',
      'рис',
      'масло кунжутное',
      'сгущенка',
      'ананас',
      'говядина',
      'соль',
      'рыба вяленая',
      'масло подсолнечное',
      'яблоки',
      'груши',
      'лепешка',
      'молоко',
      'курица',
      'лаваш',
      'вафли',
      'мандарины'
    ) THEN ROUND(price / 1.1, 2)
    ELSE ROUND(price / 1.2, 2)
  END AS price_before_tax
FROM
  products
ORDER BY
  price_before_tax DESC,
  product_id;