import 'models.dart';

class StoryData {
  static StoryChapter getChapter1() {
    return StoryChapter(
      title: '第1話：謎の手紙',
      narrative: '''
あなたは探偵事務所で働く新人探偵です。ある日、謎めいた手紙が届きました。

「明日の午後3時、中央公園のベンチで待っています。重要な話があります。署名：M」

手紙には他に何も書かれていませんでした。あなたはこの手紙の真偽を確かめるために、様々な角度から考えを巡らせる必要があります。

この物語を通じて、あなたのクリティカルシンキング力を試してみましょう。各問題で最も論理的な選択肢を選んでください。
''',
      questions: [
        ThinkingQuestion(
          questionText: '手紙の内容を分析する際、最初に確認すべきことは何でしょうか？',
          choices: [
            '手紙の筆跡を分析する',
            '手紙の用紙の種類を調べる',
            '差出人の身元を調べる',
            '手紙の内容の真偽を確認する'
          ],
          correctIndex: 3,
          explanation: '手紙の内容が真実かどうかを確認することが最も重要です。偽の手紙であれば、他の分析は無意味になります。',
        ),
        ThinkingQuestion(
          questionText: '手紙に書かれた「M」という署名について、どのような仮説が考えられますか？',
          choices: [
            '必ず本名の頭文字である',
            '偽名の可能性がある',
            '偶然の一致である',
            '手紙の内容と無関係である'
          ],
          correctIndex: 1,
          explanation: '「M」は偽名の可能性が高いです。本名を隠したい理由がある可能性があります。',
        ),
        ThinkingQuestion(
          questionText: '中央公園のベンチで待ち合わせるという設定について、どのようなリスクが考えられますか？',
          choices: [
            '天候の影響を受ける',
            '人目につきやすい場所である',
            '危険な場所である',
            '交通の便が悪い'
          ],
          correctIndex: 1,
          explanation: '公園は人目につきやすい場所なので、犯罪を企てる者にとっては不都合な場所です。',
        ),
        ThinkingQuestion(
          questionText: '手紙の差出人が本当に重要な話がある場合、なぜ手紙で連絡を取ったのでしょうか？',
          choices: [
            '電話が使えないから',
            '匿名性を保ちたいから',
            '手紙の方が正式だから',
            '時間をかけて考えてもらいたいから'
          ],
          correctIndex: 1,
          explanation: '重要な話がある場合、匿名性を保ちたいという理由が最も論理的です。',
        ),
        ThinkingQuestion(
          questionText: 'この手紙に対する最も適切な対応は何でしょうか？',
          choices: [
            'すぐに約束の場所に行く',
            '手紙を無視する',
            '警察に相談する',
            '事前に調査してから判断する'
          ],
          correctIndex: 3,
          explanation: '事前に調査してから判断することが最も安全で論理的な対応です。',
        ),
        ThinkingQuestion(
          questionText: '手紙の内容が真実である可能性を高める要素は何でしょうか？',
          choices: [
            '手紙の用紙が高級である',
            '筆跡が美しい',
            '具体的な日時が記載されている',
            '手紙の長さが適切である'
          ],
          correctIndex: 2,
          explanation: '具体的な日時が記載されていることは、差出人が真剣に考えていることを示します。',
        ),
        ThinkingQuestion(
          questionText: '手紙の差出人が悪意を持っている可能性を判断するために、最も重要な情報は何でしょうか？',
          choices: [
            '手紙の用紙の種類',
            '差出人の過去の行動',
            '手紙の内容の詳細',
            '手紙の配達方法'
          ],
          correctIndex: 1,
          explanation: '差出人の過去の行動を知ることが、その人の意図を判断する最も重要な情報です。',
        ),
        ThinkingQuestion(
          questionText: '手紙の内容が偽物である可能性を高める要素は何でしょうか？',
          choices: [
            '手紙が短すぎる',
            '差出人の名前が不明',
            '約束の場所が公共の場所',
            '手紙の内容が曖昧すぎる'
          ],
          correctIndex: 3,
          explanation: '手紙の内容が曖昧すぎることは、差出人が真剣でないことを示す可能性があります。',
        ),
        ThinkingQuestion(
          questionText: 'この手紙に対する感情的な反応を避けるために、どのような態度を取るべきでしょうか？',
          choices: [
            '好奇心を抑える',
            '恐怖心を克服する',
            '興奮を抑える',
            '客観的な視点を保つ'
          ],
          correctIndex: 3,
          explanation: '客観的な視点を保つことが、感情的な判断を避けるために最も重要です。',
        ),
        ThinkingQuestion(
          questionText: '最終的にこの手紙に応じるかどうかを決める際、最も重視すべき基準は何でしょうか？',
          choices: [
            '好奇心',
            '安全性',
            '効率性',
            '経済性'
          ],
          correctIndex: 1,
          explanation: '安全性を最優先に考えることが、探偵として最も重要な判断基準です。',
        ),
      ],
    );
  }
} 