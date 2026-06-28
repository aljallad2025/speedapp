# SPEED Car Rental - Flutter App (من الصفر)

## شغال حالياً
- هيكل المشروع + pubspec.yaml + ثيم أحمر/أسود
- اتصال Supabase (لازم تعبي URL + anon key)
- **Splash → MainShell (Bottom Nav: السيارات / المفضلة / حجوزاتي / حسابي)**
- **Fleet**: فلتر إيجار/بيع
- **Car Detail**: زر مفضلة (heart)، قسم تقييمات، أزرار حجز/اتصال/واتساب حسب نوع السيارة
- **Login / Register**: مرتبطة بـ Supabase Auth + جدول `users`
- **Booking Screen**: تاريخ بداية/نهاية + حساب السعر + إرسال طلب حجز (يدخل بحالة pending)
- **My Bookings**: قائمة طلبات الحجز وحالتها
- **Favorites**: قلب بالتفاصيل + شاشة قائمة المفضلة
- **Profile**: بيانات المستخدم + تسجيل خروج
- Guest Mode: تصفح بدون تسجيل دخول، الحجز/المفضلة بيطلبوا تسجيل دخول

## لازم تسويه قبل ما يبني صحيح

1. **`lib/core/supabase_config.dart`** → عبّي `supabaseUrl` و `supabaseAnonKey`

2. **`lib/screens/fleet/car_detail_screen.dart`** → غيّر `kSalesWhatsappNumber` و `kSalesPhoneNumber`

3. **شغّل `migration.sql` على قاعدة البيانات:**
   ```bash
   psql $DATABASE_URL -f migration.sql
   ```
   هذا يضيف:
   - عمود `listing_type` و `sale_price` على جدول `cars` (لو غير موجودين)
   - جدول `booking_requests` (جديد كامل)
   - جدول `favorites` (لو غير موجود من نسخة Ionic)
   - جدول `reviews` (لو غير موجود من نسخة Ionic)

   ⚠️ **مهم:** لو `favorites` أو `reviews` موجودين أصلاً من نسخة Ionic بأسماء
   أعمدة مختلفة عن اللي بالسكربت، خبرني بالأعمدة الحقيقية عشان أصحح
   `lib/services/favorite_service.dart` و `lib/services/review_service.dart`.

4. **جدول `users`** — تأكد فيه أعمدة `full_name`, `email`, `phone` (أو عدّل
   `lib/models/app_user_model.dart` و `lib/services/auth_service.dart` لو
   الأسماء مختلفة)

## الخطوات الجاية
- [ ] ربط `codemagic.yaml` بمشروع فعلي على codemagic.io وأول build تجريبي
- [ ] Chat / Support (لو تبيها بالنسخة الجاية)
- [ ] شاشة Settings (تبديل لغة عربي/إنجليزي فعلي - حالياً locale ثابت 'ar')
- [ ] صفحة Onboarding (اختياري)
- [ ] ربط لوحة التحكم بحيث الموظف يشوف `booking_requests` الجديدة ويحوّلها لعقد فعلي
      (نفس مبدأ Quotation → Convert to Invoice)

## البناء على Codemagic
الملف `codemagic.yaml` بجذر المشروع جاهز لبناء APK مباشرة، لازم تربطه بمشروع
على codemagic.io ويقرأ الملف تلقائياً من الريبو.

