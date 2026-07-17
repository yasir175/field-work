import 'package:flutter/material.dart';
import '../../models/question.dart';
import 'review_answers.dart';

class ResultScreen extends StatelessWidget {
  final String studentName;
  final String quizTitle;
  final int score;
  final int total;
  final List<Question> questions;
  final Map<int, String?> selectedAnswers;

  const ResultScreen({
    super.key,
    required this.studentName,
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : (score / total) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        centerTitle: true,
        automaticallyImplyLeading: false, // hide back button, we replaced TakeQuiz
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 70, color: Colors.amber),
            const SizedBox(height: 20),
            Text('Student: $studentName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Quiz: $quizTitle', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(
              'Score: $score / $total',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Percentage: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 20, color: Colors.teal),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewAnswers(
                        questions: questions,
                        selectedAnswers: selectedAnswers,
                      ),
                    ),
                  );
                },
                child: const Text('Review Answers', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // TakeQuiz was replaced by this screen (pushReplacement),
                  // so QuizList is right underneath us on the stack.
                  // Popping once takes the student straight back to it.
                  Navigator.pop(context);
                },
                child: const Text('Back to Quiz List', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
