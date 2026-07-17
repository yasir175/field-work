import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/quiz.dart';
import 'add_edit_quiz.dart';
import 'manage_questions.dart';

class ManageQuizzes extends StatefulWidget {
  const ManageQuizzes({super.key});

  @override
  State<ManageQuizzes> createState() => _ManageQuizzesState();
}

class _ManageQuizzesState extends State<ManageQuizzes> {
  List<Quiz> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  // Load all quizzes from the database
  Future<void> loadQuizzes() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getAllQuizzes();
    setState(() {
      quizzes = data.map((map) => Quiz.fromMap(map)).toList();
      isLoading = false;
    });
  }

  // Show a confirmation dialog before deleting a quiz
  Future<void> confirmDelete(Quiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"? All its questions will also be deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteQuiz(quiz.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz deleted'), backgroundColor: Colors.red),
      );
      loadQuizzes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Quizzes')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
              ? const Center(child: Text('No quizzes yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${quiz.subject}\n${quiz.description}'),
                        isThreeLine: true,
                        onTap: () {
                          // Tap the card to manage this quiz's questions
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ManageQuestions(quiz: quiz)),
                          ).then((_) => loadQuizzes());
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddEditQuiz(quiz: quiz)),
                                );
                                loadQuizzes();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(quiz),
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
            MaterialPageRoute(builder: (context) => const AddEditQuiz()),
          );
          loadQuizzes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
