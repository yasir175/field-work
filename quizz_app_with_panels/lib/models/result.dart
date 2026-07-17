// A simple model class representing a saved Quiz Result.
// We store studentName and quizTitle directly (instead of joining tables)
// to keep reading results simple for a beginner project.
class QuizResult {
  final int? id;
  final String studentId;
  final String studentName;
  final int quizId;
  final String quizTitle;
  final int score;
  final int total;
  final String dateTaken;

  QuizResult({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.dateTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'total': total,
      'dateTaken': dateTaken,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      quizId: map['quizId'],
      quizTitle: map['quizTitle'] ?? '',
      score: map['score'] ?? 0,
      total: map['total'] ?? 0,
      dateTaken: map['dateTaken'] ?? '',
    );
  }

  // Percentage score (0-100)
  double get percentage => total == 0 ? 0 : (score / total) * 100;
}
