// A simple model class representing one multiple-choice Question.
// correctAnswer is stored as a single letter: 'A', 'B', 'C', or 'D'.
class Question {
  final int? id;
  final int quizId; // which quiz this question belongs to
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  Question({
    this.id,
    required this.quizId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  // Convert this Question into a Map (used when saving to SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
    };
  }

  // Create a Question object from a Map (used when reading from SQLite)
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      quizId: map['quizId'],
      question: map['question'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      optionC: map['optionC'] ?? '',
      optionD: map['optionD'] ?? '',
      correctAnswer: map['correctAnswer'] ?? 'A',
    );
  }

  // Helper: get the text of a given option letter ('A', 'B', 'C', 'D')
  String textForLetter(String? letter) {
    switch (letter) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return 'Not Answered';
    }
  }
}
