import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/quiz.dart';

// This one screen handles BOTH adding a new quiz and editing an existing one.
// If "quiz" is null we are adding a new quiz, otherwise we are editing it.
class AddEditQuiz extends StatefulWidget {
  final Quiz? quiz;

  const AddEditQuiz({super.key, this.quiz});

  @override
  State<AddEditQuiz> createState() => _AddEditQuizState();
}

class _AddEditQuizState extends State<AddEditQuiz> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController subjectController;

  bool get isEditing => widget.quiz != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.quiz?.title ?? '');
    descriptionController = TextEditingController(text: widget.quiz?.description ?? '');
    subjectController = TextEditingController(text: widget.quiz?.subject ?? '');
  }

  Future<void> saveQuiz() async {
    if (!formKey.currentState!.validate()) return;

    final quiz = Quiz(
      id: widget.quiz?.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      subject: subjectController.text.trim(),
      createdAt: widget.quiz?.createdAt ?? DateTime.now().toString(),
    );

    if (isEditing) {
      await DatabaseHelper.instance.updateQuiz(quiz.toMap());
    } else {
      await DatabaseHelper.instance.insertQuiz(quiz.toMap());
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Quiz updated' : 'Quiz added'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Quiz' : 'Add Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveQuiz,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
