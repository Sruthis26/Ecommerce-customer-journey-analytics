-- Customer and session analysis

-- 1. Users with multiple sessions
WITH user_sessions AS (
    SELECT
        UserID,
        COUNT(DISTINCT SessionID) AS total_sessions,
        MAX(Purchased) AS has_any_purchase
    FROM customer_events
    GROUP BY UserID
)
SELECT
    UserID,
    total_sessions,
    has_any_purchase
FROM user_sessions
WHERE total_sessions > 1
ORDER BY total_sessions DESC, UserID;

-- 2. Summary of one-session and repeat-session users
WITH user_sessions AS (
    SELECT
        UserID,
        COUNT(DISTINCT SessionID) AS total_sessions
    FROM customer_events
    GROUP BY UserID
)
SELECT
    CASE
        WHEN total_sessions = 1 THEN 'One session'
        ELSE 'Multiple sessions'
    END AS user_group,
    COUNT(*) AS users,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM user_sessions), 2) AS user_share_pct
FROM user_sessions
GROUP BY user_group;

-- 3. Average time on page by page type
SELECT
    PageType,
    COUNT(*) AS event_records,
    ROUND(AVG(TimeOnPage_seconds), 2) AS avg_time_on_page_seconds
FROM customer_events
GROUP BY PageType
ORDER BY avg_time_on_page_seconds DESC;

-- 4. Average cart quantity by purchase outcome.
-- This is descriptive, not evidence that cart quantity causes a purchase.
WITH session_summary AS (
    SELECT
        SessionID,
        MAX(ItemsInCart) AS max_items_in_cart,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    purchased,
    COUNT(*) AS total_sessions,
    ROUND(AVG(max_items_in_cart), 2) AS avg_max_items_in_cart
FROM session_summary
GROUP BY purchased
ORDER BY purchased;

-- 5. Purchase outcome by maximum cart quantity
WITH session_summary AS (
    SELECT
        SessionID,
        MAX(ItemsInCart) AS max_items_in_cart,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    max_items_in_cart,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS purchased_sessions,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_pct
FROM session_summary
GROUP BY max_items_in_cart
ORDER BY max_items_in_cart;
