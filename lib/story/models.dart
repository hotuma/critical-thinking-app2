class ThinkingQuestion {
  final String questionText;
  final List<String> choices;
  final int correctIndex;
  final String explanation;

  ThinkingQuestion({
    required this.questionText,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });
}

class StoryChapter {
  final String title;
  final String narrative;
  final List<ThinkingQuestion> questions;

  StoryChapter({
    required this.title,
    required this.narrative,
    required this.questions,
  });
} 