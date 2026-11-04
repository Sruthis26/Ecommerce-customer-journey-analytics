-- Conversion analysis
-- Purchased is a session-level outcome repeated on the event rows.
-- Use DISTINCT SessionID so each session is counted only once.

-- 1. Overall session conversion rate
WITH session_summary AS (
    SELECT
        SessionID,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    COUNT(*) AS total_sessions,
    SUM(purchased) AS purchased_sessions,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_pct
FROM session_summary;

-- 2. Conversion rate by device
WITH session_summary AS (
    SELECT
        SessionID,
        MAX(DeviceType) AS DeviceType,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    DeviceType,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS purchased_sessions,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_pct
FROM session_summary
GROUP BY DeviceType
ORDER BY conversion_rate_pct DESC;

-- 3. Conversion rate by referral source
WITH session_summary AS (
    SELECT
        SessionID,
        MAX(ReferralSource) AS ReferralSource,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    ReferralSource,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS purchased_sessions,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_pct
FROM session_summary
GROUP BY ReferralSource
ORDER BY conversion_rate_pct DESC;

-- 4. Conversion rate by country
WITH session_summary AS (
    SELECT
        SessionID,
        MAX(Country) AS Country,
        MAX(Purchased) AS purchased
    FROM customer_events
    GROUP BY SessionID
)
SELECT
    Country,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS purchased_sessions,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS conversion_rate_pct
FROM session_summary
GROUP BY Country
ORDER BY conversion_rate_pct DESC;
