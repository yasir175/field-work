# Quiz App — Admin & Student Edition (Offline, SQLite)

A simple, offline Flutter quiz application with two roles — **Admin** and
**Student** — backed entirely by a local SQLite database. No Firebase,
no backend server, no internet connection required.

---

## Features

### Admin
- Login with fixed credentials
- Add, edit, and delete quizzes
- Add, edit, and delete questions inside each quiz
- View a list of every result submitted by students
- Logout

### Student
- Enter Name + Student ID (no password, no registration)
- View all available quizzes with subject, description, and question count
- Take a quiz one question at a time (Previous / Next / Finish)
- View score and percentage immediately after finishing
- Review every question with their answer vs. the correct answer

---

## Admin Login

| Field    | Value      |
|----------|------------|
| Username | `admin`    |
| Password | `admin123` |

These are hardcoded in `lib/screens/admin/admin_login.dart`.

---

## Tech Stack

- **Flutter** (Material widgets only — no custom themes, no animations)
- **State management:** `StatefulWidget` + `setState()` only
- **Database:** SQLite via the [`sqflite`](https://pub.dev/packages/sqflite) package
- **Packages used:**
  - `sqflite` — local database
  - `path_provider` — finds the correct folder to store the database file
  - `path` — builds the database file path

---

## Getting Started

1. Clone or copy this project.
2. Make sure `pubspec.yaml` includes:

   ```yaml
   dependencies:
     sqflite: ^2.3.3
     path_provider: ^2.1.4
     path: ^1.9.0
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

The database file (`quiz_app.db`) is created automatically the first time
the app runs — no manual setup needed.

---

## Database Schema

**quizzes**
| Column      | Type    |
|-------------|---------|
| id          | INTEGER (PK, autoincrement) |
| title       | TEXT    |
| description | TEXT    |
| subject     | TEXT    |
| createdAt   | TEXT    |

**questions**
| Column        | Type    |
|---------------|---------|
| id            | INTEGER (PK, autoincrement) |
| quizId        | INTEGER (FK → quizzes.id) |
| question      | TEXT    |
| optionA       | TEXT    |
| optionB       | TEXT    |
| optionC       | TEXT    |
| optionD       | TEXT    |
| correctAnswer | TEXT (`A` / `B` / `C` / `D`) |

**students**
| Column    | Type    |
|-----------|---------|
| id        | INTEGER (PK, autoincrement) |
| name      | TEXT    |
| studentId | TEXT    |

**results**
| Column      | Type    |
|-------------|---------|
| id          | INTEGER (PK, autoincrement) |
| studentId   | TEXT    |
| studentName | TEXT    |
| quizId      | INTEGER |
| quizTitle   | TEXT    |
| score       | INTEGER |
| total       | INTEGER |
| dateTaken   | TEXT    |

> `studentName` and `quizTitle` are stored directly in `results` (instead
> of joining tables) to keep the queries simple and beginner-friendly.

Deleting a quiz also deletes all of its questions automatically.

---

## Project Structure

```
lib/
├── database/
│   └── database_helper.dart      # Singleton SQLite helper, all CRUD methods
├── models/
│   ├── quiz.dart
│   ├── question.dart
│   ├── student.dart
│   └── result.dart
├── screens/
│   ├── shared/
│   │   └── role_selection.dart   # First screen: Admin / Student choice
│   ├── admin/
│   │   ├── admin_login.dart
│   │   ├── admin_dashboard.dart
│   │   ├── manage_quizzes.dart
│   │   ├── add_edit_quiz.dart
│   │   ├── manage_questions.dart
│   │   ├── add_edit_question.dart
│   │   └── view_results.dart
│   └── student/
│       ├── student_login.dart
│       ├── quiz_list.dart
│       ├── take_quiz.dart
│       ├── result_screen.dart
│       └── review_answers.dart
└── main.dart
```

---

## App Flow

```
Role Selection
├── Admin
│   ├── Admin Login (admin / admin123)
│   └── Admin Dashboard
│       ├── Manage Quizzes → Add/Edit/Delete Quiz → Manage Questions
│       ├── View Results
│       └── Logout
└── Student
    ├── Student Login (Name + Student ID)
    └── Quiz List
        └── Take Quiz → Result Screen → Review Answers
```

---

## Notes

- No quiz timer is implemented (by design), but `take_quiz.dart` is
  structured so a `Timer.periodic` could be added later without
  restructuring the screen.
- This project intentionally avoids advanced architecture (no BLoC,
  Riverpod, GetX, Clean Architecture) to stay beginner-friendly and easy
  to modify.
