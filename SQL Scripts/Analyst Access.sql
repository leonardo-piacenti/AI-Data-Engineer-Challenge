-- KPI Metrics Comparison (Postgres)
-- Dates:
-- Current window (2025-06-01 → 2025-06-30) - Last 30 days
-- Comparison window (2025-05-01 → 2025-05-31) - Prior 30 days


WITH base AS (
    SELECT
        CAST(date AS DATE) AS date,
        SUM(spend) AS spend,
        SUM(conversions) AS conversions
    FROM ads_spend
    GROUP BY 1
),

kpis AS (
    SELECT
        date,
        spend,
        conversions,
        conversions * 100 AS revenue,
        CASE WHEN conversions > 0 THEN spend::float / conversions END AS cac,
        CASE WHEN spend > 0 THEN (conversions * 100)::float / spend END AS roas
    FROM base
),

-- Current window (2025-06-01 → 2025-06-30)
window_1 AS (
    SELECT
        SUM(spend) AS spend,
        SUM(conversions) AS conversions,
        SUM(revenue) AS revenue,
        SUM(spend)::float / NULLIF(SUM(conversions), 0) AS cac,
        SUM(revenue)::float / NULLIF(SUM(spend), 0) AS roas
    FROM kpis
    WHERE date BETWEEN '2025-06-01' AND '2025-06-30'
),

-- Comparison window (2025-05-01 → 2025-05-31)
window_2 AS (
    SELECT
        SUM(spend) AS spend,
        SUM(conversions) AS conversions,
        SUM(revenue) AS revenue,
        SUM(spend)::float / NULLIF(SUM(conversions), 0) AS cac,
        SUM(revenue)::float / NULLIF(SUM(spend), 0) AS roas
    FROM kpis
    WHERE date BETWEEN '2025-05-01' AND '2025-05-31'
)

SELECT
    metric,
    window_1,
    window_2,
    window_1 - window_2 AS delta_abs,
    ROUND(
        (100.0 * (window_1 - window_2) / NULLIF(window_2, 0))::numeric,
        2
    ) AS delta_pct
FROM (
    SELECT 'spend' AS metric, w1.spend AS window_1, w2.spend AS window_2 FROM window_1 w1, window_2 w2
    UNION ALL
    SELECT 'conversions', w1.conversions, w2.conversions FROM window_1 w1, window_2 w2
    UNION ALL
    SELECT 'revenue', w1.revenue, w2.revenue FROM window_1 w1, window_2 w2
    UNION ALL
    SELECT 'cac', w1.cac, w2.cac FROM window_1 w1, window_2 w2
    UNION ALL
    SELECT 'roas', w1.roas, w2.roas FROM window_1 w1, window_2 w2
) t;
