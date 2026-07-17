import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/question.dart';

// This screen handles BOTH adding a new question and editing one.
// If "question" is null we are adding, otherwise we are editing it.
class AddEditQuestion extends StatefulWidget {
  final int quizId;
  final Question? question;

  const AddEditQuestion({super.key, required this.quizId, this.question});

  @override
  State<AddEditQuestion> createState() => _AddEditQuestionState();
}

class _AddEditQuestionState extends State<AddEditQuestion> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController questionController;
  late TextEditingController optionAController;
  late TextEditingController optionBController;
  late TextEditingController optionCController;
  late TextEditingController optionDController;
  String correctAnswer = 'A';

  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.question?.question ?? '');
    optionAController = TextEditingController(text: widget.question?.optionA ?? '');
    optionBController = TextEditingController(text: widget.question?.optionB ?? '');
    optionCController = TextEditingController(text: widget.question?.optionC ?? '');
    optionDController = TextEditingController(text: widget.question?.optionD ?? '');
    correctAnswer = widget.question?.correctAnswer ?? 'A';
  }

  Future<void> saveQuestion() async {
    if (!formKey.currentState!.validate()) return;

    final question = Question(
      id: widget.question?.id,
      quizId: widget.quizId,
      question: questionController.text.trim(),
      optionA: optionAController.text.trim(),
      optionB: optionBController.text.trim(),
      optionC: optionCController.text.trim(),
      optionD: optionDController.text.trim(),
      correctAnswer: correctAnswer,
    );

    if (isEditing) {
      await DatabaseHelper.instance.updateQuestion(question.toMap());
    } else {
      await DatabaseHelper.instance.insertQuestion(question.toMap());
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Question updated' : 'Question added'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  // Small helper widget so we don't repeat the same TextFormField 4 times
  Widget optionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Question' : 'Add Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter the question' : null,
              ),
              const SizedBox(height: 16),
              optionField('Option A', optionAController),
              optionField('Option B', optionBController),
              optionField('Option C', optionCController),
              optionField('Option D', optionDController),
              DropdownButtonFormField<String>(
                value: correctAnswer,
                decoration: const InputDecoration(labelText: 'Correct Answer', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'A', child: Text('Option A')),
                  DropdownMenuItem(value: 'B', child: Text('Option B')),
                  DropdownMenuItem(value: 'C', child: Text('Option C')),
                  DropdownMenuItem(value: 'D', child: Text('Option D')),
                ],
                onChanged: (value) {
                  setState(() => correctAnswer = value!);
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveQuestion,
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
