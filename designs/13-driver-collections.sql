-- 13 - Driver collections (migration 0098): the driver_collections table.
--
-- The cash a driver types at delivery (or with Finance -> Collect payment) is now only NOTED here;
-- the office records it on Cash Flow -> Collections to check, and only then is it a Payment In
-- (Day Book, bill, customer balance). Needed in BOTH business databases. Additive: one new table,
-- three indexes. Nothing existing is changed.
--
-- Run BEFORE (or right after) the API build with this change goes live, on both databases:
--
--   npx wrangler d1 execute rrp-erp     --remote --env production --file docs/multi-business/fly-ash-go-live/13-driver-collections.sql
--   npx wrangler d1 execute rrp-fly-ash --remote --env production --file docs/multi-business/fly-ash-go-live/13-driver-collections.sql
--
-- Then record it on rrp-erp:
--   INSERT OR IGNORE INTO _drizzle_migrations_log (tag, applied_at) VALUES ('0098_driver_collections', strftime('%s','now') * 1000);
-- Running this file twice fails on "table already exists" and changes nothing.
-- Until the table exists, completing a delivery WITH an amount collected fails - run it first.

CREATE TABLE `driver_collections` (
	`id` text PRIMARY KEY NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	`source` text DEFAULT 'DELIVERY' NOT NULL,
	`job_type` text,
	`job_id` text,
	`job_no` text,
	`customer_id` text,
	`customer_name` text,
	`driver_id` text NOT NULL,
	`driver_name` text,
	`duty_session_id` text,
	`date` integer NOT NULL,
	`amount` real NOT NULL,
	`payment_mode` text DEFAULT 'Cash' NOT NULL,
	`reference_no` text,
	`notes` text,
	`status` text DEFAULT 'PENDING' NOT NULL,
	`payment_id` text,
	`recorded_amount` real,
	`decided_by` text,
	`decided_by_name` text,
	`decided_at` integer,
	`decision_note` text,
	`edited_at` integer
);

CREATE INDEX `idx_driver_collections_status` ON `driver_collections` (`status`);
CREATE INDEX `idx_driver_collections_driver_date` ON `driver_collections` (`driver_id`,`date`);
CREATE INDEX `idx_driver_collections_job` ON `driver_collections` (`job_id`);
