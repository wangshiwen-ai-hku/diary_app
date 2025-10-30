# 情侣AI日记 - 技术实现方案

## 架构设计原则

### 核心思想
1. **配置外置化** - Prompt、样式、默认值都可热更新
2. **离线优先** - 先本地开发，后端最后接入
3. **易于调试** - 模块化、Mock数据、日志完善
4. **用户体验至上** - 精美UI、流畅动画、快速响应

---

## 一、配置管理系统

### 1.1 Prompt配置文件结构

```
assets/
  prompts/
    base_diary.txt          # 基础日记生成
    highlight_moment.txt    # 高光时刻
    dual_perspective.txt    # 双视角合成
    anniversary.txt         # 周年纪念
    quarrel_resolve.txt     # 和解日记
    travel_log.txt          # 旅行日记
  
  configs/
    styles.json            # 风格配置
    moods.json            # 心情标签
    templates.json        # 场景模板
    defaults.json         # 默认值配置
    ui_theme.json         # UI主题配置
```

### 1.2 Prompt模板格式（支持变量替换）

**base_diary.txt**
```
# 基础日记生成Prompt

## 角色设定
你是一个温柔细腻的情感记录者，擅长将简短的记录扩写成感人的日记。

## 输入信息
- 记录内容: {{content}}
- 记录类型: {{type}}
- 用户性别: {{gender}}
- 对方昵称: {{partner_name}}
- 风格偏好: {{style}}
- 心情: {{mood}}
- 日期: {{date}}

## 输出要求
1. 字数: {{word_count_min}}-{{word_count_max}}字
2. 风格特征:
   {{#if style == '温馨'}}
   - 语气温柔，多用柔和词汇
   - 强调细节和关怀
   - 结尾要有温暖感悟
   {{/if}}
   {{#if style == '诗意'}}
   - 使用文学化表达
   - 适当引用诗句或优美语言
   - 注重意境营造
   {{/if}}
   {{#if style == '真实'}}
   - 口语化表达
   - 保持原汁原味
   - 不过度修饰
   {{/if}}

3. 格式要求:
   - 输出Markdown格式
   - 适当使用emoji（不超过{{emoji_count}}个）
   - 段落清晰，使用空行分隔

## 示例参考
{{example_diary}}

## 开始生成
请基于以上信息，生成一篇{{style}}风格的日记。
```

### 1.3 配置加载管理器

```dart
// lib/core/config_manager.dart

class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  factory ConfigManager() => _instance;
  ConfigManager._internal();
  
  // 缓存配置
  Map<String, dynamic> _configs = {};
  Map<String, String> _prompts = {};
  
  // 初始化配置
  Future<void> init() async {
    await _loadPrompts();
    await _loadConfigs();
  }
  
  // 加载Prompt文件
  Future<void> _loadPrompts() async {
    final promptFiles = [
      'base_diary',
      'highlight_moment',
      'dual_perspective',
      'anniversary',
      'quarrel_resolve',
      'travel_log',
    ];
    
    for (var file in promptFiles) {
      _prompts[file] = await rootBundle.loadString(
        'assets/prompts/$file.txt'
      );
    }
  }
  
  // 加载JSON配置
  Future<void> _loadConfigs() async {
    _configs['styles'] = await _loadJson('assets/configs/styles.json');
    _configs['moods'] = await _loadJson('assets/configs/moods.json');
    _configs['defaults'] = await _loadJson('assets/configs/defaults.json');
    _configs['templates'] = await _loadJson('assets/configs/templates.json');
  }
  
  // 获取Prompt（支持变量替换）
  String getPrompt(String name, Map<String, dynamic> variables) {
    String prompt = _prompts[name] ?? '';
    
    // 简单变量替换
    variables.forEach((key, value) {
      prompt = prompt.replaceAll('{{$key}}', value.toString());
    });
    
    // 条件语句处理（简化版）
    prompt = _processConditionals(prompt, variables);
    
    return prompt;
  }
  
  // 获取配置
  dynamic getConfig(String category, [String key]) {
    if (key == null) return _configs[category];
    return _configs[category]?[key];
  }
  
  // 热更新（从服务器拉取最新配置）
  Future<void> hotUpdate() async {
    // TODO: 从服务器拉取配置
    // 可以实现A/B测试不同的Prompt
  }
}
```

