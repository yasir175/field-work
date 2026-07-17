// A simple model class representing one Quiz.
// It knows how to convert itself to/from a Map so it can be
// saved into (and read from) the SQLite database.
class Quiz {
  final int? id; // null when the quiz hasn't been saved yet
  final String title;
  final String description;
  final String subject;
  final String createdAt;

  Quiz({
    this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.createdAt,
  });

  // Convert this Quiz into a Map (used when saving to SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'createdAt': createdAt,
    };
  }

  // Create a Quiz object from a Map (used when reading from SQLite)
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
