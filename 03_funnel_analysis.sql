-- Funnel analysis
-- PageType values in this dataset:
-- home, product_page, cart, checkout, confirmation

-- 1. Count sessions reaching each funnel stage.
-- DISTINCT prevents multiple event rows from counting the same session twice.
WITH funnel_counts AS (
    SELECT
        PageType,
        COUNT(DISTINCT SessionID) AS sessions
    FROM customer_events
    GROUP BY PageType
)
SELECT
    PageType,
    sessions
FROM funnel_counts
ORDER BY CASE PageType
    WHEN 'home' THEN 1
    WHEN 'product_page' THEN 2
    WHEN 'cart' THEN 3
    WHEN 'checkout' THEN 4
    WHEN 'confirmation' THEN 5
    ELSE 6
END;

-- 2. Calculate the drop-off between consecutive stages.
WITH funnel_counts AS (
    SELECT
        COUNT(DISTINCT CASE WHEN PageType = 'home' THEN SessionID END) AS home_sessions,
        COUNT(DISTINCT CASE WHEN PageType = 'product_page' THEN SessionID END) AS product_sessions,
        COUNT(DISTINCT CASE WHEN PageType = 'cart' THEN SessionID END) AS cart_sessions,
        COUNT(DISTINCT CASE WHEN PageType = 'checkout' THEN SessionID END) AS checkout_sessions,
        COUNT(DISTINCT CASE WHEN PageType = 'confirmation' THEN SessionID END) AS confirmation_sessions
    FROM customer_events
),
stages AS (
    SELECT 1 AS stage_order, 'home' AS stage, home_sessions AS sessions FROM funnel_counts
    UNION ALL
    SELECT 2, 'product_page', product_sessions FROM funnel_counts
    UNION ALL
    SELECT 3, 'cart', cart_sessions FROM funnel_counts
    UNION ALL
    SELECT 4, 'checkout', checkout_sessions FROM funnel_counts
    UNION ALL
    SELECT 5, 'confirmation', confirmation_sessions FROM funnel_counts
),
stage_comparison AS (
    SELECT
        stage,
        sessions,
        LEAD(sessions) OVER (ORDER BY stage_order) AS next_stage_sessions
    FROM stages
)
SELECT
    stage,
    sessions,
    next_stage_sessions,
    ROUND(
        100.0 * (sessions - next_stage_sessions) / NULLIF(sessions, 0),
        2
    ) AS drop_off_pct
FROM stage_comparison
ORDER BY CASE stage
    WHEN 'home' THEN 1
    WHEN 'product_page' THEN 2
    WHEN 'cart' THEN 3
    WHEN 'checkout' THEN 4
    WHEN 'confirmation' THEN 5
    ELSE 6
END;

-- 3. Monthly session and purchase counts
WITH session_summary AS (
    SELECT
        SessionID,
        substr(MIN(Timestamp), 1, 7) AS session_month,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    session_month,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS purchased_sessions,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_pct
FROM session_summary
GROUP BY session_month
ORDER BY session_month;
