import 'package:flutter/material.dart';

class Question {
  final String QuestionText;
  final List<String> Options;
  final int CorrectIndex;

  Question({
    required this.QuestionText,
    required this.Options,
    required this.CorrectIndex,
  });
}



class Result extends StatelessWidget {
  final int score;
  final int total;

  const Result({
    super.key,
    required this.score,
    required this.total,
});
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Result'),
       centerTitle: true,
     ),
     body: Center(
       child: Text(
         "Your Score: $score/$total",
         style: const TextStyle(
           fontSize: 28,
           fontWeight: FontWeight.bold,

         ),
       ),
     ),
   );
  }
}
