# 下一步开发指南

## 📋 当前状态

✅ **已完成**:
- UI页面框架搭建完成
- 所有核心页面已创建（首页、创建、详情、编辑、设置）
- 自定义UI组件完成
- 本地数据存储结构设计完成
- Mock数据生成器可用

⏳ **待完成**:
- 配置文件创建
- AI接口集成
- 图片功能实现

## 🚀 立即开始

### 1. 创建必需的配置文件

首先创建配置文件目录和文件：

```bash
# 创建配置目录
mkdir -p assets/configs
mkdir -p assets/prompts

# 创建styles.json
cat > assets/configs/styles.json << 'EOF'
{
  "styles": [
    {
      "id": "warm",
      "name": "温馨",
      "icon": "❤️",
      "description": "温柔细腻，充满爱意",
      "word_count_min": 300,
      "word_count_max": 500,
      "emoji_count": 3
    },
    {
      "id": "poetic",
      "name": "诗意",
      "icon": "🌙",
      "description": "文艺浪漫，富有诗意",
      "word_count_min": 400,
      "word_count_max": 600,
      "emoji_count": 2
    },
    {
      "id": "real",
      "name": "真实",
      "icon": "😊",
      "description": "口语化，原汁原味",
      "word_count_min": 200,
      "word_count_max": 400,
      "emoji_count": 4
    }
  ],
  "default_style": "warm"
}
EOF

# 创建defaults.json
cat > assets/configs/defaults.json << 'EOF'
{
  "default_style": "warm",
  "default_word_count": 400,
  "mood_tags": [
    {"id": "happy", "name": "开心", "emoji": "😊", "color": "#FFB74D"},
    {"id": "sweet", "name": "甜蜜", "emoji": "💕", "color": "#F06292"},
    {"id": "miss", "name": "想念", "emoji": "🥺", "color": "#64B5F6"},
    {"id": "excited", "name": "激动", "emoji": "🤩", "color": "#BA68C8"},
    {"id": "calm", "name": "平静", "emoji": "😌", "color": "#4DB6AC"}
  ],
  "input_placeholders": [
    "今天他给我买了奶茶，还记得少糖...",
    "一起看了日落，他说下次还要带我去海边...",
    "异地第37天，好想抱抱他...",
    "他今天发了很多表情包，笑死我了..."
  ]
}
EOF

# 创建base_diary.txt prompt
cat > assets/prompts/base_diary.txt << 'EOF'
你是一个温柔细腻的情感记录者，擅长将简短的记录扩写成感人的日记。

请基于以下信息生成一篇日记：
- 内容: {{content}}
- 风格: {{style}}
- 心情: {{mood}}

要求：
1. 保持原汁原味的情感
2. 适当扩充细节
3. 字数控制在300-500字
4. 使用Markdown格式
5. 适当添加emoji表情
EOF
```

### 2. 生成Hive适配器

```bash
cd /Users/wangshiwen/Desktop/workspace/diary_app
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. 运行应用测试

```bash
flutter run
```

或者在特定设备上运行：
```bash
# iOS模拟器
flutter run -d "iPhone 15 Pro"

# Chrome浏览器（调试用）
flutter run -d chrome

# 查看可用设备
flutter devices
```

## 📝 接下来要开发的功能

### A. AI接口集成（优先级最高）

1. **选择AI服务**
   - OpenAI GPT-4
   - Claude API
   - 国内大模型（通义千问、文心一言等）

2. **创建API Service**

在 `lib/data/services/` 创建 `ai_service.dart`:

```dart
import 'package:dio/dio.dart';

class AIService {
  final Dio _dio = Dio();
  final String apiKey = 'YOUR_API_KEY'; // 从环境变量读取
  
  Future<String> generateDiary({
    required String content,
    required String style,
    String? mood,
  }) async {
    // 调用AI API
    // 返回生成的日记内容
  }
}
```

3. **更新CreateDiaryPage**
   - 替换Mock实现
   - 添加错误处理
   - 添加重试机制

### B. 图片功能

1. **添加图片选择**
```dart
// 在CreateDiaryPage添加
import 'package:image_picker/image_picker.dart';

Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  // 处理图片
}
```

2. **图片存储**
   - 保存到本地文件系统
   - 或使用云存储服务

### C. Markdown渲染

在DiaryDetailPage添加Markdown显示：

```dart
import 'package:flutter_markdown/flutter_markdown.dart';

Markdown(
  data: diary.aiContent!,
  styleSheet: MarkdownStyleSheet.fromTheme(theme),
)
```

## 🔧 常用开发命令

```bash
# 安装依赖
flutter pub get

# 代码检查
flutter analyze

# 格式化代码
dart format lib/

# 清理缓存
flutter clean

# 重新构建
flutter pub get
flutter run

# 查看日志
flutter logs

# 热重载 (运行时按 r)
# 热重启 (运行时按 R)
```

## 📱 测试建议

### 功能测试清单
- [ ] 创建新日记
- [ ] 查看日记列表
- [ ] 查看日记详情
- [ ] 编辑日记
- [ ] 删除日记
- [ ] 选择心情
- [ ] 选择风格
- [ ] 分享日记
- [ ] 复制内容

### UI测试清单
- [ ] 深色/浅色主题切换
- [ ] 不同屏幕尺寸适配
- [ ] 滚动性能
- [ ] 动画流畅度

## 💡 开发技巧

1. **使用热重载**: 修改UI后按 `r` 即可看到效果
2. **使用DevTools**: `flutter pub global activate devtools`
3. **查看Widget树**: 启用Flutter Inspector
4. **性能分析**: 使用Performance Overlay

## 🐛 常见问题

### Q: Hive报错找不到适配器？
A: 运行 `flutter packages pub run build_runner build`

### Q: 配置文件找不到？
A: 确保在 `pubspec.yaml` 中正确配置了 assets

### Q: 图片不显示？
A: 检查pubspec.yaml中的assets配置

### Q: Hot reload不生效？
A: 有些改动需要Hot restart (按 R)

## 📚 参考资源

- [Flutter官方文档](https://flutter.dev/docs)
- [Riverpod文档](https://riverpod.dev)
- [Hive文档](https://docs.hivedb.dev)
- [Material 3设计](https://m3.material.io)

## 🎯 阶段性目标

### 第一阶段（当前）
- ✅ 完成UI框架
- ⏳ 创建配置文件
- ⏳ 测试基本功能

### 第二阶段
- [ ] AI接口集成
- [ ] 图片功能
- [ ] Markdown渲染

### 第三阶段
- [ ] 双视角功能
- [ ] 高光时刻
- [ ] 周年纪念

### 第四阶段
- [ ] 云端同步
- [ ] 数据导出
- [ ] 分享优化

---

💪 加油！项目已经搭建好基础框架，可以开始愉快地开发了！

有问题随时查看 `DEVELOPMENT_PROGRESS.md` 了解当前进度。
