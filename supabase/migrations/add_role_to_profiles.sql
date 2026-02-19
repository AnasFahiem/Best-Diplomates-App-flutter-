-- ============================================================
-- Add role column to profiles table – Supabase Migration
-- ============================================================

-- 1. Add 'role' column to 'public.profiles' table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- 2. Update the specific admin user
-- Replace 'admin@futurediplomates.com' with the actual email if different
UPDATE public.profiles 
SET role = 'admin' 
WHERE email = 'admin@futurediplomates.com';

-- 3. (Optional) Create an index on the role column for faster lookups if you have many users
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
