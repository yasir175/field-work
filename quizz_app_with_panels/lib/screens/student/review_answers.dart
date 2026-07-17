import 'package:flutter/material.dart';
import '../../models/question.dart';

class ReviewAnswers extends StatelessWidget {
  final List<Question> questions;
  final Map<int, String?> selectedAnswers;

  const ReviewAnswers({
    super.key,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Answers')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final studentAnswer = selectedAnswers[index];
          final isCorrect = studentAnswer == question.correctAnswer;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}. ${question.question}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Your Answer: ${question.textForLetter(studentAnswer)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Correct Answer: ${question.textForLetter(question.correctAnswer)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
