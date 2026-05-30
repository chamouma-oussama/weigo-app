import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // 1. المتغيرات والبيانات
  List<Map<String, dynamic>> _dailyTasks = [
    {"title": "Morning: Drink 2 glasses of warm water", "isDone": false},
    {"title": "Breakfast: High Protein (3 eggs + veggies)", "isDone": false},
    {"title": "Activity: 30 minutes brisk walking", "isDone": false},
    {"title": "Lunch: Grilled chicken with salad", "isDone": false},
    {"title": "Water: Reach 3 liters total", "isDone": false},
    {"title": "Sleep: 8 hours of quality rest", "isDone": false},
  ];

  List<double> _weeklyHistory = [0.2, 0.5, 0.4, 0.7, 0.6, 0.8, 0.0]; // آخر عنصر يمثل اليوم الحالي ليرتبط بالمنحنى

  @override
  void initState() {
    super.initState();
    _loadDataAndCheckDate();
  }

  // 2. منطق الوقت والتحقق من اليوم الجديد
  Future<void> _loadDataAndCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0]; // تاريخ اليوم (YYYY-MM-DD)

    String? savedTasks = prefs.getString('saved_tasks');
    String? lastDate = prefs.getString('last_date');
    String? savedHistory = prefs.getString('weekly_history');

    setState(() {
      if (savedTasks != null) {
        _dailyTasks = List<Map<String, dynamic>>.from(jsonDecode(savedTasks));
      }
      if (savedHistory != null) {
        _weeklyHistory = List<double>.from(jsonDecode(savedHistory));
      }
      // تحديث آخر نقطة في المنحنى تلقائياً لتعكس التقدم الفعلي لليوم الحالي عند الفتح
      if (_weeklyHistory.isNotEmpty) {
        _weeklyHistory[_weeklyHistory.length - 1] = _calculateProgress;
      }
    });

    if (lastDate != null && lastDate != today) {
      _archiveAndReset(today, prefs);
    } else if (lastDate == null) {
      await prefs.setString('last_date', today);
    }
  }

  void _archiveAndReset(String today, SharedPreferences prefs) async {
    double yesterdayProgress = _calculateProgress;

    setState(() {
      _weeklyHistory.removeAt(0);
      _weeklyHistory.add(yesterdayProgress);

      for (var task in _dailyTasks) {
        task['isDone'] = false;
      }
      // إعادة تصفير تقدم اليوم الجديد في المنحنى
      _weeklyHistory[_weeklyHistory.length - 1] = 0.0;
    });

    await prefs.setString('last_date', today);
    await prefs.setString('weekly_history', jsonEncode(_weeklyHistory));
    _saveTasks();
  }

  // 3. دوال الحفظ والحساب
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_tasks', jsonEncode(_dailyTasks));
  }

  double get _calculateProgress {
    if (_dailyTasks.isEmpty) return 0;
    int doneCount = _dailyTasks.where((task) => task['isDone'] == true).length;
    return doneCount / _dailyTasks.length;
  }

  // 4. واجهة إضافة مهمة جديدة (متوافقة مع الثيمين)
  void _showAddTaskDialog(bool isDarkMode) {
    TextEditingController taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("New Tracked Task", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        content: TextField(
          controller: taskController,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Enter task name...",
            hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade500 : Colors.grey),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDarkMode ? Colors.blueGrey.shade700 : Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: isDarkMode ? const Color.fromARGB(255, 66, 165, 245) : Colors.blue)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                setState(() {
                  _dailyTasks.add({"title": taskController.text, "isDone": false});
                  // تحديث المنحنى فوراً
                  _weeklyHistory[_weeklyHistory.length - 1] = _calculateProgress;
                });
                _saveTasks();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.blue.shade500 : Colors.blue.shade700),
            child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. بناء واجهة المستخدم (UI)
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double progress = _calculateProgress;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("Progress Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Tasks',
            onPressed: () {
              setState(() {
                for (var task in _dailyTasks) task['isDone'] = false;
                _weeklyHistory[_weeklyHistory.length - 1] = 0.0; // تصفير المنحنى لليوم
              });
              _saveTasks();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayProgressHeader(progress, isDarkMode),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                      child: Text(
                        "Weekly Performance History",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.blue.shade400 : Colors.blueGrey,
                        ),
                      ),
                    ),
                    _buildWeeklyChart(isDarkMode),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                      child: Text(
                        "Daily Routine Checklist (Swipe left to delete)",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildTasksList(isDarkMode),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // 💾 زر التأكيد العصري المثبت في الأسفل
            _buildConfirmButton(isDarkMode),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0), // رفع الزر قليلاً لكي لا يغطي عليه زر التأكيد
        child: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(isDarkMode),
          backgroundColor: isDarkMode ? Colors.blue.shade500 : Colors.blue.shade700,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTodayProgressHeader(double progress, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.blue.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Progress Rate",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              Text("${(progress * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDarkMode ? Colors.blueGrey.shade800 : Colors.blue.shade900.withOpacity(0.3),
              color: isDarkMode ? Colors.blue.shade400 : Colors.white,
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDarkMode) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.only(right: 25, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDarkMode ? Border.all(color: Colors.blueGrey.shade800, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDarkMode ? Colors.blueGrey.shade800 : Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          minY: 0.0,
          maxY: 1.0,
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: 0.25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${(value * 100).toInt()}%",
                    style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.grey.shade400 : Colors.grey),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  int index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text("");
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _weeklyHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700,
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.x == 6, // تمييز نقطة اليوم الحالي فقط
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 6,
                  color: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: (isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700).withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailyTasks.length,
      itemBuilder: (context, index) {
        final isDone = _dailyTasks[index]['isDone'] ?? false;
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              _dailyTasks.removeAt(index);
              _weeklyHistory[_weeklyHistory.length - 1] = _calculateProgress; // تحديث المنحنى بعد الحذف
            });
            _saveTasks();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              // 🛠️ تم الإصلاح هنا: استبدال shade950 بالدرجة اللونية الكحلية الداكنة المخصصة والمستقرة
              color: isDone
                  ? (isDarkMode ? const Color(0xFF172554).withOpacity(0.4) : Colors.green.shade50.withOpacity(0.7))
                  : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDone
                    ? (isDarkMode ? Colors.blue.shade800 : Colors.green.shade200)
                    : (isDarkMode ? Colors.blueGrey.shade800 : Colors.grey.shade100),
                width: 1,
              ),
            ),
            child: CheckboxListTile(
              title: Text(
                _dailyTasks[index]['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isDone ? FontWeight.w400 : FontWeight.w500,
                  color: isDone
                      ? (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600)
                      : (isDarkMode ? Colors.grey.shade200 : Colors.black87),
                  decoration: TextDecoration.none, // الكتابة تظل نظيفة بدون خط مشطوب
                ),
              ),
              value: isDone,
              activeColor: isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700,
              checkColor: Colors.white,
              onChanged: (val) {
                setState(() {
                  _dailyTasks[index]['isDone'] = val;
                  // تحديث المنحنى البياني فوراً عند الضغط ليتماشى مع المهام المنجزة أمام اللجنة
                  _weeklyHistory[_weeklyHistory.length - 1] = _calculateProgress;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        );
      },
    );
  }

  // 💾 ودجت زر التأكيد العصري المضاف في الأسفل
  Widget _buildConfirmButton(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await _saveTasks();
          // حفظ إنجاز اليوم الحالي بشكل دائم في السجل الأسبوعي
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('weekly_history', jsonEncode(_weeklyHistory));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text("Weigo Progress Saved! (${(_calculateProgress * 100).toInt()}% Done)"),
                ],
              ),
              backgroundColor: isDarkMode ? Colors.blue.shade600 : Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        icon: const Icon(Icons.task_alt_rounded, size: 20, color: Colors.white),
        label: const Text(
          "Confirm & Save Progress",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.blue.shade500 : Colors.blue.shade700,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}