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
  // Page routing configuration
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Local storage for evaluation logs (Historique)
  static List<Map<String, dynamic>> _historyLogs = [];

  // Controllers for text values
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _caloriesController = TextEditingController();

  // State variables for sliders and options
  int _gender = 1; // 1: Male, 0: Female
  double _activityLevel = 2.0;
  double _sportsDays = 3.0;
  double _sleepHours = 7.0;
  double _waterIntake = 2.0;
  double _stressLevel = 3.0;
  double _motivation = 4.0;
  int _nightEating = 0; // 0: No, 1: Yes
  bool _isCommitted = true;

  bool _isLoading = false;

  // Data sending function (Integration with Python Backend)
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
          "commitment": _isCommitted ? 5 : 2,
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
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Media Query to get device metrics dynamically
    final mediaQuery = MediaQuery.of(context);

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Auto-lifts elements when keyboard triggers
        appBar: AppBar(
          title: Text("WEIGO", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),

        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Analysis History",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                accountEmail: Text("Real-time tracking of previous entries"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.history_toggle_off_rounded,
                      size: 38, color: Colors.blue.shade700),
                ),
                decoration: BoxDecoration(color: Colors.blue.shade700),
              ),
              Expanded(
                child: _historyLogs.isEmpty
                    ? Center(
                        child: Text("No predictions recorded yet.",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500)))
                    : ListView.builder(
                        itemCount: _historyLogs.length,
                        itemBuilder: (context, index) {
                          final log = _historyLogs[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: log['rate'] >= 60
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                child: Text("${log['rate'].toInt()}%",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                              title: Text("Success Rate: ${log['rate']}%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (log['bmi'] > 0)
                                    Text(
                                        "Body Mass Index (BMI): ${log['bmi'].toStringAsFixed(1)}",
                                        style: TextStyle(fontSize: 11)),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 12, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(log['time'],
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
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
              // Structural Page Stage Tracker Indicator
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (index) => Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: _currentPage == index
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade300,
                                child: Text("${index + 1}",
                                    style: TextStyle(
                                        color: _currentPage == index
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                              if (index < 2) SizedBox(width: 6),
                            ],
                          )),
                ),
              ),

              // Flexible Content View Container
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    // 📄 Page 1: Personal Physical Demographics
                    _buildPageWrapper([
                      _buildHeader("Personal Data", Icons.person_outline),
                      LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildTextField(
                                    _ageController,
                                    "Age",
                                    Icons.cake,
                                    "Enter your current age in years.")),
                            SizedBox(width: 12),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Gender",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey.shade800,
                                            fontSize: 14)),
                                    Spacer(),
                                    _buildHelpIcon(
                                        "Select birth gender for BMR logic.")
                                  ],
                                ),
                                SizedBox(height: 8),
                                _buildDropdownGender(),
                              ],
                            )),
                          ],
                        );
                      }),
                      SizedBox(height: 10),
                      _buildTextField(
                          _heightController,
                          "Height (cm)",
                          Icons.height,
                          "Enter your vertical measurement in centimeters."),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _weightController,
                                  "Weight (kg)",
                                  Icons.monitor_weight,
                                  "Enter your exact current mass.")),
                          SizedBox(width: 12),
                          Expanded(
                              child: _buildTextField(
                                  _targetWeightController,
                                  "Target (kg)",
                                  Icons.flag,
                                  "Enter the milestone weight metric.")),
                        ],
                      ),
                    ]),

                    // 📄 Page 2: Dietary Habits & Sleep Intervals
                    _buildPageWrapper([
                      _buildHeader("Eating and Sleeping Patterns",
                          Icons.restaurant_menu),
                      _buildTextField(
                          _caloriesController,
                          "Average Calories Consumed",
                          Icons.local_fire_department,
                          "The average amount of energy intake consumed via food daily."),
                      SizedBox(height: 10),
                      _buildSlider(
                          "Drinking Water (liters/day)",
                          _waterIntake,
                          0,
                          5,
                          "Total volume of pure fluid intake consumed within 24 hours.",
                          isWater: true),
                      SizedBox(height: 10),
                      _buildSlider("Sleep Hours", _sleepHours, 4, 12,
                          "Average systemic overnight rest cycle experienced daily."),
                      SizedBox(height: 10),
                      _buildSwitch(
                          "Do you eat late at night?",
                          _nightEating == 1,
                          "Consuming heavy snacks or main courses near bedtime.",
                          (val) {
                        setState(() => _nightEating = val ? 1 : 0);
                      }),
                    ]),

                    // 📄 Page 3: Physical Training & Psychological State
                    _buildPageWrapper([
                      _buildHeader("Physical Activity & Mental State",
                          Icons.fitness_center),
                      _buildSlider("Activity Level (1-5)", _activityLevel, 1, 5,
                          "Overall daily movement: 1 for sedentary, 5 for heavy manual setups."),
                      SizedBox(height: 10),
                      _buildSlider("Sports Days/Week", _sportsDays, 0, 7,
                          "Weekly frequency allocated for deliberate athletic routines."),
                      SizedBox(height: 10),
                      _buildSlider("Stress Level", _stressLevel, 1, 5,
                          "Psychological pressure metric: 1 for tranquil, 5 for extreme tension."),
                      SizedBox(height: 10),
                      _buildSlider("Level of Motivation", _motivation, 1, 5,
                          "Inner behavioral determination score regarding consistency."),
                      SizedBox(height: 10),
                      _buildSwitch("Are you fully committed?", _isCommitted,
                          "Are you genuinely prepared to maintain self-discipline?",
                          (val) {
                        setState(() => _isCommitted = val);
                      }),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Native Bottom Navigation Bar Implementation (Guards layout from breaking)
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: mediaQuery.viewInsets.bottom > 0
                  ? 10
                  : 24, // Adapts layout padding based on keyboard state
              top: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2))
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    icon: Icon(Icons.arrow_back_ios, size: 14),
                    label: Text("Previous",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else
                  SizedBox(width: 10),
                _isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.blue.shade700, strokeWidth: 3)),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          } else {
                            _analyzeData();
                          }
                        },
                        icon: Icon(
                            _currentPage == 2
                                ? Icons.analytics
                                : Icons.arrow_forward_ios,
                            size: 16),
                        label: Text(_currentPage == 2 ? "Analyze" : "Next",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == 2
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 26, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Flexible UI Elements Widgets ---

  Widget _buildPageWrapper(List<Widget> children) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
          .onDrag, // Dismisses keyboard on scroll gesture
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpIcon(String helpText) {
    return Tooltip(
      message: helpText,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 24),
      showDuration: Duration(seconds: 4),
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(Icons.help_outline_rounded,
          color: Colors.amber.shade800, size: 20),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String helpText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                      fontSize: 14)),
              Spacer(),
              _buildHelpIcon(helpText)
            ],
          ),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 15),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              prefixIcon: Icon(icon, size: 20, color: Colors.blue.shade700),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownGender() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _gender,
          isExpanded: true,
          style: TextStyle(fontSize: 15, color: Colors.black),
          items: [
            DropdownMenuItem(child: Text("Male"), value: 1),
            DropdownMenuItem(child: Text("Female"), value: 0),
          ],
          onChanged: (val) => setState(() => _gender = val!),
        ),
      ),
    );
  }

  Widget _buildSlider(
      String label, double value, double min, double max, String helpText,
      {bool isWater = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
                "$label: ${isWater ? value.toStringAsFixed(1) : value.toInt()}",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800)),
            Spacer(),
            _buildHelpIcon(helpText)
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: isWater ? (max * 2).toInt() : (max - min).toInt(),
          activeColor: Colors.blue.shade700,
          inactiveColor: Colors.blue.shade100,
          onChanged: (val) {
            setState(() {
              if (label.contains("Activity")) {
                _activityLevel = val;
              } else if (label.contains("Sleep")) {
                _sleepHours = val;
              } else if (label.contains("Water")) {
                _waterIntake = val;
              } else if (label.contains("Sports")) {
                _sportsDays = val;
              } else if (label.contains("Stress")) {
                _stressLevel = val;
              } else if (label.contains("Motivation")) {
                _motivation = val;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitch(
      String title, bool val, String helpText, Function(bool) onChanged) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300)),
      child: SwitchListTile(
        title: Row(
          children: [
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800))),
            _buildHelpIcon(helpText)
          ],
        ),
        value: val,
        onChanged: onChanged,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        activeColor: Colors.blue.shade700,
      ),
    );
  }
}
