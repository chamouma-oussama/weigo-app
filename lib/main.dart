import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // استيراد الصفحة الترحيبية من مجلدها الصحيح

void main() {
  runApp(WeightLossApp());
}

class WeightLossApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Loss Predictor',
      debugShowCheckedModeBanner: false,

      // إعدادات الثيم (التصميم العام الموحد للتطبيق)
      theme: ThemeData(
        useMaterial3: true, // تفعيل نظام التصميم الأحدث من جوجل
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // يعمل الخط عند تعريفه في pubspec.yaml

        // تحسين مظهر الأزرار بشكل عام في التطبيق ليصبح متناسقاً
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // تحسين مظهر الحقول النصية (Inputs) لتسجيل الدخول والبيانات
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

      // الصفحة التي يبدأ منها التطبيق دائماً عند التشغيل
      home: WelcomeScreen(),
    );
  }
}
