// login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'selection_screen.dart'; // للانتقال إليها عند نجاح الدخول
import 'signup_screen.dart'; // للانتقال إليها إذا ضغط المستخدم على "إنشاء حساب"

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 🌟 تم تحديث الـ IP والمنفذ ليتوافق مع سيرفر الـ Flask Backend تماماً
  final String _baseUrl = "https://weigo-be.onrender.com/login";
  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("الرجاء ملء جميع الحقول المطلوبة");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      final result = jsonDecode(response.body);

      // التحقق من حالة النجاح القادمة من السيرفر
      if (response.statusCode == 200 && result['status'] == 'success') {
        _showSnackBar(result['message'] ?? "تم تسجيل الدخول بنجاح",
            isSuccess: true);

        // الانتقال الآمن والمباشر إلى شاشة الاختيار ومسح هذه الشاشة من الذاكرة
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SelectionScreen()),
        );
      } else {
        _showSnackBar(result['message'] ?? "اسم المستخدم أو كلمة المرور خاطئة");
      }
    } catch (e) {
      _showSnackBar(
          "تعذر الاتصال بالسيرفر، تأكد من تشغيل البايثون وثبات الـ IP");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Directionality(
            textDirection:
                TextDirection.rtl, // لتنسيق الحقول والنصوص لغوياً عربياً
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded,
                    size: 80, color: Colors.blue.shade900),
                SizedBox(height: 10),
                Text(
                  "مرحباً بك مجدداً",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900),
                ),
                Text("قم بتسجيل الدخول لمتابعة حسابك",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 35),

                // حقل اسم المستخدم
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "اسم المستخدم (Username)",
                    prefixIcon: Icon(Icons.person, color: Colors.blue.shade900),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 15),

                // حقل كلمة المرور
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور",
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 30),

                // زر تسجيل الدخول التفاعلي مع الـ Loading
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 52),
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("دخول",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                SizedBox(height: 15),

                // زر الانتقال لإنشاء حساب في حال عدم امتلاك حساب
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Text("ليس لديك حساب؟ سجل حسابك الجديد الآن",
                      style: TextStyle(color: Colors.blue.shade700)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
