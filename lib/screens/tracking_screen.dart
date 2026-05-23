import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class TrackingScreen extends StatefulWidget {
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

  List<double> _weeklyHistory = [
    0.2,
    0.5,
    0.4,
    0.7,
    0.6,
    0.8,
    0.3
  ]; // قيم افتراضية للسجل

  @override
  void initState() {
    super.initState();
    _loadDataAndCheckDate();
  }

  // 2. منطق الوقت والتحقق من اليوم الجديد (Logic)
  Future<void> _loadDataAndCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    String today =
        DateTime.now().toString().split(' ')[0]; // تاريخ اليوم (YYYY-MM-DD)

    // تحميل البيانات المحفوظة
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
    });

    // إذا كان المستخدم يفتح التطبيق في يوم جديد
    if (lastDate != null && lastDate != today) {
      _archiveAndReset(today, prefs);
    } else if (lastDate == null) {
      await prefs.setString('last_date', today);
    }
  }

  void _archiveAndReset(String today, SharedPreferences prefs) async {
    double yesterdayProgress =
        _calculateProgress; // حساب إنجاز الأمس قبل التصفير

    setState(() {
      // تحديث السجل الأسبوعي (إضافة إنجاز الأمس وحذف الأقدم)
      _weeklyHistory.removeAt(0);
      _weeklyHistory.add(yesterdayProgress);

      // تصفير جميع المهام ليوم جديد
      for (var task in _dailyTasks) {
        task['isDone'] = false;
      }
    });

    // حفظ التغييرات الجديدة
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

  // 4. واجهة إضافة مهمة جديدة
  void _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("New Tracked Task"),
        content: TextField(
          controller: taskController,
          decoration: const InputDecoration(
            hintText: "Enter task name...",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                setState(() {
                  _dailyTasks
                      .add({"title": taskController.text, "isDone": false});
                });
                _saveTasks();
                Navigator.pop(context);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 5. بناء واجهة المستخدم (UI)
  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Progress Tracking",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Tasks',
            onPressed: () {
              setState(() {
                for (var task in _dailyTasks) task['isDone'] = false;
              });
              _saveTasks();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayProgressHeader(progress),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                "Weekly Performance History",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            ),
            _buildWeeklyChart(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                "Daily Routine Checklist (Swipe left to delete)",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
              ),
            ),
            _buildTasksList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayProgressHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor == Colors.blue
            ? Theme.of(context).primaryColor
            : Colors.blue.shade700,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Progress Rate",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              Text("${(progress * 100).toInt()}%",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade900.withOpacity(0.3),
              color: Colors.white,
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.only(right: 25, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: 0.2),
          minY: 0.0,
          maxY: 1.0, // من الصفر إلى الإنجاز الكامل 100%
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 0.25,
                getTitlesWidget: (value, meta) {
                  return Text("${(value * 100).toInt()}%",
                      style: const TextStyle(fontSize: 10, color: Colors.grey));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  int index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[index],
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500)),
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
              spots: _weeklyHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: Colors.blue.shade700.withOpacity(0.12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
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
            decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              _dailyTasks.removeAt(index);
            });
            _saveTasks();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
                color: isDone
                    ? Colors.blue.shade50.withOpacity(0.4)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 5,
                      spreadRadius: 1)
                ]),
            child: CheckboxListTile(
              title: Text(
                _dailyTasks[index]['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
                  color: isDone ? Colors.grey : Colors.black87,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              value: isDone,
              activeColor: Colors.blue.shade700,
              onChanged: (val) {
                setState(() {
                  _dailyTasks[index]['isDone'] = val;
                });
                _saveTasks();
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        );
      },
    );
  }
}
