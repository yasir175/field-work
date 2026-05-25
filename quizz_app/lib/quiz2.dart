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

final List<Question> quiz2 = [
  Question(
    QuestionText: "Time complexity of inserting in array (middle):",
    Options: ["O(1)", "O(n)", "O(log n)", "O(n²)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of deleting from array (middle):",
    Options: ["O(1)", "O(n)", "O(log n)", "O(n²)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of stack push operation:",
    Options: ["O(1)", "O(n)", "O(log n)", "O(n log n)"],
    CorrectIndex: 0,
  ),
  Question(
    QuestionText: "Time complexity of stack pop operation:",
    Options: ["O(n)", "O(1)", "O(log n)", "O(n²)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of queue enqueue:",
    Options: ["O(1)", "O(n)", "O(log n)", "O(n log n)"],
    CorrectIndex: 0,
  ),
  Question(
    QuestionText: "Time complexity of BFS:",
    Options: ["O(V + E)", "O(V²)", "O(E log V)", "O(V log V)"],
    CorrectIndex: 0,
  ),
  Question(
    QuestionText: "Time complexity of DFS:",
    Options: ["O(V + E)", "O(V²)", "O(E²)", "O(log V)"],
    CorrectIndex: 0,
  ),
  Question(
    QuestionText: "Time complexity of finding max in unsorted array:",
    Options: ["O(log n)", "O(n)", "O(n log n)", "O(1)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of heap insert:",
    Options: ["O(1)", "O(log n)", "O(n)", "O(n log n)"],
    CorrectIndex: 1,
  ),
  Question(
    QuestionText: "Time complexity of heap delete (extract max/min):",
    Options: ["O(n)", "O(log n)", "O(n log n)", "O(1)"],
    CorrectIndex: 1,
  ),
];

class Quiz2 extends StatefulWidget {
  const Quiz2({super.key});

  @override
  State<Quiz2> createState() => _Quiz2();
}

class _Quiz2 extends State<Quiz2> {
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
    if (quiz2[currentindex].CorrectIndex == index) {
      score++;
    }
    setState(() {
      currentindex++;
    });
    if (currentindex == quiz2.length) {
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
      appBar: AppBar(title: Text('Time Complexity Quiz 2'), centerTitle: true),
      body: currentindex < quiz2.length ? BuildQuiz() : const SizedBox(),
    );
  }

  Widget BuildQuiz() {
    final question =quiz2[currentindex];
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

          Text('Question ${currentindex+1}/${quiz2.length}',
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
