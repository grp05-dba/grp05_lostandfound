ALTER TABLE claims
ADD COLUMN IF NOT EXISTS contact_preference VARCHAR(10) NOT NULL DEFAULT 'email';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'claims_contact_preference_check'
          AND conrelid = 'claims'::regclass
    ) THEN
        ALTER TABLE claims
        ADD CONSTRAINT claims_contact_preference_check
        CHECK (contact_preference IN ('email', 'phone'));
    END IF;
END $$;
