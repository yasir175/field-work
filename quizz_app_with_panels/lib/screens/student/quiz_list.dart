import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/quiz.dart';
import 'take_quiz.dart';

class QuizList extends StatefulWidget {
  final String studentName;
  final String studentId;

  const QuizList({super.key, required this.studentName, required this.studentId});

  @override
  State<QuizList> createState() => _QuizListState();
}

class _QuizListState extends State<QuizList> {
  List<Quiz> quizzes = [];
  Map<int, int> questionCounts = {}; // quizId -> number of questions
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getAllQuizzes();
    final loadedQuizzes = data.map((map) => Quiz.fromMap(map)).toList();

    // Get the question count for each quiz so students know how long it is
    final counts = <int, int>{};
    for (final quiz in loadedQuizzes) {
      counts[quiz.id!] = await DatabaseHelper.instance.getQuestionCount(quiz.id!);
    }

    setState(() {
      quizzes = loadedQuizzes;
      questionCounts = counts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.studentName}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
              ? const Center(child: Text('No quizzes available yet.'))
              : ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    final count = questionCounts[quiz.id] ?? 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${quiz.subject}\n${quiz.description}\nQuestions: $count'),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          // Disable the button if the quiz has no questions yet
                          onPressed: count == 0
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TakeQuiz(
                                        quiz: quiz,
                                        studentName: widget.studentName,
                                        studentId: widget.studentId,
                                      ),
                                    ),
                                  ).then((_) => loadQuizzes());
                                },
                          child: const Text('Start'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
