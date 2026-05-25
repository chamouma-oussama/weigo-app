// login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'selection_screen.dart'; 
import 'signup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final String _baseUrl = "https://weigo-be.onrender.com/login";

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Please fill in all required fields");
      return;
    }
    setState(() => _isLoading = true);
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
      if (response.statusCode == 200 && result['status'] == 'success') {
        _showSnackBar(result['message'] ?? "Login successful", isSuccess: true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectionScreen()));
      } else {
        _showSnackBar(result['message'] ?? "Incorrect username or password");
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
        color: Colors.grey.shade100, // خلفية رمادية فاتحة ومريحة للعين
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), // حواف دائرية للبطاقة
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الأيقونة الدائرية العلوية بألوانك الزرقاء
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.home_rounded, size: 40, color: Colors.blue.shade900),
                  ),
                  SizedBox(height: 20),
                  Text("Welcome Back", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                  Text("Sign in with your name or email", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 25),

                  // حقل اسم المستخدم
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person, color: Colors.blue.shade900),
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
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 25),

                  // زر تسجيل الدخول التفاعلي بالأزرق الساكن
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 52),
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                  SizedBox(height: 20),

                  // رابط إنشاء الحساب
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                    child: Text("Don't have an account? Sign up", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
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