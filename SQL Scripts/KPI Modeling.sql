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

last_30 AS (
    SELECT
        SUM(spend) AS spend,
        SUM(conversions) AS conversions,
        SUM(revenue) AS revenue,
        SUM(spend) / NULLIF(SUM(conversions), 0) AS cac,
        SUM(revenue) / NULLIF(SUM(spend), 0) AS roas
    FROM kpis
    WHERE date >= (SELECT MAX(date) FROM kpis) - INTERVAL '29 days'
),

prior_30 AS (
    SELECT
        SUM(spend) AS spend,
        SUM(conversions) AS conversions,
        SUM(revenue) AS revenue,
        SUM(spend) / NULLIF(SUM(conversions), 0) AS cac,
        SUM(revenue) / NULLIF(SUM(spend), 0) AS roas
    FROM kpis
    WHERE date BETWEEN (SELECT MAX(date) FROM kpis) - INTERVAL '59 days'
                    AND (SELECT MAX(date) FROM kpis) - INTERVAL '30 days'
)

SELECT
    'spend' AS metric,
    l.spend AS last_30,
    p.spend AS prior_30,
    l.spend - p.spend AS delta_abs,
    ROUND(100.0 * (l.spend - p.spend) / NULLIF(p.spend, 0), 2) AS delta_pct
FROM last_30 l, prior_30 p
UNION ALL
SELECT
    'conversions', l.conversions, p.conversions,
    l.conversions - p.conversions,
    ROUND(100.0 * (l.conversions - p.conversions) / NULLIF(p.conversions, 0), 2)
FROM last_30 l, prior_30 p
UNION ALL
SELECT
    'revenue', l.revenue, p.revenue,
    l.revenue - p.revenue,
    ROUND(100.0 * (l.revenue - p.revenue) / NULLIF(p.revenue, 0), 2)
FROM last_30 l, prior_30 p
UNION ALL
SELECT
    'cac', l.cac, p.cac,
    l.cac - p.cac,
    ROUND(100.0 * (l.cac - p.cac) / NULLIF(p.cac, 0), 2)
FROM last_30 l, prior_30 p
UNION ALL
SELECT
    'roas', l.roas, p.roas,
    l.roas - p.roas,
    ROUND(100.0 * (l.roas - p.roas) / NULLIF(p.roas, 0), 2)
FROM last_30 l, prior_30 p;
