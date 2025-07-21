import 'package:flutter/material.dart';
import 'models.dart';
import 'question_card.dart';
import 'progress_model.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatelessWidget {
  final StoryChapter chapter;

  const StoryPage({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProgress(),
      child: Consumer<StoryProgress>(
        builder: (context, progress, _) {
          return Scaffold(
            appBar: AppBar(title: Text(chapter.title)),
            body: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(chapter.narrative, style: TextStyle(fontSize: 18)),
                SizedBox(height: 24),
                ...chapter.questions.map((q) => QuestionCard(question: q)).toList(),
                SizedBox(height: 24),
                Text('正解数: ${progress.correctAnswers} / ${chapter.questions.length}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
} 