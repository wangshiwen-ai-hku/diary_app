import 'dart:math';
import '../data/models/diary.dart';
import 'package:uuid/uuid.dart';

class MockDataGenerator {
  static final _uuid = Uuid();
  static final _random = Random();

  static List<Diary> generateDiaries(int count) {
    final now = DateTime.now();

    return List.generate(count, (index) {
      final date = now.subtract(Duration(days: index));

      return Diary(
        id: _uuid.v4(),
        date: date,
        type: _randomType(),
        rawContent: _randomContent(),
        aiContent: _generateMockMarkdown(date, index),
        mood: _randomMood(),
        style: 'warm',
        photos: [],
        tags: [],
        createdAt: date,
        isEdited: false,
      );
    });
  }

  static String _generateMockMarkdown(DateTime date, int index) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final contents = [
      """# $dateStr

今天又是充满温暖的一天。

虽然我们身在异地，但心却从未远离。他今天发来的消息让我笑了很久，那些看似平常的关心，其实都是爱的表达。

> "想你了" - 简单的三个字，却让整个世界都变得柔软。

期待下次见面的时刻。💕

---

*连续记录第${index + 1}天*
""",
      """# $dateStr

## 今天的小确幸

早上醒来看到他的早安消息，心情就变得很好。虽然只是简单的问候，但能感受到他的关心。

中午聊天的时候，他突然说想我了。这种突如其来的甜蜜，让人防不胜防。

> "等疫情结束，我们就去看海"

这个约定，我会一直记得。😊

---

*距离下次见面还有 X 天*
""",
      """# $dateStr

今天有点想他。

看到别人成双成对，突然就觉得有些孤单。给他发消息，他秒回了，还安慰我说很快就能见面了。

虽然分开很难受，但想到他也在努力等待，就觉得一切都值得。

异地恋真的很难，但因为是你，所以我愿意。💕
""",
    ];

    return contents[_random.nextInt(contents.length)];
  }

  static String _randomType() {
    final types = ['daily', 'sweet', 'highlight', 'quarrel', 'travel'];
    return types[_random.nextInt(types.length)];
  }

  static String _randomMood() {
    final moods = ['happy', 'sweet', 'miss', 'excited', 'calm'];
    return moods[_random.nextInt(moods.length)];
  }

  static String _randomContent() {
    final contents = [
      '今天他给我买了奶茶，还记得少糖',
      '一起看了日落，他说下次还要带我去海边',
      '吵架了，但他最后还是来哄我了',
      '异地第37天，好想抱抱他',
      '他今天发了很多表情包，笑死我了',
      '一起做饭，他把厨房搞得乱七八糟',
      '收到了他寄来的礼物，是我最喜欢的',
      '视频聊了三个小时，说着说着就困了',
    ];
    return contents[_random.nextInt(contents.length)];
  }

  // 生成单个日记的Mock AI内容
  static String generateMockAIDiary(String rawContent, String style) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return """# $dateStr

$rawContent

今天的这个瞬间，值得被好好记录下来。这些看似平凡的时刻，其实都是我们爱情中最珍贵的宝藏。

> 在一起的每一天，都是最好的一天。

愿我们的故事，一直这样温暖下去。💕

---

*AI已为你生成日记，你可以继续编辑完善*
""";
  }
}
