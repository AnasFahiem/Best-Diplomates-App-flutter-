-- ============================================================
-- Support & Announcement Chat Room – Supabase Migration
-- ============================================================
-- Run this in your Supabase Dashboard → SQL Editor → New Query
-- ============================================================
-- NOTE: If you already ran the previous version, run the
-- "DROP & RECREATE" section below first.
-- ============================================================

-- ── Drop old policies if they exist (safe to run even if they don't) ──
DROP POLICY IF EXISTS "Users can read own messages and announcements" ON public.support_messages;
DROP POLICY IF EXISTS "Users can send their own messages" ON public.support_messages;
DROP POLICY IF EXISTS "Users can mark own messages as read" ON public.support_messages;

-- 1. Create the support_messages table (IF NOT EXISTS so it's safe to re-run)
CREATE TABLE IF NOT EXISTS public.support_messages (
    id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id       UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_role   TEXT NOT NULL CHECK (sender_role IN ('admin', 'user')),
    message_text  TEXT NOT NULL,
    is_announcement BOOLEAN DEFAULT FALSE,
    is_read       BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMPTZ DEFAULT now()
);

-- 2. Add a comment for clarity
COMMENT ON TABLE public.support_messages IS 'Two-way support chat between admin and users, plus global announcements';

-- 3. Create indexes for fast lookups (IF NOT EXISTS)
CREATE INDEX IF NOT EXISTS idx_support_messages_user_id    ON public.support_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_created_at ON public.support_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_messages_announcements ON public.support_messages(is_announcement) WHERE is_announcement = TRUE;

-- 4. Enable Row Level Security
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
--    This app uses CUSTOM authentication (not Supabase Auth),
--    so auth.uid() is not available. We use permissive policies
--    and rely on application-level auth instead.

-- Allow all authenticated/anon users to read messages
CREATE POLICY "Allow read access"
    ON public.support_messages
    FOR SELECT
    USING (true);

-- Allow all authenticated/anon users to insert messages
CREATE POLICY "Allow insert access"
    ON public.support_messages
    FOR INSERT
    WITH CHECK (true);

-- Allow all authenticated/anon users to update messages (for marking as read)
CREATE POLICY "Allow update access"
    ON public.support_messages
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- 6. Enable Realtime for this table (safe to re-run)
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages;
EXCEPTION
    WHEN duplicate_object THEN
        NULL; -- Already added, ignore
END $$;
