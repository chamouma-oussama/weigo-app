import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💾 استيراد مكتبة الحفظ والقراءة
import '../main.dart'; // 🌟 استيراد ملف main.dart للوصول إلى themeNotifier العالمي
import 'input_screen.dart'; // شاشة التنبؤ
import 'tracking_screen.dart'; // شاشة التتبع
import 'welcome_screen.dart'; // استيراد شاشة الترحيب للعودة إليها عند تسجيل الخروج

// --- 🎯 شاشة About المدمجة باللغة الإنجليزية ---
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("About Weigo",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 70,
                color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Weigo App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              "Version 1.0.0 (Release)",
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildAboutCard(
              title: "Project Overview",
              icon: Icons.info_outline_rounded,
              isDarkMode: isDarkMode,
              content:
                  "Weigo is an advanced, data-driven mobile application designed as a university graduation thesis. The application aims to predict weight loss success rates by combining modern mobile development with Machine Learning capabilities.",
            ),
            _buildAboutCard(
              title: "Intelligence & Analytics",
              icon: Icons.analytics_outlined,
              isDarkMode: isDarkMode,
              content:
                  "By utilizing a trained Random Forest predictive model, Weigo processes key lifestyle factors, daily behavior metrics, and commitment data to deliver intelligent, actionable feedback to users on their health journeys.",
            ),
            _buildAboutCard(
              title: "Core Architecture",
              icon: Icons.code_rounded,
              isDarkMode: isDarkMode,
              content:
                  "• Frontend: Cross-platform development via Flutter & Dart\n"
                  "• Backend: Python-based Flask API deployed securely on cloud\n"
                  "• Machine Learning: Random Forest Classifier (Scikit-Learn)",
            ),
            _buildAboutCard(
              title: "Academic Credits",
              icon: Icons.school_outlined,
              isDarkMode: isDarkMode,
              content: "• Supervised by:Mrs. Hamdani Nesrine\n"
                  "• Developed by: Abdessalam Oussama Chamouma/Mohamed Fellah\n"
                  "• Academic Year: 2025 - 2026",
            ),
            const SizedBox(height: 20),
            Text(
              "© 2026 Weigo Project. All Rights Reserved.",
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard({
    required String title,
    required IconData icon,
    required String content,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 20,
                  color:
                      isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode ? Colors.blue.shade400 : Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 0.7),
          ),
          Text(
            content,
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDarkMode ? Colors.grey.shade300 : Colors.black87),
          ),
        ],
      ),
    );
  }
}

// --- 🌟 شاشة الاختيار الرئيسية المحدثة (StatefulWidget لديناميكية البيانات) ---
class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String _userInitials = "U";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 💾 دالة جلب بيانات المستخدم المسجل من الـ SharedPreferences تلقائياً
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 🛠️ تأكد من استخدام نفس الـ keys التي قمت بحفظ الاسم والإيميل بها عند التسجيل (مثلاً 'username' و 'email')
      _userName = prefs.getString('username') ?? "Guest User";
      _userEmail = prefs.getString('email') ?? "no-email@weigo.com";

      // استخراج أول حرفين من الاسم بشكل ذكي لتكون كرمز شخصي
      if (_userName.isNotEmpty && _userName != "Guest User") {
        List<String> words = _userName.trim().split(' ');
        if (words.length > 1) {
          _userInitials = (words[0][0] + words[1][0]).toUpperCase();
        } else {
          _userInitials = words[0][0].toUpperCase();
        }
      } else {
        _userInitials = "U";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("Choose Your Path",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      // 👤 القائمة الجانبية الاحترافية الديناميكية
      drawer: Drawer(
        backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[50],
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    isDarkMode ? Colors.blue.shade700 : Colors.white,
                child: Text(
                  _userInitials, // 🔥 يعرض الحروف الأولى من اسم المستخدم الحالي ديناميكياً
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blue.shade700,
                  ),
                ),
              ),
              accountName: Text(
                _userName, // 🔥 يعرض اسم المستخدم المسجل حالياً ديناميكياً
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5),
              ),
              accountEmail: Text(
                _userEmail, // 🔥 يعرض بريد المستخدم المسجل حالياً ديناميكياً
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade800,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),

            // محتويات الـ Drawer
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildSectionTitle("Navigation", isDarkMode),
                  ListTile(
                    leading: Icon(Icons.psychology_outlined,
                        color: isDarkMode
                            ? Colors.blue.shade400
                            : Colors.blue.shade800),
                    title: const Text("Prediction Path",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InputScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.fact_check_outlined,
                        color: isDarkMode
                            ? Colors.green.shade400
                            : Colors.green.shade700),
                    title: const Text("Tracking Path",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrackingScreen()));
                    },
                  ),

                  const Divider(),
                  _buildSectionTitle("Project Info", isDarkMode),

                  // 🎯 شاشة About Weigo محفوظة ومتاحة فقط هنا في الـ Drawer
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded,
                        color: isDarkMode
                            ? Colors.purple.shade400
                            : Colors.purple.shade700),
                    title: const Text("About Weigo (À Propos)",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutScreen()));
                    },
                  ),

                  const Divider(),
                  _buildSectionTitle("Preferences", isDarkMode),

                  // زر التبديل للوضع الليلي
                  SwitchListTile(
                    title: const Text("Dark Mode",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    secondary: Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDarkMode ? Colors.amber : Colors.blueGrey,
                    ),
                    value: isDarkMode,
                    onChanged: (bool value) {
                      themeNotifier.value =
                          value ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            // زر تسجيل الخروج في أسفل القائمة
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 💻 واجهة شاشة الاختيار الرئيسية (تم حذف كارت About ومتبقي فقط المسارين)
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard(
              context,
              title: "Prediction Path",
              desc: "Analyze your lifestyle & AI prediction",
              icon: Icons.psychology_outlined,
              color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade800,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InputScreen()));
              },
            ),
            const SizedBox(height: 25),
            _buildOptionCard(
              context,
              title: "Tracking Path",
              desc: "View your daily plan & checklists",
              icon: Icons.fact_check_outlined,
              color: isDarkMode ? Colors.green.shade400 : Colors.green.shade700,
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

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 10, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title,
      required String desc,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
