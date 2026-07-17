import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import 'result_screen.dart';

// Shows one question at a time, with Previous / Next / Finish buttons.
// NOTE: No timer is used here, but the code is structured so a timer
// could easily be added later inside initState()/dispose() if needed.
class TakeQuiz extends StatefulWidget {
  final Quiz quiz;
  final String studentName;
  final String studentId;

  const TakeQuiz({
    super.key,
    required this.quiz,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<TakeQuiz> createState() => _TakeQuizState();
}

class _TakeQuizState extends State<TakeQuiz> {
  List<Question> questions = [];
  bool isLoading = true;
  int currentIndex = 0;

  // Stores the selected answer letter ('A'/'B'/'C'/'D') for each question
  // index. A missing entry means the student hasn't answered that one yet.
  Map<int, String?> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final data = await DatabaseHelper.instance.getQuestionsByQuiz(widget.quiz.id!);
    setState(() {
      questions = data.map((map) => Question.fromMap(map)).toList();
      isLoading = false;
    });
  }

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswers[currentIndex] = answer;
    });
  }

  void goNext() {
    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void goPrevious() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  Future<void> finishQuiz() async {
    // Calculate the score by comparing selected answers to correct answers
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswer) {
        score++;
      }
    }

    // Save this attempt into the results table
    await DatabaseHelper.instance.insertResult({
      'studentId': widget.studentId,
      'studentName': widget.studentName,
      'quizId': widget.quiz.id,
      'quizTitle': widget.quiz.title,
      'score': score,
      'total': questions.length,
      'dateTaken': DateTime.now().toString(),
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          studentName: widget.studentName,
          quizTitle: widget.quiz.title,
          score: score,
          total: questions.length,
          questions: questions,
          selectedAnswers: selectedAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: const Center(child: Text('This quiz has no questions yet.')),
      );
    }

    final question = questions[currentIndex];
    final isLastQuestion = currentIndex == questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Show the four options; tapping one selects it
            Expanded(
              child: ListView(
                children: ['A', 'B', 'C', 'D'].map((letter) {
                  final optionText = question.textForLetter(letter);
                  final isSelected = selectedAnswers[currentIndex] == letter;

                  return Card(
                    color: isSelected ? Colors.teal[100] : null,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(letter)),
                      title: Text(optionText),
                      onTap: () => selectAnswer(letter),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Previous / Next / Finish buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentIndex == 0 ? null : goPrevious,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLastQuestion ? finishQuiz : goNext,
                    child: Text(isLastQuestion ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
