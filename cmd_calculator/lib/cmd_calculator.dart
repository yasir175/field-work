import 'dart:io';

void main() {
  print('=== Simple Calculator ===');
  print('Operators: + - * /');
  print('Type "exit" to quit');
  print('');

  while (true) {
    stdout.write('Enter expression (e.g. 10 + 5): ');
    String? input = stdin.readLineSync();

    if (input == null || input.trim() == 'exit') {
      print('Goodbye!');
      break;
    }

    List<String> parts = input.trim().split(' ');

    if (parts.length != 3) {
      print('Invalid input. Use format: number operator number');
      continue;
    }

    double? a = double.tryParse(parts[0]);
    String op = parts[1];
    double? b = double.tryParse(parts[2]);

    if (a == null || b == null) {
      print('Invalid numbers. Please try again.');
      continue;
    }

    double result;

    if (op == '+') {
      result = a + b;
    } else if (op == '-') {
      result = a - b;
    } else if (op == '*') {
      result = a * b;
    } else if (op == '/') {
      if (b == 0) {
        print('Error: Cannot divide by zero.');
        continue;
      }
      result = a / b;
    } else {
      print('Unknown operator "$op". Use + - * /');
      continue;
    }

    print('Result: $result');
    print('');
  }
}