import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double rate;
  final double
      modelAccuracy; // 🌟 تم إضافة متغير دقة النموذج هنا لاستقباله من الـ InputScreen
  final List<String> warnings;
  final List<String> recommendations;
  final String message;

  // تحديث الباني لاستقبال المتغير الجديد كعنصر إجباري
  ResultScreen({
    required this.rate,
    required this.modelAccuracy, // 🌟 ممرر هنا لربط الصفحات
    required this.warnings,
    required this.recommendations,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analysis Results",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // لضمان ترتيب العناصر من البداية بشكل منظم
          children: [
            // عرض نسبة النجاح ودقة النموذج للمشرف ولجنة المناقشة
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity, // لضمان اتساع التصميم بشكل متناسق
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("Success Probability",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade700)),
                  SizedBox(height: 5),
                  Text("${rate.toStringAsFixed(1)}%",
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800)),

                  SizedBox(height: 12),
                  Divider(
                      color: Colors.blue.shade200,
                      thickness: 1,
                      indent: 30,
                      endIndent: 30),
                  SizedBox(height: 8),

                  // 🌟 هنا يتم عرض دقة النموذج (Model Accuracy) المطلوبة للمناقشة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined,
                          size: 20, color: Colors.blue.shade700),
                      SizedBox(width: 6),
                      Text(
                        "Model Accuracy (AI): ${modelAccuracy.toStringAsFixed(1)}%",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87)),
                ],
              ),
            ),

            SizedBox(height: 25),

            // قسم التحذيرات - تظهر الأيقونة المناسبة للتحذير هنا
            if (warnings.isNotEmpty)
              _buildSection("Warnings", warnings, Colors.red.shade700,
                  Icons.warning_amber_rounded),

            // قسم التوصيات
            if (recommendations.isNotEmpty)
              _buildSection("Recommendations", recommendations,
                  Colors.green.shade700, Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Divider(color: color, thickness: 1),
        SizedBox(height: 5),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 22, color: color),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(
                        item,
                        style: TextStyle(
                            fontSize: 15, color: Colors.black87, height: 1.3),
                      )),
                    ],
                  ),
                ))
            .toList(),
        SizedBox(height: 20),
      ],
    );
  }
}
