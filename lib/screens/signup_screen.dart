// signup_screen.dart
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
  final String _baseUrl = "https://weigo-be.onrender.com/register";

  Future<void> _signup() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar("Please fill in all required fields");
      return;
    }
    setState(() => _isLoading = true);
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
      if ((response.statusCode == 200 || response.statusCode == 201) && result['status'] == 'success') {
        _showSnackBar(result['message'] ?? "Account created successfully", isSuccess: true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        _showSnackBar(result['message'] ?? "The username is already in use or there are missing fields");
      }
    } catch (e) {
      _showSnackBar("Please try again, unable to connect to the server");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade100, // خلفية متناسقة مع شاشة الدخول
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الأيقونة الدائرية العلوية بألوانك الزرقاء لشاشة التسجيل
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.person_add_alt_1_rounded, size: 40, color: Colors.blue.shade900),
                  ),
                  SizedBox(height: 20),
                  Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                  Text("Fill in the details to get started", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 25),

                  // حقل الاسم الأول
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade900),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 15),

                  // حقل اسم العائلة
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade900),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 15),

                  // حقل اسم المستخدم
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.account_circle_outlined, color: Colors.blue.shade900),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 15),

                  // حقل كلمة المرور
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade900),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 25),

                  // زر إنشاء الحساب التفاعلي
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 52),
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                  SizedBox(height: 20),

                  // رابط العودة لشاشة الدخول
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                    child: Text("Already have an account? Login", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}