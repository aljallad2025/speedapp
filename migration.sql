-- SPEED Mobile App - Migration Script
-- شغّلها بالـ ERP: psql $DATABASE_URL -f migration.sql
-- كل الجمل IF NOT EXISTS، آمنة تتكرر بدون مشاكل

-- 1) لازم يكون فيه عمود listing_type على جدول cars (rent / sale / both)
ALTER TABLE cars ADD COLUMN IF NOT EXISTS listing_type TEXT DEFAULT 'rent';
ALTER TABLE cars ADD COLUMN IF NOT EXISTS sale_price NUMERIC;

-- 2) جدول طلبات الحجز من الموبايل (الموظف يراجعها ويحوّلها لعقد فعلي)
CREATE TABLE IF NOT EXISTS booking_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  car_id UUID NOT NULL REFERENCES cars(id),
  user_id UUID NOT NULL,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending | confirmed | rejected | converted
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3) جدول المفضلة (لو غير موجود من نسخة Ionic القديمة)
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  car_id UUID NOT NULL REFERENCES cars(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, car_id)
);

-- 4) جدول التقييمات (لو غير موجود من نسخة Ionic القديمة)
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  car_id UUID NOT NULL REFERENCES cars(id),
  user_id UUID NOT NULL,
  rating NUMERIC NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ⚠️ لو جدول reviews / favorites موجود مسبقاً من نسخة Ionic بأسماء أعمدة مختلفة
-- خبرني بأسماء الأعمدة الحقيقية بدل ما أعمل تكرار/تعارض
