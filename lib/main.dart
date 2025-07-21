import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'story/story_data.dart';
import 'story/story_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // タイムゾーンデータの初期化
  tz.initializeTimeZones();
  
  // 通知の初期化
  await NotificationService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '本日のお題',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CriticalThinkingHomePage(),
    );
  }
}

const List<String> defaultTopics = [
  'なぜ信号は赤・黄・青なのか？',
  'なぜ人は朝ごはんを食べるのか？',
  'なぜ学校は月曜日から始まるのか？',
  'なぜ電車は時間通りに来るのか？',
  'なぜお金が必要なのか？',
  'なぜ天気予報は外れることがあるのか？',
  'なぜスマホは毎日充電が必要なのか？',
  'なぜゴミは分別するのか？',
  'なぜ日本語には敬語があるのか？',
  'なぜ地球は丸いのか？',
];

class CriticalThinkingHomePage extends StatefulWidget {
  const CriticalThinkingHomePage({super.key});

  @override
  State<CriticalThinkingHomePage> createState() => _CriticalThinkingHomePageState();
}

class _CriticalThinkingHomePageState extends State<CriticalThinkingHomePage> {
  List<String> topics = [];
  late String todayTopic;
  int currentTopicIndex = 0; // 現在表示中のお題のインデックス
  TextEditingController memoController = TextEditingController();
  bool isLoading = true;
  bool isNotificationEnabled = false;
  TimeOfDay notificationTime = const TimeOfDay(hour: 9, minute: 0);

  String get todayKey {
    final now = DateTime.now();
    return 'memo_${now.year}_${now.month}_${now.day}';
  }

  String get currentTopicKey {
    return 'memo_topic_$currentTopicIndex';
  }

  @override
  void initState() {
    super.initState();
    loadTopicsAndMemo();
    loadNotificationSettings();
  }

