-- E-commerce Customer Journey Analytics
-- SQLite | Table: customer_events

-- 1. Check the total number of event records
SELECT COUNT(*) AS total_event_records
FROM customer_events;

-- 2. Count unique sessions and users
SELECT
    COUNT(DISTINCT SessionID) AS total_sessions,
    COUNT(DISTINCT UserID) AS total_users
FROM customer_events;

-- 3. Review the available page types
SELECT
    PageType,
    COUNT(*) AS event_count,
    COUNT(DISTINCT SessionID) AS sessions
FROM customer_events
GROUP BY PageType
ORDER BY event_count DESC;

-- 4. Check missing values in important columns
SELECT
    SUM(CASE WHEN SessionID IS NULL OR TRIM(SessionID) = '' THEN 1 ELSE 0 END) AS missing_session_ids,
    SUM(CASE WHEN UserID IS NULL OR TRIM(UserID) = '' THEN 1 ELSE 0 END) AS missing_user_ids,
    SUM(CASE WHEN Timestamp IS NULL OR TRIM(Timestamp) = '' THEN 1 ELSE 0 END) AS missing_timestamps,
    SUM(CASE WHEN PageType IS NULL OR TRIM(PageType) = '' THEN 1 ELSE 0 END) AS missing_page_types
FROM customer_events;

-- 5. Check the date range
SELECT
    MIN(Timestamp) AS first_event,
    MAX(Timestamp) AS last_event
FROM customer_events;
