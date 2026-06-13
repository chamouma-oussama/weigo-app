// input_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_screen.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static List<Map<String, dynamic>> _historyLogs = [];

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _caloriesController = TextEditingController();

  int _gender = 1; // 1: Male, 0: Female
  double _activityLevel = 2.0;
  double _sportsDays = 3.0;
  double _sleepHours = 7.0;
  double _waterIntake = 2.0;
  double _stressLevel = 3.0;
  double _motivation = 4.0;
  int _nightEating = 0;
  double _isCommitted = 5.0;

  bool _isLoading = false;

  Future<void> _analyzeData() async {
    if (_ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _targetWeightController.text.isEmpty ||
        _caloriesController.text.isEmpty) {
      _showError("Please fill in all numerical input fields first.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = 'https://weigo-be.onrender.com/predict';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": int.parse(_ageController.text.trim()),
          "gender": _gender,
          "height": double.parse(_heightController.text.trim()),
          "current_weight": double.parse(_weightController.text.trim()),
          "target_weight": double.parse(_targetWeightController.text.trim()),
          "activity_level": _activityLevel.toInt(),
          "sports_days": _sportsDays.toInt(),
          "sleep_hours": _sleepHours.toInt(),
          "Avg_Caloric_Intake": double.parse(_caloriesController.text.trim()),
          "water_intake": _waterIntake,
          "night_eating": _nightEating,
          "stress_level": _stressLevel.toInt(),
          "commitment": _isCommitted.toInt(),
          "motivation": _motivation.toInt(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String currentFormattedTime =
            DateFormat('yyyy-MM-dd | hh:mm a').format(DateTime.now());
        setState(() {
          _historyLogs.insert(0, {
            'time': currentFormattedTime,
            'rate': data['success_rate'].toDouble(),
            'bmi': data['analysis']['bmi']?.toDouble() ?? 0.0
          });
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              rate: data['success_rate'].toDouble(),
              modelAccuracy: data['model_accuracy'].toDouble(),
              warnings: List<String>.from(data['analysis']['warnings']),
              recommendations:
                  List<String>.from(data['analysis']['recommendations']),
              message: data['analysis']['message'],
            ),
          ),
        );
      } else {
        _showError("Server Error: Status code ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed. Ensure the Python backend is active: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: ui.TextDirection.ltr,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryBlue = Colors.blue.shade800;
    final deepBlueButton = Colors.blue.shade800;
    final lightBackground = const Color(0xFFF8F9FA);
    final surfaceColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : lightBackground,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("WEIGO",
              style:
                  TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          centerTitle: true,
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: Drawer(
          backgroundColor: surfaceColor,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text("Analysis History",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                accountEmail: const Text(
                    "Real-time tracking of previous entries",
                    style: TextStyle(color: Colors.white70)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF0F4C81)
                      : const Color(0xFFECEFF1),
                  child: Icon(Icons.history_toggle_off_rounded,
                      size: 34, color: isDarkMode ? Colors.white : primaryBlue),
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF111827) : primaryBlue,
                ),
              ),
              Expanded(
                child: _historyLogs.isEmpty
                    ? Center(
                        child: Text("No predictions recorded yet.",
                            style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500)))
                    : ListView.builder(
                        itemCount: _historyLogs.length,
                        itemBuilder: (context, index) {
                          final log = _historyLogs[index];
                          return Card(
                            color: isDarkMode
                                ? const Color(0xFF111827)
                                : Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: log['rate'] >= 60
                                    ? (isDarkMode
                                        ? const Color(0xFF064E3B)
                                        : const Color(0xFFE8F5E9))
                                    : (isDarkMode
                                        ? const Color(0xFF78350F)
                                        : const Color(0xFFFFF3E0)),
                                child: Text("${log['rate'].toInt()}%",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: log['rate'] >= 60
                                            ? Colors.green.shade700
                                            : Colors.orange.shade800)),
                              ),
                              title: Text("Success Rate: ${log['rate']}%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : primaryBlue,
                                      fontSize: 13)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (log['bmi'] > 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0),
                                      key: UniqueKey(),
                                      child: Text(
                                          "Body Mass Index (BMI): ${log['bmi'].toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: isDarkMode
                                                  ? Colors.grey.shade300
                                                  : Colors.blueGrey.shade700)),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(log['time'],
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                color: isDarkMode ? const Color(0xFF121212) : lightBackground,
                child: Row(
                  children: List.generate(3, (index) {
                    bool isPassed = index <= _currentPage;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? (isDarkMode
                                  ? Colors.blue.shade400
                                  : primaryBlue)
                              : (isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    // 📄 Page 1: Personal Physical Demographics
                    _buildPageWrapper(surfaceColor, isDarkMode, [
                      _buildHeader("Personal Data", Icons.person_outline,
                          isDarkMode, primaryBlue),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _ageController,
                                  "Age",
                                  Icons.cake,
                                  "Enter your current age in years.",
                                  isDarkMode,
                                  primaryBlue)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Gender",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : primaryBlue,
                                            fontSize: 14)),
                                    const Spacer(),
                                    _buildHelpIcon(
                                        "Select birth gender for BMR logic.")
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildDropdownGender(isDarkMode, primaryBlue),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                          _heightController,
                          "Height (cm)",
                          Icons.height,
                          "Enter your vertical measurement in centimeters.",
                          isDarkMode,
                          primaryBlue),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _weightController,
                                  "Weight (kg)",
                                  Icons.monitor_weight,
                                  "Enter your exact current mass.",
                                  isDarkMode,
                                  primaryBlue)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _targetWeightController,
                                  "Target (kg)",
                                  Icons.flag,
                                  "Enter the milestone weight metric.",
                                  isDarkMode,
                                  primaryBlue)),
                        ],
                      ),
                    ]),

                    // 📄 Page 2: Dietary Habits & Sleep Intervals
                    _buildPageWrapper(surfaceColor, isDarkMode, [
                      _buildHeader("Eating & Sleeping", Icons.restaurant_menu,
                          isDarkMode, primaryBlue),
                      const SizedBox(height: 8),
                      _buildTextField(
                          _caloriesController,
                          "Average Calories Consumed",
                          Icons.local_fire_department,
                          "The average amount of energy intake consumed via food daily.",
                          isDarkMode,
                          primaryBlue),
                      const SizedBox(height: 24),
                      _buildSlider(
                          "Drinking Water (liters/day)",
                          _waterIntake,
                          0,
                          5,
                          "Total volume of pure fluid intake consumed within 24 hours.",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _waterIntake = val),
                          isWater: true),
                      const SizedBox(height: 24),
                      _buildSlider(
                          "Sleep Hours",
                          _sleepHours,
                          4,
                          12,
                          "Average systemic overnight rest cycle experienced daily.",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _sleepHours = val)),
                      const SizedBox(height: 24),
                      _buildSwitch(
                          "Do you eat late at night?",
                          _nightEating == 1,
                          "Consuming heavy snacks or main courses near bedtime.",
                          isDarkMode,
                          primaryBlue, (val) {
                        setState(() => _nightEating = val ? 1 : 0);
                      }),
                    ]),

                    // 📄 Page 3: Physical Training & Psychological State
                    _buildPageWrapper(surfaceColor, isDarkMode, [
                      _buildHeader("Activity & Mental State",
                          Icons.fitness_center, isDarkMode, primaryBlue),
                      const SizedBox(height: 8),
                      _buildSlider(
                          "Activity Level (1-5)",
                          _activityLevel,
                          1,
                          5,
                          "Overall daily movement: 1 for sedentary, 5 for heavy manual setups.",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _activityLevel = val)),
                      const SizedBox(height: 24),
                      _buildSlider(
                          "Sports Days/Week",
                          _sportsDays,
                          0,
                          7,
                          "Weekly frequency allocated for deliberate athletic routines.",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _sportsDays = val)),
                      const SizedBox(height: 24),
                      _buildSlider(
                          "Stress Level",
                          _stressLevel,
                          1,
                          10,
                          "Psychological pressure metric: 1 for tranquil, 5 for extreme tension.",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _stressLevel = val)),
                      const SizedBox(height: 24),
                      _buildSlider(
                          "Level of Motivation",
                          _motivation,
                          1,
                          10,
                          "Inner behavioral determination score regarding consistency.",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _motivation = val)),
                      const SizedBox(height: 24),
                      _buildSlider(
                          "Are you fully committed?",
                          _isCommitted,
                          1,
                          10,
                          "Are you genuinely prepared to maintain self-discipline?",
                          isDarkMode,
                          primaryBlue,
                          (val) => setState(() => _isCommitted = val)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: mediaQuery.viewInsets.bottom > 0 ? 12 : 32,
              top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: isDarkMode
                          ? Colors.black45
                          : Colors.black12.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -4))
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 14),
                    label: const Text("Back",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    style: TextButton.styleFrom(
                      foregroundColor: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  )
                else
                  const SizedBox(width: 10),
                _isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: isDarkMode
                                    ? Colors.blue.shade400
                                    : deepBlueButton,
                                strokeWidth: 3)),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          } else {
                            _analyzeData();
                          }
                        },
                        icon: Icon(
                            _currentPage == 2
                                ? Icons.analytics_rounded
                                : Icons.arrow_forward_ios,
                            size: 16),
                        label: Text(
                            _currentPage == 2 ? "Analyze Now" : "Continue",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == 2
                              ? Colors.green.shade600
                              : (isDarkMode
                                  ? Colors.blue.shade500
                                  : deepBlueButton),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Elements Widgets ---

  Widget _buildPageWrapper(
      Color surfaceColor, bool isDarkMode, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.transparent
                  : Colors.black12.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ]),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildHeader(
      String title, IconData icon, bool isDarkMode, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.blueGrey.shade900
                  : primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: isDarkMode ? Colors.blue.shade300 : primaryColor,
                size: 22),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : primaryColor)),
        ],
      ),
    );
  }

  Widget _buildHelpIcon(String helpText) {
    return Tooltip(
      message: helpText,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      showDuration: const Duration(seconds: 3),
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(Icons.help_outline_rounded,
          color: Colors.blueGrey.shade400, size: 18),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String helpText, bool isDarkMode, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                    fontSize: 14)),
            const Spacer(),
            _buildHelpIcon(helpText),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
              fontSize: 15, color: isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            prefixIcon: Icon(icon,
                size: 18,
                color: isDarkMode
                    ? Colors.blue.shade300
                    : primaryColor.withOpacity(0.7)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                  width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: isDarkMode ? Colors.blue.shade400 : primaryColor,
                  width: 2.0),
            ),
            filled: true,
            fillColor:
                isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownGender(bool isDarkMode, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _gender,
          isExpanded: true,
          dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: isDarkMode
                  ? Colors.grey.shade400
                  : primaryColor.withOpacity(0.7)),
          style: TextStyle(
              fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
          items: [
            DropdownMenuItem(
                child: Text("Male",
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500)),
                value: 1),
            DropdownMenuItem(
                child: Text("Female",
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500)),
                value: 0),
          ],
          onChanged: (val) => setState(() => _gender = val!),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      String helpText, bool isDarkMode, Color primaryColor, ValueChanged<double> onChanged,
      {bool isWater = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : primaryColor)),
                const SizedBox(width: 6),
                _buildHelpIcon(helpText),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blueGrey.shade900
                    : primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isWater
                    ? "${value.toStringAsFixed(1)} L"
                    : value.toInt().toString(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blue.shade300 : primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            activeTrackColor: isDarkMode ? Colors.blue.shade400 : primaryColor,
            inactiveTrackColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            thumbColor: isDarkMode ? Colors.blue.shade400 : primaryColor,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt() == 0 ? 1 : (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, String helpText,
      bool isDarkMode, Color primaryColor, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : primaryColor)),
                  const SizedBox(width: 6),
                  _buildHelpIcon(helpText),
                ],
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDarkMode ? Colors.blue.shade400 : primaryColor,
        ),
      ],
    );
  }
}