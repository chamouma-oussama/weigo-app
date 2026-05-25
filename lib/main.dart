import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // استيراد الصفحة الترحيبية من مجلدها الصحيح

// 🌟 الـ Notifier العالمي المسؤول عن مراقبة وضع الألوان في التطبيق بأكمله
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(WeightLossApp());
}

class WeightLossApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 🌟 نستخدم ValueListenableBuilder ليقوم بإعادة بناء التطبيق فوراً عند ضغط زر التبديل
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Weight Loss Predictor',
          debugShowCheckedModeBanner: false,

          // ☀️ 1. إعدادات الوضع الفاتح (Light Mode) المحسنة من كودك الأصلي
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            fontFamily: 'Cairo',
            
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),

          // 🌙 2. إعدادات الوضع الليلي الفخم (Dark Mode) المتوافقة مع الحقول والأزرار
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
              background: const Color(0xFF0F172A), // لون خلفية ليلي احترافي (Slate Dark)
              surface: const Color(0xFF1E293B),    // لون البطاقات والقوائم في الليل
            ),
            fontFamily: 'Cairo',
            
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E293B), // حقول نصية داكنة تناسب الليل
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),

          // ⚙️ ربط التطبيق بالـ Notifier ليتغير يدوياً عبر الـ Drawer
          themeMode: currentMode, 
          
          home: WelcomeScreen(),
        );
      },
    );
  }
}