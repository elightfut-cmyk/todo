-- ==========================================================
-- جدول سهم مسار اليوم (Day Timeline Table) في Supabase PostgreSQL
-- ==========================================================

-- 1. إنشاء جدول محطات سهم اليوم
CREATE TABLE IF NOT EXISTS public.day_timeline (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    time_range TEXT NOT NULL,
    title TEXT NOT NULL,
    notes TEXT DEFAULT '',
    category TEXT DEFAULT 'general',
    completed BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. إنشاء الفهارس لتحسين وسرعة الأداء
CREATE INDEX IF NOT EXISTS idx_day_timeline_user_id ON public.day_timeline(user_id);
CREATE INDEX IF NOT EXISTS idx_day_timeline_sort_order ON public.day_timeline(user_id, sort_order);

-- 3. تفعيل نظام حماية البيانات (Row Level Security)
ALTER TABLE public.day_timeline ENABLE ROW LEVEL SECURITY;

-- 4. سياسات الصلاحيات (كل مستخدم يرى ويعدل محطاته فقط)
DROP POLICY IF EXISTS "Users can view their own timeline items" ON public.day_timeline;
CREATE POLICY "Users can view their own timeline items" 
ON public.day_timeline FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own timeline items" ON public.day_timeline;
CREATE POLICY "Users can insert their own timeline items" 
ON public.day_timeline FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own timeline items" ON public.day_timeline;
CREATE POLICY "Users can update their own timeline items" 
ON public.day_timeline FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id) 
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own timeline items" ON public.day_timeline;
CREATE POLICY "Users can delete their own timeline items" 
ON public.day_timeline FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- 5. تفعيل التحديث اللحظي (Realtime)
ALTER PUBLICATION supabase_realtime ADD TABLE public.day_timeline;
