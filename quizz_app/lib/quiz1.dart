import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizz_app/result.dart';

class Question {
  final String QuestionText;
  final List<String> Options;
  final int CorrectIndex;

  Question({
    required this.QuestionText,
    required this.Options,
    required this.CorrectIndex,
  });
}


final List<Question> quiz1 = [
  Question(
    QuestionText:
        "What is the time complexity of accessing an array element by index?",
    Options: ["O(n)", "O(log n)", "O(1)", "O(n log n)"],
    CorrectIndex: 2,
  ),
  Question(
    QuestionText: "Time complexity of linear search in worst case?",
    Options: ["O(1)", "O(n)", "O(log n)", "O(n²)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Binary search works only on:",
    Options: ["Linked list", "Sorted array", "Stack", "Queue"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Worst-case time complexity of binary search:",
    Options: ["O(n)", "O(log n)", "O(n log n)", "O(1)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of bubble sort (worst case):",
    Options: ["O(n)", "O(n log n)", "O(n²)", "O(log n)"],
    CorrectIndex: 2,
  ),
  Question(
    QuestionText: "Best case time complexity of bubble sort:",
    Options: ["O(n)", "O(n²)", "O(log n)", "O(1)"],
    CorrectIndex: 0,
  ),
  Question(
    QuestionText: "Time complexity of merge sort:",
    Options: ["O(n²)", "O(n log n)", "O(n)", "O(log n)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of quicksort (average case):",
    Options: ["O(n log n)", "O(n²)", "O(log n)", "O(n)"],
    CorrectIndex: 0,
  ),
  Question(
    QuestionText: "Worst-case time complexity of quicksort:",
    Options: ["O(n log n)", "O(n²)", "O(n)", "O(log n)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of inserting at head of linked list:",
    Options: ["O(n)", "O(1)", "O(log n)", "O(n log n)"],
    CorrectIndex: 1,
  ),
];

class Quiz1 extends StatefulWidget {
  const Quiz1({super.key});

  @override
  State<Quiz1> createState() => _Quiz1();
}

class _Quiz1 extends State<Quiz1> {
  int currentindex = 0;
  int score = 0;
  int total=10;
 int duration=30;
 Timer?timer;
 void initState()
 {
   super.initState();
   startTimer();
 }
 void startTimer(){
   duration=30;
   timer?.cancel();

   timer=Timer.periodic(const Duration(seconds: 1),(t){
     if(!mounted)return;

     setState(() {
       duration--;
     });
     if(duration==0)
       {
         t.cancel();
         answer(-1);
       }
   });

 }
  void answer(int index) {
   timer?.cancel();
   if (quiz1[currentindex].CorrectIndex == index) {
      score++;
    }
    setState(() {
      currentindex++;
    });
    if (currentindex == quiz1.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Result(score:score,total:total)),
      );
    }
    else
      {
        startTimer();
      }
  }
 @override
 void dispose()
 {
   timer?.cancel();
   super.dispose();
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Time Complexity Quiz 1'), centerTitle: true),
      body: currentindex < quiz1.length ? BuildQuiz() : const SizedBox(),
    );
  }

  Widget BuildQuiz() {
    final question =quiz1[currentindex];
    return Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(
            'Time Left: $duration s',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text('Question ${currentindex+1}/${quiz1.length}',
          style:const TextStyle(fontSize:20),
          ),
          const SizedBox(height: 30,),
          Text(
            question.QuestionText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 30,),
          ...List.generate(question.Options.length, (index){
            return Container(
              width: double.infinity,
              margin: const EdgeInsetsGeometry.symmetric(vertical: 8),
              child: ElevatedButton(
                  onPressed: ()=>answer(index),
                  child: Text(question.Options[index]),
              ),
            );
          })
        ],
      ),
    );
  }
}