### 1.4 配置文件示例

**styles.json**
```json
{
  "styles": [
    {
      "id": "warm",
      "name": "温馨",
      "icon": "❤️",
      "description": "温柔细腻，充满爱意",
      "word_count_min": 300,
      "word_count_max": 500,
      "emoji_count": 3,
      "tone": "gentle",
      "example_keywords": ["温暖", "关怀", "幸福", "珍惜"]
    },
    {
      "id": "poetic",
      "name": "诗意",
      "icon": "🌙",
      "description": "文艺浪漫，富有诗意",
      "word_count_min": 400,
      "word_count_max": 600,
      "emoji_count": 2,
      "tone": "literary",
      "example_keywords": ["月光", "星辰", "时光", "温柔"]
    },
    {
      "id": "real",
      "name": "真实",
      "icon": "😊",
      "description": "口语化，原汁原味",
      "word_count_min": 200,
      "word_count_max": 400,
      "emoji_count": 4,
      "tone": "casual",
      "example_keywords": ["今天", "我们", "哈哈", "开心"]
    },
    {
      "id": "funny",
      "name": "搞笑",
      "icon": "😄",
      "description": "幽默风趣，逗趣可爱",
      "word_count_min": 250,
      "word_count_max": 450,
      "emoji_count": 5,
      "tone": "humorous",
      "example_keywords": ["哈哈", "傻", "笑死", "可爱"]
    }
  ],
  "default_style": "warm"
}
```

**defaults.json**
```json
{
  "input_placeholders": [
    "今天他给我买了奶茶，还记得少糖 🥤",
    "一起看了日落，他说下次还要带我去海边 🌅",
    "吵架了，但他最后还是来哄我了 😤",
    "异地第37天，好想抱抱他 🤗",
    "他今天发了很多表情包，笑死我了 😂",
    "一起做饭，他把厨房搞得乱七八糟 🍳",
    "收到了他寄来的礼物，是我最喜欢的 🎁",
    "视频聊了三个小时，说着说着就困了 😴",
    "他记得我随口说过想吃的东西 💝",
    "今天纪念日，他准备了惊喜 🎉"
  ],
  "mood_tags": [
    {"id": "happy", "name": "开心", "emoji": "😊", "color": "#FFD93D"},
    {"id": "sweet", "name": "甜蜜", "emoji": "💕", "color": "#FF6B9D"},
    {"id": "miss", "name": "想念", "emoji": "🥺", "color": "#AEC6CF"},
    {"id": "excited", "name": "激动", "emoji": "🤩", "color": "#FF8C42"},
    {"id": "calm", "name": "平静", "emoji": "😌", "color": "#C4E538"},
    {"id": "sad", "name": "难过", "emoji": "😢", "color": "#B8B8D1"},
    {"id": "angry", "name": "生气", "emoji": "😤", "color": "#FF6B6B"}
  ],
  "diary_types": [
    {
      "id": "daily",
      "name": "日常随笔",
      "icon": "📝",
      "prompt_template": "base_diary",
      "default_style": "real"
    },
    {
      "id": "sweet",
      "name": "甜蜜时刻",
      "icon": "💕",
      "prompt_template": "base_diary",
      "default_style": "warm"
    },
    {
      "id": "highlight",
      "name": "高光时刻",
      "icon": "🎉",
      "prompt_template": "highlight_moment",
      "default_style": "poetic"
    },
    {
      "id": "quarrel",
      "name": "小吵小闹",
      "icon": "😤",
      "prompt_template": "quarrel_resolve",
      "default_style": "real"
    },
    {
      "id": "travel",
      "name": "旅行记录",
      "icon": "✈️",
      "prompt_template": "travel_log",
      "default_style": "poetic"
    }
  ]
}
```

