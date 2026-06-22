DROP VIEW IF EXISTS campaign_long CASCADE;
DROP VIEW IF EXISTS campaign_aggregated CASCADE;

CREATE OR REPLACE VIEW campaign_aggregated AS
WITH aggregated AS (
    SELECT
        isoyear,
        isoweek,
        (100 * isoyear + isoweek) AS isoyear_isoweek,
        brand,
        media_channel,
        sub_channel,
        campaign_name,
        CASE
            WHEN campaign_objective ILIKE '%brand%' THEN 'brand'
            ELSE product_category
        END AS product_category_raw,
        target,
        SUM(net_spend::NUMERIC) AS spendings,
        SUM(gross_spend::NUMERIC) AS gross_spend,
        SUM(grps::NUMERIC) AS grps
        -- GRP (Gross Rating Point) is a marketing metric used to measure the total
        -- advertising exposure of a campaign. Price per GRP represents the cost of
        -- purchasing one GRP and is commonly used in TV advertising planning.
    FROM campaign_data
    GROUP BY
        isoyear,
        isoweek,
        brand,
        media_channel,
        sub_channel,
        campaign_name,
        target,
        campaign_objective,
        product_category
),
price_mapping AS (
    SELECT
        isoyear,
        isoweek,
        isoyear_isoweek,
        brand,
        media_channel,
        sub_channel,
        campaign_name,
        LOWER(product_category_raw) AS product_category_1,
        target,
        spendings,
        gross_spend,
        grps,
        CASE
            -- The original script contained manually maintained price-per-GRP rules.
            -- These values are fictional and only demonstrate the transformation pattern.
            WHEN product_category_raw ILIKE '%wireless%' AND isoyear_isoweek <= 202513 THEN 105.74
            WHEN product_category_raw ILIKE '%wireless%' AND isoyear_isoweek > 202513 THEN 585.94
            WHEN product_category_raw ILIKE '%wireline%' AND isoyear_isoweek <= 202513 THEN 338.22
            WHEN product_category_raw ILIKE '%wireline%' AND isoyear_isoweek > 202513 THEN -1
            WHEN product_category_raw ILIKE '%brand%' AND isoyear_isoweek <= 202513 THEN 221.98
            WHEN product_category_raw ILIKE '%brand%' AND isoyear_isoweek > 202513 THEN -1
            WHEN product_category_raw ILIKE '%kombi%' AND isoyear_isoweek <= 202513 THEN -1
            WHEN product_category_raw ILIKE '%kombi%' AND isoyear_isoweek > 202513 THEN 132.91
            ELSE NULL
        END AS price_per_grp
    FROM aggregated
),
final AS (
    SELECT
        isoyear,
        isoweek,
        isoyear_isoweek,
        brand,
        media_channel,
        sub_channel,
        campaign_name,
        CASE
            WHEN product_category_1 LIKE '%pp%' THEN TRIM(REPLACE(product_category_1, 'pp', ''))
            WHEN product_category_1 = 'wireline & wireless' THEN 'kombi'
            ELSE product_category_1
        END AS product_category,
        target,
        spendings,
        gross_spend,
        CASE
            WHEN (grps IS NULL OR grps = 0) AND spendings > 0 AND price_per_grp IS NOT NULL
                THEN spendings / NULLIF(price_per_grp, 0)
            ELSE grps
        END AS grps,
        price_per_grp
    FROM price_mapping
)
SELECT *
FROM final;
