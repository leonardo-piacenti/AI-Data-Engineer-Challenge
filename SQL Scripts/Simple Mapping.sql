--Steps:

--Natural language input → Analyst asks a question in plain English - “Compare CAC and ROAS for last 30 days vs prior 30 days.”

--Template mapping → The system detects the metric(s) + time window(s).

--SQL execution → Dates are injected into the SQL script.

--Result → Compact KPI comparison table returned to the analyst.

  
  WITH base AS (
    SELECT CAST(date AS DATE) AS date, SUM(spend) AS spend, SUM(conversions) AS conversions
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
window_1 AS (
    SELECT
        SUM(spend)::float / NULLIF(SUM(conversions), 0) AS cac,
        SUM(conversions * 100)::float / NULLIF(SUM(spend), 0) AS roas
    FROM kpis
    WHERE date BETWEEN '2025-05-01' AND '2025-05-31'
),
window_2 AS (
    SELECT
        SUM(spend)::float / NULLIF(SUM(conversions), 0) AS cac,
        SUM(conversions * 100)::float / NULLIF(SUM(spend), 0) AS roas
    FROM kpis
    WHERE date BETWEEN '2025-06-01' AND '2025-06-30'
)
SELECT
    metric,
    window_1,
    window_2,
    window_1 - window_2 AS delta_abs,
    ROUND(
        (100.0 * (window_1 - window_2) / NULLIF(window_2, 0))::numeric,2) AS delta_pct
FROM (
    SELECT 'cac' AS metric, w1.cac AS window_1, w2.cac AS window_2 FROM window_1 w1, window_2 w2
    UNION ALL
    SELECT 'roas', w1.roas, w2.roas FROM window_1 w1, window_2 w2
) t;
