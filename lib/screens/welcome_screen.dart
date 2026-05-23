import 'package:flutter/material.dart';
import 'login_screen.dart'; // استيراد شاشة تسجيل الدخول الجديدة
import 'signup_screen.dart'; // استيراد شاشة إنشاء الحساب الجديدة

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph_rounded, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "WEIGO",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            SizedBox(height: 10),
            Text(
              "Measure Your Future",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 50),

            // 1. زر تسجيل الدخول الأساسي
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              child: Text(
                "LOG IN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 15),

            // 2. زر إنشاء حساب جديد (تمت إضافته بتصميم مفرغ متناسق)
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "SIGN UP",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 40),
            Text("Or connect via",
                style: TextStyle(color: Colors.white60, fontSize: 14)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialIcon(Icons.facebook, Colors.white),
                SizedBox(width: 20),
                _socialIcon(Icons.email_outlined, Colors.white),
                SizedBox(width: 20),
                _socialIcon(Icons.g_mobiledata_rounded, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
        color: const Color.fromARGB(255, 244, 242, 242).withOpacity(0.1),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
