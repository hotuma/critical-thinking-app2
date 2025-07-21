import 'package:flutter/material.dart';
import 'models.dart';
import 'progress_model.dart';
import 'package:provider/provider.dart';

class QuestionCard extends StatelessWidget {
  final ThinkingQuestion question;

  const QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<StoryProgress>(context);
    final selected = progress.selectedAnswers.length > progress.currentQuestionIndex
        ? progress.selectedAnswers[progress.currentQuestionIndex]
        : null;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.questionText, style: TextStyle(fontSize: 16)),
            ...List.generate(question.choices.length, (index) {
              return RadioListTile<int>(
                title: Text(question.choices[index]),
                value: index,
                groupValue: selected,
                onChanged: selected == null
                    ? (value) {
                        progress.selectAnswer(value!, question.correctIndex);
                      }
                    : null,
              );
            }),
            if (selected != null)
              Text(
                selected == question.correctIndex
                    ? '正解！'
                    : '不正解：${question.explanation}',
                style: TextStyle(
                  color: selected == question.correctIndex ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 