import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 🌟 تم تحديث الـ IP إلى 38 وتعديل المسار ليتطابق مع البايثون تماماً
  final String _baseUrl = "https://weigo-be.onrender.com/register";

  Future<void> _signup() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
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
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "username": _usernameController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      final result = jsonDecode(response.body);

      // 🌟 تم تعديل الفحص ليتوافق مع الاستجابة المتوقعة (200 أو 201) لضمان العبور بأمان
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          result['status'] == 'success') {
        _showSnackBar(result['message'] ?? "تم إنشاء الحساب بنجاح",
            isSuccess: true);

        // بعد نجاح التسجيل، نقله تلقائياً لشاشة تسجيل الدخول
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showSnackBar(result['message'] ??
            "اسم المستخدم مستخدم مسبقاً أو هناك حقول ناقصة");
      }
    } catch (e) {
      _showSnackBar(
          "تعذر الاتصال بالسيرفر المحلي، تأكد من مطابقة الـ IP وتشغيل البايثون");
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
        title: Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    size: 80, color: Colors.blue.shade900),
                SizedBox(height: 10),
                Text(
                  "إنشاء حساب جديد",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900),
                ),
                Text("سجل بياناتك للانضمام إلى منصة WeiGo",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 35),

                // حقل الاسم الأول
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: "الاسم الأول",
                    prefixIcon:
                        Icon(Icons.person_outline, color: Colors.blue.shade900),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 15),

                // حقل اسم العائلة
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: "اللقب (اسم العائلة)",
                    prefixIcon:
                        Icon(Icons.person_outline, color: Colors.blue.shade900),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 15),

                // حقل اسم المستخدم
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "اسم المستخدم (Username)",
                    prefixIcon:
                        Icon(Icons.account_circle, color: Colors.blue.shade900),
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
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.blue.shade900),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 30),

                // زر إنشاء الحساب الفعلي
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 52),
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("إنشاء الحساب",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                SizedBox(height: 15),

                // زر العودة السريعة لشاشة الدخول
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text("لديك حساب بالفعل؟ سجل دخولك الآن",
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
