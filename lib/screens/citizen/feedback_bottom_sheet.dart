import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/citizen_colors.dart';

// TODO: Replace with your actual Gemini API key
const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? question;
  List<String> options = [];
  String? correctAnswer;
  String? selectedAnswer;
  String feedback = '';
  int score = 0;
  int timer = 15;
  Timer? countdown;
  bool loading = false;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  Future<void> fetchQuestion() async {
    setState(() {
      loading = true;
      question = null;
      options = [];
      correctAnswer = null;
      selectedAnswer = null;
      feedback = '';
      timer = 15;
      answered = false;
    });
    countdown?.cancel();

    // Gemini prompt for trivia
    final prompt =
        'Give me a single random trivia or general knowledge question with 4 options and the correct answer. Respond in JSON: {"question": "...", "options": ["A", "B", "C", "D"], "answer": "A"}';

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        final jsonData = jsonDecode(text);
        setState(() {
          question = jsonData['question'];
          options = List<String>.from(jsonData['options']);
          correctAnswer = jsonData['answer'];
          loading = false;
        });
        startTimer();
      } catch (e) {
        setState(() {
          question = 'Failed to parse question.';
          loading = false;
        });
      }
    } else {
      setState(() {
        question = 'Failed to fetch question.';
        loading = false;
      });
    }
  }

  void startTimer() {
    countdown?.cancel();
    timer = 15;
    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timer--;
        if (timer == 0) {
          t.cancel();
          answered = true;
          feedback = 'Time\'s up! Correct answer: $correctAnswer';
        }
      });
    });
  }

  void selectAnswer(String answer) {
    if (answered) return;
    setState(() {
      selectedAnswer = answer;
      answered = true;
      countdown?.cancel();
      if (answer == correctAnswer) {
        feedback = 'Correct!';
        score++;
      } else {
        feedback = 'Incorrect! Correct answer: $correctAnswer';
      }
    });
  }

  void playAgain() {
    fetchQuestion();
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Question Quiz'),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Score: $score', style: TextStyle(fontSize: 20.sp)),
                    SizedBox(height: 20.h),
                    if (question != null)
                      Text(
                        question!,
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 30.h),
                    if (options.isNotEmpty)
                      ...options.map((opt) => Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 6.h),
                            child: ElevatedButton(
                              onPressed: answered ? null : () => selectAnswer(opt),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedAnswer == opt
                                    ? (opt == correctAnswer ? Colors.green : Colors.red)
                                    : Colors.deepPurple,
                      foregroundColor: CitizenColors.light,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                              ),
                              child: Text(opt, style: TextStyle(fontSize: 18.sp)),
                            ),
                          )),
                    SizedBox(height: 20.h),
                    Text('Time left: $timer s', style: TextStyle(fontSize: 18.sp)),
                    SizedBox(height: 20.h),
                    if (feedback.isNotEmpty)
                      Text(
                        feedback,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: feedback.startsWith('Correct') ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 30.h),
                    ElevatedButton.icon(
                      onPressed: loading ? null : playAgain,
                      icon: Icon(Icons.refresh),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                  foregroundColor: CitizenColors.light,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 