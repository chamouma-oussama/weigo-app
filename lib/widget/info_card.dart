import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color themeColor;

  const InfoCard({required this.text, required this.icon, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: themeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.black87, fontSize: 14))),
        ],
      ),
    );
  }
}