  Future<void> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationEnabled = prefs.getBool('notification_enabled') ?? false;
      final hour = prefs.getInt('notification_hour') ?? 9;
      final minute = prefs.getInt('notification_minute') ?? 0;
      notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', isNotificationEnabled);
    await prefs.setInt('notification_hour', notificationTime.hour);
    await prefs.setInt('notification_minute', notificationTime.minute);
  }

  Future<void> toggleNotification() async {
    setState(() {
      isNotificationEnabled = !isNotificationEnabled;
    });
    
    if (isNotificationEnabled) {
      await NotificationService().scheduleDailyNotification(
        hour: notificationTime.hour,
        minute: notificationTime.minute,
      );
    } else {
      await NotificationService().cancelNotification();
    }
    
    await saveNotificationSettings();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNotificationEnabled ? '通知を有効にしました' : '通知を無効にしました'),
      ),
    );
  }

  Future<void> selectNotificationTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );
    
    if (newTime != null) {
      setState(() {
        notificationTime = newTime;
      });
      
      if (isNotificationEnabled) {
        await NotificationService().cancelNotification();
        await NotificationService().scheduleDailyNotification(
          hour: notificationTime.hour,
          minute: notificationTime.minute,
        );
      }
      
      await saveNotificationSettings();
    }
  }

  Future<void> loadTopicsAndMemo() async {
    setState(() { isLoading = true; });
    final prefs = await SharedPreferences.getInstance();
    // お題リストの取得
    final topicsJson = prefs.getString('topics');
    if (topicsJson == null) {
      // 初回のみデフォルトリストを保存
      topics = List<String>.from(defaultTopics);
      await prefs.setString('topics', jsonEncode(topics));
    } else {
      topics = List<String>.from(jsonDecode(topicsJson));
    }
    
    // 今日のお題のインデックスを計算
    final now = DateTime.now();
    currentTopicIndex = (now.year * 10000 + now.month * 100 + now.day) % topics.length;
    todayTopic = topics[currentTopicIndex];
    
    // 現在のお題のメモを読み込み
    memoController.text = prefs.getString(currentTopicKey) ?? '';
    setState(() { isLoading = false; });
  }

  String getTodayTopic() {
    final now = DateTime.now();
    if (topics.isEmpty) return 'お題がありません';
    int index = (now.year * 10000 + now.month * 100 + now.day) % topics.length;
    return topics[index];
  }

  Future<void> saveMemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentTopicKey, memoController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('メモを保存しました')),
    );
  }

  Future<void> nextTopic() async {
    if (topics.isEmpty) return;
    
    // 現在のメモを保存
    await saveMemo();
    
    setState(() {
      currentTopicIndex = (currentTopicIndex + 1) % topics.length;
      todayTopic = topics[currentTopicIndex];
    });
    
    // 新しいお題のメモを読み込み
    final prefs = await SharedPreferences.getInstance();
    memoController.text = prefs.getString(currentTopicKey) ?? '';
  }

  Future<void> randomTopic() async {
    if (topics.isEmpty) return;
    
    // 現在のメモを保存
    await saveMemo();
    
    setState(() {
      currentTopicIndex = (currentTopicIndex + 1 + (DateTime.now().millisecondsSinceEpoch % (topics.length - 1))) % topics.length;
      todayTopic = topics[currentTopicIndex];
    });
    
    // 新しいお題のメモを読み込み
    final prefs = await SharedPreferences.getInstance();
    memoController.text = prefs.getString(currentTopicKey) ?? '';
  }

  Future<void> backToTodayTopic() async {
    if (topics.isEmpty) return;
    
    // 現在のメモを保存
    await saveMemo();
    
    setState(() {
      currentTopicIndex = (DateTime.now().year * 10000 + DateTime.now().month * 100 + DateTime.now().day) % topics.length;
      todayTopic = topics[currentTopicIndex];
    });
    
    // 今日のお題のメモを読み込み
    final prefs = await SharedPreferences.getInstance();
    memoController.text = prefs.getString(currentTopicKey) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本日のお題'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TopicEditPage(topics: List<String>.from(topics)),
                ),
              );
              if (result != null) {
                setState(() {
                  topics = result;
                  todayTopic = getTodayTopic();
                });
                // お題リストを保存
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('topics', jsonEncode(topics));
              }
            },
            tooltip: 'お題リスト編集',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todayTopic,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text('あなたの考えをメモしましょう'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: memoController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ここに入力...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveMemo,
                      child: const Text('保存'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // お題切り替えボタン
                  const Text('お題を切り替える', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: nextTopic,
                          child: const Text('次のお題'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: randomTopic,
                          child: const Text('ランダム'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: backToTodayTopic,
                      child: const Text('今日のお題に戻る'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ストーリーモードセクション
                  const Text('ストーリーモード', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryPage(chapter: StoryData.getChapter1()),
                          ),
                        );
                      },
                      icon: Icon(Icons.book),
                      label: Text('ストーリーモードを開始'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue, // ボタンの背景色を明示的に設定
                        foregroundColor: Colors.white, // ボタンの文字色を明示的に設定
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 通知設定セクション
                  const Text('通知設定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('毎日の通知'),
                                    Text(
                                      '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: isNotificationEnabled,
                                onChanged: (value) => toggleNotification(),
                              ),
                            ],
                          ),
                          if (isNotificationEnabled) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: selectNotificationTime,
                                child: const Text('通知時間を変更'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TopicEditPage extends StatefulWidget {
  final List<String> topics;
  
  const TopicEditPage({super.key, required this.topics});

  @override
  State<TopicEditPage> createState() => _TopicEditPageState();
}

class _TopicEditPageState extends State<TopicEditPage> {
  late List<String> topics;
  final TextEditingController addController = TextEditingController();
  final TextEditingController editController = TextEditingController();
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    topics = List<String>.from(widget.topics);
  }

  void addTopic() {
    if (addController.text.trim().isNotEmpty) {
      setState(() {
        topics.add(addController.text.trim());
        addController.clear();
      });
    }
  }

  void startEdit(int index) {
    setState(() {
      editingIndex = index;
      editController.text = topics[index];
    });
  }

  void saveEdit() {
    if (editingIndex != null && editController.text.trim().isNotEmpty) {
      setState(() {
        topics[editingIndex!] = editController.text.trim();
        editingIndex = null;
        editController.clear();
      });
    }
  }

  void cancelEdit() {
    setState(() {
      editingIndex = null;
      editController.clear();
    });
  }

  void deleteTopic(int index) {
    setState(() {
      topics.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お題リスト編集'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, topics),
            child: const Text('完了'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // お題追加セクション
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addController,
                    decoration: const InputDecoration(
                      labelText: '新しいお題',
                      hintText: '例：なぜ空は青いのか？',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addTopic,
                  child: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // お題一覧
            Expanded(
              child: ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  if (editingIndex == index) {
                    // 編集モード
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: editController,
                                decoration: const InputDecoration(
                                  labelText: 'お題を編集',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: saveEdit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: cancelEdit,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // 表示モード
                    return Card(
                      child: ListTile(
                        title: Text(topics[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => startEdit(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTopic(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      0, // 通知ID
      '本日のお題',
      '今日もクリティカルシンキングを鍛えましょう！',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'critical_thinking_channel',
          'クリティカルシンキング',
          channelDescription: '毎日のお題通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> cancelNotification() async {
    await _notifications.cancel(0);
  }

  Future<bool> isNotificationScheduled() async {
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    return pendingNotifications.any((notification) => notification.id == 0);
  }
}
