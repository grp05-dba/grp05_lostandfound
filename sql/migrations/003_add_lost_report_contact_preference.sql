ALTER TABLE lost_reports
    ADD COLUMN IF NOT EXISTS contact_preference VARCHAR(10) NOT NULL DEFAULT 'email';

ALTER TABLE lost_reports
    DROP CONSTRAINT IF EXISTS lost_reports_contact_preference_check;

ALTER TABLE lost_reports
    ADD CONSTRAINT lost_reports_contact_preference_check
    CHECK (contact_preference IN ('email', 'sms'));
