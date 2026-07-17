import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/result.dart';

class ViewResults extends StatefulWidget {
  const ViewResults({super.key});

  @override
  State<ViewResults> createState() => _ViewResultsState();
}

class _ViewResultsState extends State<ViewResults> {
  List<QuizResult> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    final data = await DatabaseHelper.instance.getResults();
    setState(() {
      results = data.map((map) => QuizResult.fromMap(map)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Results')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text('No results yet.'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('${result.studentName} (${result.studentId})'),
                        subtitle: Text('Quiz: ${result.quizTitle}\nDate: ${result.dateTaken}'),
                        isThreeLine: true,
                        trailing: Text(
                          '${result.score}/${result.total}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
