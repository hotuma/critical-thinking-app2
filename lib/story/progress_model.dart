import 'package:flutter/material.dart';

class StoryProgress with ChangeNotifier {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  List<int?> selectedAnswers = [];

  void selectAnswer(int index, int correctIndex) {
    selectedAnswers.add(index);
    if (index == correctIndex) {
      correctAnswers++;
    }
    currentQuestionIndex++;
    notifyListeners();
  }

  void reset() {
    currentQuestionIndex = 0;
    correctAnswers = 0;
    selectedAnswers.clear();
    notifyListeners();
  }
} 