---

## 二、数据层架构（离线优先）

### 2.1 三层数据架构

```
UI Layer (Flutter Widgets)
    ↓
Business Logic Layer (BLoC/Riverpod)
    ↓
Repository Layer (数据仓库)
    ↓ ↙        ↘
Local DB    Mock Data    Remote API
(Hive)      (开发用)     (后期接入)
```

### 2.2 数据仓库接口设计

```dart
// lib/data/repositories/diary_repository.dart

abstract class DiaryRepository {
  Future<List<Diary>> getDiaries({int? limit, DateTime? startDate});
  Future<Diary> getDiary(String id);
  Future<Diary> createDiary(DiaryInput input);
  Future<Diary> updateDiary(String id, DiaryUpdate update);
  Future<void> deleteDiary(String id);
  Future<String> generateAIDiary(DiaryInput input);
}

// 本地实现（开发阶段使用）
class LocalDiaryRepository implements DiaryRepository {
  final HiveInterface _hive;
  
  @override
  Future<List<Diary>> getDiaries({int? limit, DateTime? startDate}) async {
    final box = await _hive.openBox<Diary>('diaries');
    var diaries = box.values.toList();
    
    if (startDate != null) {
      diaries = diaries.where((d) => d.date.isAfter(startDate)).toList();
    }
    
    diaries.sort((a, b) => b.date.compareTo(a.date));
    
    if (limit != null) {
      diaries = diaries.take(limit).toList();
    }
    
    return diaries;
  }
  
  @override
  Future<String> generateAIDiary(DiaryInput input) async {
    // Mock AI生成（开发阶段）
    await Future.delayed(Duration(seconds: 2)); // 模拟网络延迟
    return _mockGenerate(input);
  }
  
  String _mockGenerate(DiaryInput input) {
    // 简单的mock逻辑
    return """
# ${input.date.toString().split(' ')[0]}

${input.content}

---

*这是一段AI生成的温馨日记内容...*

今天的点点滴滴都值得记录。${input.content} 这样的时刻，让我觉得特别幸福。

愿我们的每一天，都能这样简单而美好。💕
""";
  }
}

// 远程实现（后期接入）
class RemoteDiaryRepository implements DiaryRepository {
  final ApiClient _api;
  final LocalDiaryRepository _localRepo; // 缓存层
  
  @override
  Future<String> generateAIDiary(DiaryInput input) async {
    try {
      final result = await _api.post('/ai/generate', input.toJson());
      return result['content'];
    } catch (e) {
      // 失败时降级到本地mock
      return _localRepo.generateAIDiary(input);
    }
  }
}

// 数据源切换器
class DiaryRepositoryFactory {
  static DiaryRepository create({bool useMock = true}) {
    if (useMock || !kReleaseMode) {
      return LocalDiaryRepository(Hive);
    } else {
      return RemoteDiaryRepository(ApiClient(), LocalDiaryRepository(Hive));
    }
  }
}
```

### 2.3 开发环境配置

```dart
// lib/config/app_config.dart

class AppConfig {
  static const bool USE_MOCK_DATA = true; // 开发时设为true
  static const bool ENABLE_AI_GENERATION = false; // 真正接入AI前设为false
  static const bool USE_LOCAL_DB = true; // 优先使用本地数据库
  
  // 方便切换环境
  static DiaryRepository getDiaryRepo() {
    return DiaryRepositoryFactory.create(useMock: USE_MOCK_DATA);
  }
}
```

---

## 三、日记编辑系统

### 3.1 Markdown编辑器集成

