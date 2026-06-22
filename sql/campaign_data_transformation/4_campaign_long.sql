CREATE OR REPLACE VIEW campaign_long AS
WITH base AS (
    SELECT
        isoyear,
        isoweek,
        CASE
            WHEN media_channel <> 'TV' THEN LOWER(
                brand || '_' ||
                product_category || '_' ||
                media_channel
            )
            ELSE LOWER(
                brand || '_' ||
                product_category || '_' ||
                media_channel || '_' ||
                sub_channel
            )
        END AS dimension_key,
        COALESCE(spendings, 0) AS spendings,
        COALESCE(grps, 0) AS grps
    FROM campaign_aggregated
),
long_format AS (
    SELECT
        isoyear,
        isoweek,
        dimension_key,
        'spendings' AS metric,
        spendings AS value
    FROM base

    UNION ALL

    SELECT
        isoyear,
        isoweek,
        dimension_key,
        'grps' AS metric,
        grps AS value
    FROM base
)
SELECT
    isoyear,
    isoweek,
    dimension_key || '_' || metric AS product_metric,
    value
FROM long_format
ORDER BY
    isoyear,
    isoweek,
    product_metric;
