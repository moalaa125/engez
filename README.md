# Engez (إنجز)

تطبيق Flutter لطلب الأكل والمشروبات مقدمًا من الكافيهات والمطاعم القريبة، والدفع أونلاين، واستلام الطلب جاهز من غير انتظار في الطابور.

##  الفكرة

المستخدم يفتح التطبيق، يشوف الكافيهات/المطاعم القريبة منه بناءً على موقعه، يختار الأوردر ويدفعه أونلاين، وبعدين يوصله إشعار لما الطلب يبقى جاهز للاستلام.

##  المميزات الحالية

- **تسجيل الدخول (Auth)**
  - تسجيل دخول عن طريق رقم الموبايل المصري + OTP عبر Firebase Phone Auth
  - تسجيل دخول عن طريق Google (Google Sign-In)
- **تحديد الموقع (Location)**
  - جلب الموقع الحالي للمستخدم وتحويله لعنوان مقروء (Geocoding)
  - التعامل مع كل حالات صلاحيات الموقع (مرفوضة، مغلقة، مرفوضة نهائيًا)
- **الفئات (Categories)**
  - اختيار فئة من قائمة تصنيفات الأماكن/الأصناف
- **واجهة المستخدم**
  - تصميم متجاوب لكل أحجام الشاشات (flutter_screenutil)
  - ثيم بألوان مخصصة ودعم خطوط عربية (Google Fonts - Cairo)
  - مكونات UI جاهزة قابلة لإعادة الاستخدام (أزرار، كروت، حقول إدخال، شريط تنقل سفلي، كاروسيل عروض...)

## 🛠️ التقنيات المستخدمة

| التقنية | الاستخدام |
|---|---|
| Flutter | إطار العمل الأساسي |
| Firebase Core / Firebase Auth | تسجيل الدخول والمصادقة |
| Google Sign-In | تسجيل الدخول بجوجل |
| flutter_bloc (Cubit) | إدارة الحالة (State Management) |
| equatable | مقارنة الحالات (States) بكفاءة |
| flutter_screenutil | تصميم متجاوب (Responsive UI) |
| google_fonts | خطوط مخصصة (Cairo) |
| geolocator / geocoding | تحديد الموقع الجغرافي وتحويله لعنوان |
| google_nav_bar | شريط التنقل السفلي |
| carousel_slider | عرض السلايدر/العروض |

## 📁 هيكل المشروع

```
lib/
├── main.dart                      # نقطة تشغيل التطبيق وتهيئة Firebase
├── firebase_options.dart          # إعدادات Firebase (مولدة تلقائيًا)
├── constants/
│   └── my_colors.dart             # الألوان الأساسية للتطبيق
├── core/
│   └── theme/
│       └── app_theme.dart         # الثيم العام (ألوان، خطوط، أزرار، حقول إدخال)
├── features/
│   ├── auth/
│   │   ├── manager/                       # AuthCubit + AuthState
│   │   └── presentation/screens/          # شاشات تسجيل الدخول والصفحة الرئيسية
│   ├── category/                          # SelectCategoryCubit + State
│   └── location/
│       └── manger/                        # LocationCubit + State
└── widgets/                        # مكونات UI قابلة لإعادة الاستخدام
    ├── custom_button.dart
    ├── custom_icon_button.dart
    ├── custom_image.dart
    ├── custom_offer_section.dart
    ├── custom_text_bubble.dart
    ├── custom_text_field.dart
    ├── category_list.dart
    ├── menu_item_card.dart
    ├── nav_bar.dart
    └── place_card.dart
```

## ⚙️ الإعداد والتشغيل

### المتطلبات
- Flutter SDK مثبت على جهازك
- حساب Firebase مربوط بالمشروع (لازم ملف `firebase_options.dart` يكون مظبوط على مشروعك في Firebase Console)
- تفعيل **Phone Authentication** و **Google Sign-In** من لوحة تحكم Firebase Authentication

### خطوات التشغيل

```bash
# تثبيت الحزم
flutter pub get

# تشغيل التطبيق
flutter run
```

> ملاحظة: تأكد إن ملف `firebase_options.dart` متولد من مشروعك الخاص على Firebase (عن طريق `flutterfire configure`)، مش الملف الموجود في المستودع كما هو، لأنه مرتبط بمشروع Firebase بعينه.

## 🗺️ خطوات قادمة (مقترحة)

- شاشات: عرض المنيو، السلة والدفع، تتبع الطلب، وتاريخ الطلبات
- ربط الدفع الإلكتروني (Visa)
- ربط قائمة الأماكن الحقيقية بدل البيانات الوهمية الحالية
- الإشعارات (Push Notifications) عند جهوزية الطلب

---
تم توليد هذا الملف تلقائيًا بناءً على الكود الحالي للمشروع.