```dart
// lib/widgets/diary_editor.dart

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:markdown/markdown.dart' as md;

class DiaryEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String) onSave;
  final bool aiGenerated;
  
  @override
  _DiaryEditorState createState() => _DiaryEditorState();
}

class _DiaryEditorState extends State<DiaryEditor> {
  late quill.QuillController _controller;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController(
      document: quill.Document.fromMarkdown(widget.initialContent ?? ''),
      selection: TextSelection.collapsed(offset: 0),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        if (_isEditing) _buildToolbar(),
        
        // 编辑/预览区
        Expanded(
          child: _isEditing
              ? _buildEditor()
              : _buildPreview(),
        ),
        
        // 底部操作按钮
        _buildActions(),
      ],
    );
  }
  
  Widget _buildToolbar() {
    return quill.QuillToolbar.simple(
      configurations: quill.QuillSimpleToolbarConfigurations(
        controller: _controller,
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: false,
        showListBullets: true,
        showQuote: true,
        showLink: false,
        showCodeBlock: false,
      ),
    );
  }
  
  Widget _buildEditor() {
    return Container(
      padding: EdgeInsets.all(16),
      child: quill.QuillEditor.basic(
        configurations: quill.QuillEditorConfigurations(
          controller: _controller,
          placeholder: '记录今天的美好...',
        ),
      ),
    );
  }
  
  Widget _buildPreview() {
    final markdown = _controller.document.toMarkdown();
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: MarkdownBody(
        data: markdown,
        styleSheet: _getMarkdownStyle(context),
      ),
    );
  }
  
  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          if (widget.aiGenerated)
            TextButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('重新生成'),
              onPressed: _regenerate,
            ),
          Spacer(),
          TextButton(
            child: Text(_isEditing ? '预览' : '编辑'),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            child: Text('保存'),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
  
  void _save() {
    final markdown = _controller.document.toMarkdown();
    widget.onSave(markdown);
  }
  
  void _regenerate() {
    // TODO: 调用AI重新生成
  }
}
```

### 3.2 Markdown样式配置

```dart
// lib/ui/theme/markdown_theme.dart

MarkdownStyleSheet _getMarkdownStyle(BuildContext context) {
  final theme = Theme.of(context);
  
  return MarkdownStyleSheet(
    p: TextStyle(
      fontSize: 16,
      height: 1.8,
      color: theme.colorScheme.onSurface,
      fontFamily: 'SourceHanSerifCN', // 思源宋体
    ),
    h1: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.5,
      color: theme.colorScheme.primary,
    ),
    h2: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    blockquote: TextStyle(
      fontSize: 16,
      fontStyle: FontStyle.italic,
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    ),
    blockquoteDecoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
      border: Border(
        left: BorderSide(
          color: theme.colorScheme.primary,
          width: 4,
        ),
      ),
    ),
    code: TextStyle(
      fontFamily: 'Courier',
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      fontSize: 14,
    ),
    em: TextStyle(
      fontStyle: FontStyle.italic,
      color: theme.colorScheme.secondary,
    ),
    strong: TextStyle(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    ),
  );
}
```

---

## 四、UI主题系统

### 4.1 主题配置

