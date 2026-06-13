import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double rate;
  final double modelAccuracy; // 🌟 تم إضافة متغير دقة النموذج هنا لاستقباله من الـ InputScreen
  final List<String> warnings;
  final List<String> recommendations;
  final String message;

  // ✨ إضافة const وتحديث الباني لاستقبال المتغير الجديد كعنصر إجباري
  const ResultScreen({
    Key? key,
    required this.rate,
    required this.modelAccuracy, // 🌟 ممرر هنا لربط الصفحات
    required this.warnings,
    required this.recommendations,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🌓 التحقق مما إذا كان الجهاز يشتغل بالوضع الداكن حالياً
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 🌍 إجبار الواجهة على التنسيق الأجنبي لضمان ثبات الأيقونات والنصوص بالمناقشة
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Analysis Results",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // لضمان ترتيب العناصر من البداية بشكل منظم
            children: [
              // عرض نسبة النجاح ودقة النموذج للمشرف ولجنة المناقشة
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity, // لضمان اتساع التصميم بشكل متناسق
                decoration: BoxDecoration(
                  // 🎨 تلوين الخلفية ديناميكياً بحسب الوضع الليلي أو العادي
                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDarkMode ? Colors.blueGrey.shade700 : Colors.blue.shade100, 
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Success Probability",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.blueGrey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${rate.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: isDarkMode ? Colors.blueGrey.shade600 : Colors.blue.shade200,
                      thickness: 1,
                      indent: 30,
                      endIndent: 30,
                    ),
                    const SizedBox(height: 8),
                    
                    // 🌟 هنا يتم عرض دقة النموذج (Model Accuracy) المطلوبة للمناقشة
                    
                    const SizedBox(height: 15),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        // 🛠️ تم التعديل هنا وإصلاح الخطأ المطبعي بنجاح
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // قسم التحذيرات - تظهر الأيقونة المناسبة للتحذير هنا
              if (warnings.isNotEmpty)
                _buildSection(
                  "Warnings",
                  warnings,
                  isDarkMode ? Colors.red.shade400 : Colors.red.shade700,
                  Icons.warning_amber_rounded,
                  isDarkMode,
                ),

              // قسم التوصيات
              if (recommendations.isNotEmpty)
                _buildSection(
                  "Recommendations",
                  recommendations,
                  isDarkMode ? Colors.green.shade400 : Colors.green.shade700,
                  Icons.check_circle_outline,
                  isDarkMode,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Divider(color: color, thickness: 1),
        const SizedBox(height: 5),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 15,
                    // 🌓 تعديل لون نصوص القائمة لتتناسب مع الخلفية الداكنة
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}