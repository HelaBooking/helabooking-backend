-- Migration script to add new columns to existing tables
-- Run this script if you have existing data in your database

-- User Service: Add role and active columns with defaults for existing data
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'USER';
ALTER TABLE users ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;

-- Update existing null values
UPDATE users SET role = 'USER' WHERE role IS NULL;
UPDATE users SET active = true WHERE active IS NULL;

-- Make columns not nullable after setting defaults
ALTER TABLE users ALTER COLUMN role SET NOT NULL;
ALTER TABLE users ALTER COLUMN active SET NOT NULL;

-- Event Service: Add new metadata columns
ALTER TABLE events ADD COLUMN IF NOT EXISTS description VARCHAR(2000);
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue VARCHAR(255);
ALTER TABLE events ADD COLUMN IF NOT EXISTS agenda VARCHAR(5000);
ALTER TABLE events ADD COLUMN IF NOT EXISTS categories VARCHAR(255);
ALTER TABLE events ADD COLUMN IF NOT EXISTS end_date TIMESTAMP;
ALTER TABLE events ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN DEFAULT false;
ALTER TABLE events ADD COLUMN IF NOT EXISTS recurrence_pattern VARCHAR(50);
ALTER TABLE events ADD COLUMN IF NOT EXISTS is_multi_session BOOLEAN DEFAULT false;
ALTER TABLE events ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'DRAFT';
ALTER TABLE events ADD COLUMN IF NOT EXISTS published_at TIMESTAMP;

-- Update existing null values for events
UPDATE events SET is_recurring = false WHERE is_recurring IS NULL;
UPDATE events SET is_multi_session = false WHERE is_multi_session IS NULL;
UPDATE events SET status = 'DRAFT' WHERE status IS NULL;

-- Booking Service: Add ticket type and pricing columns
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS ticket_type VARCHAR(50) DEFAULT 'PAID';
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS total_price DECIMAL(10, 2);

-- Update existing null values for bookings
UPDATE bookings SET ticket_type = 'PAID' WHERE ticket_type IS NULL;

-- Ticketing Service: Add QR code and barcode columns
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS qr_code VARCHAR(255) UNIQUE;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS barcode VARCHAR(255) UNIQUE;

-- Generate QR codes and barcodes for existing tickets (placeholder values)
UPDATE tickets SET qr_code = CONCAT('QR-', ticket_number, '-', SUBSTRING(MD5(RANDOM()::text), 1, 8)) WHERE qr_code IS NULL;
UPDATE tickets SET barcode = CONCAT('BC-', REPLACE(ticket_number, '-', ''), EXTRACT(EPOCH FROM NOW())::bigint) WHERE barcode IS NULL;

COMMIT;