```dart
// lib/ui/theme/app_theme.dart

class AppTheme {
  // 主题色列表
  static final themes = {
    'green': _createTheme(AppColors.green),
    'yellow': _createTheme(AppColors.yellow),
    'pink': _createTheme(AppColors.pink),
    'blue': _createTheme(AppColors.blue),
    'black': _createTheme(AppColors.black),
  };
  
  static ThemeData _createTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // 字体配置
      fontFamily: 'SourceHanSansCN', // 默认使用思源黑体
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SourceHanSerifCN', // 标题用宋体
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.7,
          letterSpacing: 0.5,
        ),
      ),
      
      // 圆角配置
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 大圆角
        ),
      ),
      
      // 按钮样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: colorScheme.primary.withOpacity(0.3),
        ),
      ),
      
      // 输入框样式
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

// 颜色配置
class AppColors {
  // 浅绿主题
  static final green = ColorScheme.light(
    primary: Color(0xFF81C784),
    secondary: Color(0xFFA5D6A7),
    surface: Color(0xFFF1F8E9),
    onPrimary: Colors.white,
    onSurface: Color(0xFF2E3B2E),
  );
  
  // 浅黄主题
  static final yellow = ColorScheme.light(
    primary: Color(0xFFFFD54F),
    secondary: Color(0xFFFFE082),
    surface: Color(0xFFFFFDE7),
    onPrimary: Color(0xFF5D4037),
    onSurface: Color(0xFF3E2723),
  );
  
  // 粉色主题
  static final pink = ColorScheme.light(
    primary: Color(0xFFF48FB1),
    secondary: Color(0xFFF8BBD0),
    surface: Color(0xFFFCE4EC),
    onPrimary: Colors.white,
    onSurface: Color(0xFF880E4F),
  );
  
  // 浅蓝主题
  static final blue = ColorScheme.light(
    primary: Color(0xFF64B5F6),
    secondary: Color(0xFF90CAF9),
    surface: Color(0xFFE3F2FD),
    onPrimary: Colors.white,
    onSurface: Color(0xFF1565C0),
  );
  
  // 黑色主题
  static final black = ColorScheme.dark(
    primary: Color(0xFF90A4AE),
    secondary: Color(0xFFB0BEC5),
    surface: Color(0xFF263238),
    onPrimary: Colors.white,
    onSurface: Color(0xFFECEFF1),
  );
}
```

### 4.2 阴影和光晕效果

```dart
// lib/ui/widgets/glowing_card.dart

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = glowColor ?? theme.colorScheme.primary;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // 外阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          // 光晕效果
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        child: child,
      ),
    );
  }
}
```

---

## 五、开发流程建议

### 阶段1：UI开发（1周，无后端）
```
✅ 搭建Flutter项目
✅ 配置主题系统
✅ 开发核心页面UI
  - 首页（日记列表）
  - 记录页（输入表单）
  - 详情页（Markdown展示）
  - 设置页
✅ 使用静态数据测试
```

### 阶段2：本地功能（1周，Hive）
```
✅ 集成Hive本地数据库
✅ 实现CRUD操作
✅ Mock AI生成（返回固定文本）
✅ 编辑功能完善
✅ 照片本地存储
```

### 阶段3：AI集成（3天）
```
✅ 配置外置化（Prompt文件）
✅ 集成AI API（通义千问/Kimi）
✅ 测试不同风格效果
✅ 优化Prompt模板
```

### 阶段4：后端接入（1周）
```
✅ Supabase配置
✅ 用户认证
✅ 数据同步（本地 ↔ 远程）
✅ 照片上传OSS
✅ 情侣绑定功能
```

### 阶段5：完善细节（1周）
```
✅ 动画效果
✅ 加载状态
✅ 错误处理
✅ 数据导出
✅ 性能优化
```

---

## 六、关键依赖包

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  
  # 本地存储
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Markdown支持
  flutter_markdown: ^0.6.18
  markdown: ^7.1.1
  
  # 富文本编辑器
  flutter_quill: ^9.0.0
  
  # 图片处理
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  photo_view: ^0.14.0
  
  # 网络请求
  dio: ^5.3.3
  
  # 日期处理
  intl: ^0.18.1
  
  # 工具类
  path_provider: ^2.1.1
  share_plus: ^7.2.1
  url_launcher: ^6.2.1
  
  # UI组件
  flutter_slidable: ^3.0.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6

flutter:
  assets:
    - assets/prompts/
    - assets/configs/
    - assets/fonts/
    - assets/images/
  
  fonts:
    - family: SourceHanSansCN
      fonts:
        - asset: assets/fonts/SourceHanSansCN-Regular.otf
        - asset: assets/fonts/SourceHanSansCN-Bold.otf
          weight: 700
    
    - family: SourceHanSerifCN
      fonts:
        - asset: assets/fonts/SourceHanSerifCN-Regular.otf
        - asset: assets/fonts/SourceHanSerifCN-Bold.otf
          weight: 700
