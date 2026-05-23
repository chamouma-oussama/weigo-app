import 'package:flutter/material.dart';
import 'input_screen.dart'; // شاشة التنبؤ
import 'tracking_screen.dart'; // شاشة التتبع
import 'welcome_screen.dart'; // استيراد شاشة الترحيب للعودة إليها عند تسجيل الخروج

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Your Path"),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),

      // 👈 إضافة القائمة الجانبية (Drawer) المدمج بها زر تسجيل الخروج
      drawer: Drawer(
        child: Directionality(
          textDirection: TextDirection
              .rtl, // تنسيق القائمة من اليمين للياسر ليتناسب مع اللغة العربية والإنجليزية معاً
          child: Column(
            children: [
              // رأس القائمة الجانبية بتصميم متناسق مع ألوان التطبيق
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade600],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_graph_rounded,
                          size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "WEIGO",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ),

              // خيار سريع للانتقال لشاشة التنبؤ
              ListTile(
                leading: Icon(Icons.psychology_outlined,
                    color: Colors.blue.shade800),
                title: Text("Prediction Path",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context); // إغلاق الـ Drawer أولاً
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => InputScreen()));
                },
              ),

              // خيار سريع للانتقال لشاشة التتبع
              ListTile(
                leading: Icon(Icons.fact_check_outlined,
                    color: Colors.green.shade700),
                title: Text("Tracking Path",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context); // إغلاق الـ Drawer أولاً
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrackingScreen()));
                },
              ),

              Divider(), // خط فاصل جمالي

              Spacer(), // لدفع زر تسجيل الخروج إلى أسفل القائمة بشكل أنيق وجذاب

              // 🔴 زر تسجيل الخروج الفعلي
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Logout",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context); // إغلاق القائمة الجانبية

                  // تنظيف الذاكرة والعودة إلى شاشة الترحيب لمنع المستخدم من العودة للخلف بزر الهاتف
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الخيار الأول: مسار التنبؤ والذكاء الاصطناعي
            _buildOptionCard(
              context,
              title: "Prediction Path",
              desc: "Analyze your lifestyle & AI prediction",
              icon: Icons.psychology_outlined,
              color: Colors.blue.shade800,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InputScreen()));
              },
            ),

            SizedBox(height: 25),

            // الخيار الثاني: مسار التتبع والخطة اليومية
            _buildOptionCard(
              context,
              title: "Tracking Path",
              desc: "View your daily plan & checklists",
              icon: Icons.fact_check_outlined,
              color: Colors.green.shade700,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TrackingScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // الـ Widget المساعد الخاص بك بدون أي تعديل خارجي ليحافظ على جماليته
  Widget _buildOptionCard(BuildContext context,
      {required String title,
      required String desc,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 40), // حافظنا على المسافة الأصلية
                  Text(
                    desc,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
