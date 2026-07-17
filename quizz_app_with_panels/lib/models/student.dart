// A simple model class representing a Student.
// Students only need a name and a student ID to log in (no password).
class Student {
  final int? id;
  final String name;
  final String studentId;

  Student({
    this.id,
    required this.name,
    required this.studentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
    );
  }
}
