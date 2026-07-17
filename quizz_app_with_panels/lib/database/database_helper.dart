import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// DatabaseHelper is a Singleton: this means there is only ever ONE instance
// of this class in the whole app. We always access it using
// `DatabaseHelper.instance` instead of creating it with `DatabaseHelper()`.
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Gets the database, opening/creating it the first time it's needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'quiz_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // This runs only once, the very first time the database file is created.
  Future<void> _onCreate(Database db, int version) async {
    // Table for quizzes
    await db.execute('''
      CREATE TABLE quizzes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        subject TEXT,
        createdAt TEXT
      )
    ''');

    // Table for questions, linked to a quiz using quizId
    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quizId INTEGER NOT NULL,
        question TEXT NOT NULL,
        optionA TEXT NOT NULL,
        optionB TEXT NOT NULL,
        optionC TEXT NOT NULL,
        optionD TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        FOREIGN KEY (quizId) REFERENCES quizzes(id) ON DELETE CASCADE
      )
    ''');

    // Table for students who log in
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        studentId TEXT NOT NULL
      )
    ''');

    // Table for quiz results
    await db.execute('''
      CREATE TABLE results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        studentName TEXT NOT NULL,
        quizId INTEGER NOT NULL,
        quizTitle TEXT NOT NULL,
        score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        dateTaken TEXT NOT NULL
      )
    ''');
  }

  // ---------------------------------------------------------------
  // QUIZ METHODS
  // ---------------------------------------------------------------

  Future<int> insertQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    return await db.insert('quizzes', quiz);
  }

  Future<int> updateQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    return await db.update(
      'quizzes',
      quiz,
      where: 'id = ?',
      whereArgs: [quiz['id']],
    );
  }

  Future<int> deleteQuiz(int id) async {
    final db = await database;
    // Remove all questions that belong to this quiz first,
    // so we don't leave "orphan" questions behind.
    await db.delete('questions', where: 'quizId = ?', whereArgs: [id]);
    return await db.delete('quizzes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    final db = await database;
    return await db.query('quizzes', orderBy: 'id DESC');
  }

  // ---------------------------------------------------------------
  // QUESTION METHODS
  // ---------------------------------------------------------------

  Future<int> insertQuestion(Map<String, dynamic> question) async {
    final db = await database;
    return await db.insert('questions', question);
  }

  Future<int> updateQuestion(Map<String, dynamic> question) async {
    final db = await database;
    return await db.update(
      'questions',
      question,
      where: 'id = ?',
      whereArgs: [question['id']],
    );
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getQuestionsByQuiz(int quizId) async {
    final db = await database;
    return await db.query(
      'questions',
      where: 'quizId = ?',
      whereArgs: [quizId],
      orderBy: 'id ASC',
    );
  }

  // Returns how many questions a quiz has (used to show a count to students)
  Future<int> getQuestionCount(int quizId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM questions WHERE quizId = ?',
      [quizId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------------------------------------------------------
  // STUDENT METHODS
  // ---------------------------------------------------------------

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
  }

  // ---------------------------------------------------------------
  // RESULT METHODS
  // ---------------------------------------------------------------

  Future<int> insertResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('results', result);
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('results', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getResultsForStudent(String studentId) async {
    final db = await database;
    return await db.query(
      'results',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'id DESC',
    );
  }
}
