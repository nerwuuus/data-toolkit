WITH t AS (
    SELECT
        TO_CHAR(date, 'IYYY')::INT AS isoyear,
        TO_CHAR(date, 'IW')::INT AS isoweek,
        CASE
            WHEN product_id = 'P001' THEN 'acq'
            WHEN product_id = 'P002' THEN 'ret'
            WHEN product_id = 'P003' THEN 'wire'
        END AS product,
        AVG(price) AS non_promo_price,
        SUM(gross_orders * price) AS gross_orders_value,
        SUM(gross_orders) AS gross_orders
    FROM gross_orders
    GROUP BY
        TO_CHAR(date, 'IYYY'),
        TO_CHAR(date, 'IW'),
        product_id
),
t2 AS (
    SELECT isoyear, isoweek, product, 'non_promo_price' AS metric, non_promo_price AS value
    FROM t
    UNION ALL
    SELECT isoyear, isoweek, product, 'gross_orders_value' AS metric, gross_orders_value AS value
    FROM t
    UNION ALL
    SELECT isoyear, isoweek, product, 'gross_orders' AS metric, gross_orders AS value
    FROM t
),
t3 AS (
    SELECT
        isoyear,
        isoweek,
        product || '_' || metric AS product_metric,
        value
    FROM t2
)
SELECT *
FROM t3
WHERE product_metric IS NOT NULL
ORDER BY
    isoyear,
    isoweek;