```

---

## 七、项目结构

```
lib/
├── main.dart
├── config/
│   ├── app_config.dart          # 环境配置
│   └── router.dart              # 路由配置
├── core/
│   ├── config_manager.dart      # 配置管理器
│   └── constants.dart
├── data/
│   ├── models/
│   │   ├── diary.dart
│   │   ├── user.dart
│   │   └── couple.dart
│   ├── repositories/
│   │   ├── diary_repository.dart
│   │   ├── user_repository.dart
│   │   └── ai_repository.dart
│   └── services/
│       ├── local_storage_service.dart
│       └── api_service.dart
├── ui/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── markdown_theme.dart
│   ├── pages/
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── home_controller.dart
│   │   ├── create/
│   │   │   ├── create_page.dart
│   │   │   └── create_controller.dart
│   │   ├── detail/
│   │   │   ├── detail_page.dart
│   │   │   └── detail_controller.dart
│   │   └── settings/
│   │       └── settings_page.dart
│   └── widgets/
│       ├── diary_card.dart
│       ├── diary_editor.dart
│       ├── glowing_card.dart
│       ├── style_selector.dart
│       └── mood_selector.dart
└── utils/
    ├── date_helper.dart
    ├── string_helper.dart
    └── export_helper.dart

assets/
├── prompts/
│   ├── base_diary.txt
│   ├── highlight_moment.txt
│   └── ...
├── configs/
│   ├── styles.json
│   ├── moods.json
│   ├── defaults.json
│   └── templates.json
├── fonts/
│   └── (字体文件)
└── images/
    └── (图片资源)
```

---

## 八、Mock数据生成器（加快开发）

```dart
// lib/utils/mock_data.dart

class MockDataGenerator {
  static List<Diary> generateDiaries(int count) {
    final random = Random();
    final now = DateTime.now();
    
    return List.generate(count, (index) {
      final date = now.subtract(Duration(days: index));
      
      return Diary(
        id: 'diary_$index',
        date: date,
        type: _randomType(),
        rawContent: _randomContent(),
        aiContent: _generateMockMarkdown(index),
        mood: _randomMood(),
        style: 'warm',
        createdAt: date,
      );
    });
  }
  
  static String _generateMockMarkdown(int index) {
    return """
# ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}

今天又是充满温暖的一天。

虽然我们身在异地，但心却从未远离。他今天发来的消息让我笑了很久，那些看似平常的关心，其实都是爱的表达。

> "想你了" - 简单的三个字，却让整个世界都变得柔软。

期待下次见面的时刻。💕

---

*连续记录第${index + 1}天*
""";
  }
  
  static String _randomType() {
    final types = ['daily', 'sweet', 'highlight', 'quarrel', 'travel'];
    return types[Random().nextInt(types.length)];
  }
  
  static String _randomMood() {
    final moods = ['happy', 'sweet', 'miss', 'excited', 'calm'];
    return moods[Random().nextInt(moods.length)];
  }
  
  static String _randomContent() {
    final contents = [
      '今天他给我买了奶茶，还记得少糖',
      '一起看了日落，他说下次还要带我去海边',
      '吵架了，但他最后还是来哄我了',
      '异地第37天，好想抱抱他',
      '他今天发了很多表情包，笑死我了',
    ];
    return contents[Random().nextInt(contents.length)];
  }
}
```

---

## 总结：技术方案核心要点

✅ **配置外置化** - 所有Prompt、样式、默认值都在assets/configs中
✅ **离线优先开发** - 前期用Mock数据，后期无缝切换到真实API
✅ **Markdown为核心** - 输入输出都用Markdown，方便AI生成和编辑
✅ **可编辑性** - AI生成后可完全编辑，支持富文本
✅ **精美UI** - 圆角、阴影、光晕、多主题，字体精心选择
✅ **快速迭代** - 模块化设计，每个功能独立开发测试

这个架构可以让你：
1. **前3周完全不需要后端**，专注UI和交互
2. **随时调整Prompt**，无需重新编译
3. **方便A/B测试**，不同用户可以用不同配置
4. **降低调试成本**，Mock数据响应即时

需要我帮你开始搭建项目框架吗？
