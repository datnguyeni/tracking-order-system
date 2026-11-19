-- PICKING meant awaiting carrier pickup; consolidate it into CONFIRMED.
-- Keep V1 unchanged so existing Flyway checksums remain valid.
UPDATE shipments SET status = 'CONFIRMED' WHERE status = 'PICKING';
UPDATE tracking_logs SET from_status = 'CONFIRMED' WHERE from_status = 'PICKING';
UPDATE tracking_logs SET to_status = 'CONFIRMED' WHERE to_status = 'PICKING';

ALTER TABLE shipments
    DROP CHECK CK_shipments_status,
    ADD CONSTRAINT CK_shipments_status CHECK (status IN ('PENDING', 'CONFIRMED', 'SHIPPING', 'DELIVERED', 'FAILED', 'REATTEMPT', 'RETURNING', 'RETURNED'));

ALTER TABLE tracking_logs
    DROP CHECK CK_tracking_logs_from,
    DROP CHECK CK_tracking_logs_to,
    ADD CONSTRAINT CK_tracking_logs_from CHECK (from_status IS NULL OR from_status IN ('PENDING', 'CONFIRMED', 'SHIPPING', 'DELIVERED', 'FAILED', 'REATTEMPT', 'RETURNING', 'RETURNED')),
    ADD CONSTRAINT CK_tracking_logs_to CHECK (to_status IN ('PENDING', 'CONFIRMED', 'SHIPPING', 'DELIVERED', 'FAILED', 'REATTEMPT', 'RETURNING', 'RETURNED'));
