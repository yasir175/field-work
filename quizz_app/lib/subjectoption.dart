import 'package:flutter/material.dart';
import 'package:quizz_app/quiz1.dart';
import 'package:quizz_app/quiz2.dart';
import 'package:quizz_app/quiz3.dart';
class SubOption extends StatefulWidget {
  const SubOption({super.key});

  @override
  State<SubOption> createState() => _SubOption();
}

class _SubOption extends State<SubOption> {
  Widget optionBox(String title, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(
            vertical: 8,   // 👈 reduces height (top + bottom)
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(child: Text(title)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subject Options')),
      body: Row(
        children: [
          optionBox('Time Complexity Quiz 1', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Quiz1()),
            );
          }),
          optionBox('Time Complexity Quiz 2', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Quiz2()),
            );
          }),
          optionBox('Time Complexity Quiz 3', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Quiz3()),
            );
          }),
        ],
      ),
    );
  }
}
