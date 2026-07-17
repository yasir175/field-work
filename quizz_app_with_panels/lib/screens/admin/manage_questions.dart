import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import 'add_edit_question.dart';

class ManageQuestions extends StatefulWidget {
  final Quiz quiz;

  const ManageQuestions({super.key, required this.quiz});

  @override
  State<ManageQuestions> createState() => _ManageQuestionsState();
}

class _ManageQuestionsState extends State<ManageQuestions> {
  List<Question> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getQuestionsByQuiz(widget.quiz.id!);
    setState(() {
      questions = data.map((map) => Question.fromMap(map)).toList();
      isLoading = false;
    });
  }

  Future<void> confirmDelete(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteQuestion(question.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted'), backgroundColor: Colors.red),
      );
      loadQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Questions - ${widget.quiz.title}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(child: Text('No questions yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('${index + 1}. ${question.question}'),
                        subtitle: Text('Correct Answer: ${question.correctAnswer}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditQuestion(
                                      quizId: widget.quiz.id!,
                                      question: question,
                                    ),
                                  ),
                                );
                                loadQuestions();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(question),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditQuestion(quizId: widget.quiz.id!)),
          );
          loadQuestions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
