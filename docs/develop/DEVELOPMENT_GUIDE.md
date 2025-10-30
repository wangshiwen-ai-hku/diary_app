# 🔧 开发重点指南

## 📍 当前项目状态

### 已完成 ✅
- UI框架 (100%)
- 数据模型 (100%)
- 本地存储 (100%)
- Mock数据 (100%)
- 基础页面 (100%)

### 待完成 ⏳
- AI接口集成 (0%)
- 配置文件 (0%)
- 图片功能 (0%)
- Markdown渲染 (0%)

---

## 🎯 开发优先级

### 【优先级1】必须完成才能发布MVP

#### 1. 创建配置文件 ⭐⭐⭐⭐⭐
**重要性**: 🔥 极高 - 应用无法启动  
**时间**: 5分钟  
**位置**: `assets/` 目录

**需要创建的文件**:
```
assets/
├── configs/
│   ├── styles.json      # 风格配置
│   └── defaults.json    # 默认配置和心情标签
└── prompts/
    └── base_diary.txt   # AI生成提示词
```

**具体内容**: 参考 `TESTING_GUIDE.md` 中的步骤1

---

#### 2. 集成真实AI API ⭐⭐⭐⭐⭐
**重要性**: 🔥 极高 - 核心功能  
**时间**: 2-4小时  
**难度**: ⭐⭐⭐

##### 📂 需要修改的文件

**A. 创建AI Service**

**文件**: `lib/data/services/ai_service.dart` (新建)

```dart
import 'package:dio/dio.dart';
import 'dart:convert';

class AIService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // TODO: 替换为你的API Key (建议从环境变量读取)
  final String _apiKey = 'YOUR_API_KEY_HERE';
  
  // TODO: 选择你的AI服务商并配置URL
  // OpenAI: https://api.openai.com/v1/chat/completions
  // Claude: https://api.anthropic.com/v1/messages
  // 通义千问: https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation
  final String _baseUrl = 'YOUR_API_URL_HERE';

  /// 生成日记
  Future<String> generateDiary({
    required String content,
    required String style,
    String? mood,
    String? promptTemplate,
  }) async {
    try {
      // 1. 构建Prompt
      final prompt = _buildPrompt(
        content: content,
        style: style,
        mood: mood,
        template: promptTemplate,
      );

      // 2. 调用API
      final response = await _callAI(prompt);

      // 3. 解析响应
      return _parseResponse(response);
    } catch (e) {
      print('AI生成失败: $e');
      rethrow;
    }
  }

  /// 构建Prompt
  String _buildPrompt({
    required String content,
    required String style,
    String? mood,
    String? template,
  }) {
    // 使用配置的模板，或使用默认模板
    final basePrompt = template ?? '''
你是一个温柔细腻的情感记录者，擅长将简短的记录扩写成感人的日记。

请基于以下信息生成一篇日记：
- 内容: $content
- 风格: $style
- 心情: ${mood ?? '无'}

要求：
1. 保持原汁原味的情感
2. 适当扩充细节
3. 字数控制在300-500字
4. 使用Markdown格式
5. 适当添加emoji表情（不超过3个）
''';

    return basePrompt;
  }

  /// 调用AI API
  Future<Map<String, dynamic>> _callAI(String prompt) async {
    // 🔥 方案A: OpenAI API
    final response = await _dio.post(
      _baseUrl,
      data: {
        'model': 'gpt-4',  // 或 gpt-3.5-turbo
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 800,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ),
    );

    /* 🔥 方案B: Claude API
    final response = await _dio.post(
      _baseUrl,
      data: {
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
      ),
    );
    */

    /* 🔥 方案C: 通义千问 API
    final response = await _dio.post(
      _baseUrl,
      data: {
        'model': 'qwen-turbo',
        'input': {'messages': [
          {'role': 'user', 'content': prompt}
        ]},
        'parameters': {
          'result_format': 'message',
        }
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ),
    );
    */

    return response.data;
  }

  /// 解析AI响应
  String _parseResponse(Map<String, dynamic> response) {
    try {
      // 🔥 OpenAI响应格式
      return response['choices'][0]['message']['content'];

      /* 🔥 Claude响应格式
      return response['content'][0]['text'];
      */

      /* 🔥 通义千问响应格式
      return response['output']['choices'][0]['message']['content'];
      */
    } catch (e) {
      throw Exception('解析AI响应失败: $e');
    }
  }

  /// 重新生成（带历史上下文）
  Future<String> regenerateDiary({
    required String originalContent,
    required String previousAIContent,
    required String style,
    String? mood,
  }) async {
    final prompt = '''
之前我生成的内容是：
$previousAIContent

但我想要重新生成一个不同风格的版本。

原始记录: $originalContent
新的风格: $style
心情: ${mood ?? '无'}

请生成一个完全不同角度和表达方式的新版本。
''';

    return generateDiary(
      content: prompt,
      style: style,
      mood: mood,
    );
  }
}
```

**B. 更新 CreateDiaryPage**

**文件**: `lib/ui/pages/create/create_diary_page.dart`

找到 `_generateAIDiary()` 方法（约第57行），替换为：

```dart
// 在文件顶部添加import
import '../../data/services/ai_service.dart';

// 在类中添加实例
class _CreateDiaryPageState extends ConsumerState<CreateDiaryPage> {
  final TextEditingController _contentController = TextEditingController();
  final AIService _aiService = AIService();  // 🔥 添加这行
  Map<String, dynamic> _defaults = {};
  String _currentPlaceholder = '';
  
  // ... 其他代码

  Future<void> _generateAIDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入内容')),
      );
      return;
    }

    ref.read(aiGeneratingProvider.notifier).state = true;

    try {
      // 🔥 调用真实AI API
      final aiContent = await _aiService.generateDiary(
        content: _contentController.text,
        style: ref.read(selectedStyleProvider),
        mood: ref.read(selectedMoodProvider),
      );

      // 保存日记
      await _saveDiary(aiContent);
    } catch (e) {
      // 错误处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI生成失败: $e')),
        );
      }
    } finally {
      ref.read(aiGeneratingProvider.notifier).state = false;
    }
  }
  
  // ... 其他代码保持不变
}
```

**C. 更新 EditDiaryPage**

**文件**: `lib/ui/pages/edit/edit_diary_page.dart`

找到"重新生成"按钮的onPressed（约第106行），替换为：

```dart
// 在文件顶部添加import
import '../../../data/services/ai_service.dart';

// 在类中添加实例和方法
class _EditDiaryPageState extends State<EditDiaryPage> {
  late TextEditingController _rawController;
  late TextEditingController _aiController;
  final AIService _aiService = AIService();  // 🔥 添加这行
  bool _isRegenerating = false;  // 🔥 添加这行

  // ... 其他代码

  Future<void> _regenerateAI() async {
    setState(() => _isRegenerating = true);

    try {
      final newContent = await _aiService.regenerateDiary(
        originalContent: _rawController.text,
        previousAIContent: _aiController.text,
        style: widget.diary.style ?? 'warm',
        mood: widget.diary.mood,
      );

      setState(() {
        _aiController.text = newContent;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('重新生成成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重新生成失败: $e')),
        );
      }
    } finally {
      setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... 前面代码不变
    
    // 修改重新生成按钮
    TextButton.icon(
      onPressed: _isRegenerating ? null : _regenerateAI,  // 🔥 修改这里
      icon: _isRegenerating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh, size: 18),
      label: Text(_isRegenerating ? '生成中...' : '重新生成'),
    ),
    
    // ... 后面代码不变
  }
}
```

##### 🔑 API Key配置建议

**方式1: 硬编码（快速测试）**
```dart
final String _apiKey = 'sk-xxxxxxxxxxxxx';
```

**方式2: 环境变量（推荐）**

创建 `.env` 文件：
```
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
```

使用 `flutter_dotenv` 包加载：
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
```

**方式3: 配置文件**
在 `assets/configs/api_config.json`：
```json
{
  "api_key": "your_key_here",
  "api_url": "https://api.openai.com/v1/chat/completions"
}
```

##### 🧪 测试AI集成

测试代码：
```dart
void testAI() async {
  final aiService = AIService();
  try {
    final result = await aiService.generateDiary(
      content: '今天和他一起看了电影',
      style: '温馨',
      mood: '开心',
    );
    print('AI生成结果: $result');
  } catch (e) {
    print('错误: $e');
  }
}
```

---

#### 3. 完善Hive初始化 ⭐⭐⭐⭐
**重要性**: 高 - 数据持久化  
**时间**: 10分钟  
**难度**: ⭐

##### 📂 需要修改的文件

**文件**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ui/theme/app_theme.dart';
import 'ui/pages/home/home_page.dart';
import 'data/models/diary.dart';
import 'data/repositories/local_diary_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 初始化Hive
  await Hive.initFlutter();
  
  // 🔥 注册适配器
  Hive.registerAdapter(DiaryAdapter());
  
  // 🔥 可选：开发阶段加载Mock数据
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    // Debug模式
    final repo = LocalDiaryRepository();
    final box = await repo._getBox();
    if (box.isEmpty) {
      await repo.initMockData(count: 10);
      print('✅ Mock数据已加载');
    }
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我们的日记',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

### 【优先级2】提升用户体验

#### 4. Markdown渲染 ⭐⭐⭐⭐
**重要性**: 高 - 内容展示  
**时间**: 30分钟  
**难度**: ⭐

##### 📂 需要修改的文件

**文件**: `lib/ui/pages/detail/diary_detail_page.dart`

```dart
// 在文件顶部添加import
import 'package:flutter_markdown/flutter_markdown.dart';

// 找到AI内容显示部分（约第220行），替换为：
if (_currentDiary.aiContent != null) ...[
  const SizedBox(height: 32),
  Row(
    children: [
      Icon(
        Icons.auto_awesome,
        size: 20,
        color: theme.colorScheme.secondary,
      ),
      const SizedBox(width: 8),
      Text(
        'AI 美化版',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.secondaryContainer.withOpacity(0.3),
          theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: MarkdownBody(  // 🔥 使用Markdown渲染
      data: _currentDiary.aiContent!,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
        h1: theme.textTheme.headlineMedium,
        h2: theme.textTheme.titleLarge,
        strong: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        blockquote: theme.textTheme.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.primary,
        ),
      ),
    ),
  ),
],
```

---

#### 5. 图片选择和显示 ⭐⭐⭐⭐
**重要性**: 中高 - 增强功能  
**时间**: 2小时  
**难度**: ⭐⭐

##### 📂 需要修改的文件

**A. 创建图片管理工具**

**文件**: `lib/utils/image_helper.dart` (新建)

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// 选择单张图片
  static Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      // 保存到应用目录
      return await _saveImageToLocal(image);
    } catch (e) {
      print('选择图片失败: $e');
      return null;
    }
  }

  /// 选择多张图片
  static Future<List<String>> pickMultipleImages({int maxImages = 9}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) return [];

      // 限制数量
      final selectedImages = images.take(maxImages).toList();

      // 保存所有图片
      final savedPaths = <String>[];
      for (var image in selectedImages) {
        final savedPath = await _saveImageToLocal(image);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }

      return savedPaths;
    } catch (e) {
      print('选择多张图片失败: $e');
      return [];
    }
  }

  /// 拍照
  static Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return await _saveImageToLocal(photo);
    } catch (e) {
      print('拍照失败: $e');
      return null;
    }
  }

  /// 保存图片到本地
  static Future<String?> _saveImageToLocal(XFile image) async {
    try {
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      
      // 创建images目录
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 生成唯一文件名
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedPath = '${imagesDir.path}/$fileName';

      // 复制文件
      await File(image.path).copy(savedPath);

      return savedPath;
    } catch (e) {
      print('保存图片失败: $e');
      return null;
    }
  }

  /// 删除图片
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('删除图片失败: $e');
      return false;
    }
  }

  /// 获取图片文件
  static File? getImageFile(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    final file = File(imagePath);
    return file.existsSync() ? file : null;
  }
}
```

**B. 更新 CreateDiaryPage 添加图片选择**

**文件**: `lib/ui/pages/create/create_diary_page.dart`

```dart
// 在文件顶部添加import
import '../../utils/image_helper.dart';
import 'dart:io';

// 在State类中添加变量
class _CreateDiaryPageState extends ConsumerState<CreateDiaryPage> {
  final TextEditingController _contentController = TextEditingController();
  Map<String, dynamic> _defaults = {};
  String _currentPlaceholder = '';
  List<String> _selectedImages = [];  // 🔥 添加这行

  // 添加图片选择方法
  Future<void> _pickImages() async {
    final images = await ImageHelper.pickMultipleImages(maxImages: 9);
    setState(() {
      _selectedImages.addAll(images);
      // 限制最多9张
      if (_selectedImages.length > 9) {
        _selectedImages = _selectedImages.take(9).toList();
      }
    });
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 修改_saveDiary方法，添加photos参数
  Future<void> _saveDiary(String aiContent) async {
    final repository = LocalDiaryRepository();
    final diary = Diary(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: ref.read(diaryTypeProvider),
      rawContent: _contentController.text,
      aiContent: aiContent,
      mood: ref.read(selectedMoodProvider),
      style: ref.read(selectedStyleProvider),
      createdAt: DateTime.now(),
      photos: _selectedImages,  // 🔥 添加图片
    );

    await repository.createDiary(diary);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功！')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... 前面代码不变

    // 在输入框后面添加图片选择区域
    return Scaffold(
      appBar: AppBar(/* ... */),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... 心情选择器
            // ... 风格选择器
            // ... 输入框
            
            const SizedBox(height: 24),
            
            // 🔥 添加图片选择部分
            Row(
              children: [
                Text(
                  '添加照片',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate, size: 20),
                  label: Text('选择照片 (${_selectedImages.length}/9)'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 图片网格
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[index]),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            // ... 提示文本等其他部分
          ],
        ),
      ),
    );
  }
}
```

**C. 更新 DiaryDetailPage 显示图片**

**文件**: `lib/ui/pages/detail/diary_detail_page.dart`

```dart
// 在文件顶部添加import
import 'dart:io';

// 找到图片显示部分（约第250行），替换为：
if (_currentDiary.photos.isNotEmpty) ...[
  const SizedBox(height: 32),
  Text(
    '照片',
    style: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),
  GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: _currentDiary.photos.length,
    itemBuilder: (context, index) {
      final imagePath = _currentDiary.photos[index];
      final imageFile = File(imagePath);
      
      return GestureDetector(
        onTap: () {
          // TODO: 打开大图查看
          _showImageViewer(context, _currentDiary.photos, index);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageFile.existsSync()
              ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image),
                ),
        ),
      );
    },
  ),
],

// 添加大图查看方法
void _showImageViewer(BuildContext context, List<String> images, int initialIndex) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: PageView.builder(
        itemCount: images.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Image.file(
              File(images[index]),
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    ),
  );
}
```

---

### 【优先级3】增强功能

#### 6. 搜索功能 ⭐⭐⭐
**时间**: 1-2小时  
**难度**: ⭐⭐

##### 📂 需要修改的文件

**文件**: `lib/ui/pages/home/home_page.dart`

添加搜索功能（代码示例略，可参考Flutter SearchDelegate）

---

#### 7. 数据导出 ⭐⭐⭐
**时间**: 2-3小时  
**难度**: ⭐⭐⭐

需要修改 `lib/ui/pages/settings/settings_page.dart` 和创建导出工具类

---

#### 8. 云端同步 ⭐⭐⭐⭐
**时间**: 1-2天  
**难度**: ⭐⭐⭐⭐

需要后端API支持

---

## 📊 开发时间估算

| 功能 | 优先级 | 时间 | 状态 |
|------|--------|------|------|
| 创建配置文件 | P1 | 5分钟 | ⏳ |
| 集成AI API | P1 | 2-4小时 | ⏳ |
| Hive初始化 | P1 | 10分钟 | ⏳ |
| Markdown渲染 | P2 | 30分钟 | ⏳ |
| 图片功能 | P2 | 2小时 | ⏳ |
| 搜索功能 | P3 | 1-2小时 | ⏳ |
| 数据导出 | P3 | 2-3小时 | ⏳ |
| 云端同步 | P3 | 1-2天 | ⏳ |

**MVP版本预计完成时间**: 1天（包含P1和P2任务）

---

## 🎯 开发建议

### 第一天（MVP）
1. ✅ 创建配置文件 (5分钟)
2. ✅ 完善Hive初始化 (10分钟)
3. ✅ 测试基本功能 (30分钟)
4. ✅ 集成AI API (2-4小时)
5. ✅ Markdown渲染 (30分钟)
6. ✅ 图片功能 (2小时)

### 第二天（增强）
7. 搜索功能
8. 优化UI细节
9. 性能优化
10. Bug修复

### 第三天（完善）
11. 数据导出
12. 统计功能
13. 双视角日记
14. 高光时刻

---

## 📝 开发检查清单

### 每次提交前检查
- [ ] 代码格式化：`dart format lib/`
- [ ] 代码分析：`flutter analyze`
- [ ] 功能测试通过
- [ ] UI无明显问题
- [ ] 无Console错误

### 发布前检查
- [ ] 所有P1功能完成
- [ ] 基本测试通过
- [ ] 性能可接受（列表滚动流畅）
- [ ] 错误处理完善
- [ ] 用户反馈机制

---

## 🔗 相关文档

- `TESTING_GUIDE.md` - 详细测试指南
- `SESSION_SUMMARY.md` - 项目总结
- `NEXT_STEPS.md` - 下一步建议
- `technical_design.md` - 技术设计

---

## 💡 开发技巧

### 1. 快速调试
```bash
# 热重载
按 r

# 热重启
按 R

# 查看Widget树
按 w

# 查看性能
按 p
```

### 2. 代码片段
在IDE中设置代码片段可以快速生成常用代码

### 3. 使用DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 4. 错误追踪
在可能出错的地方添加try-catch和日志

---

祝开发顺利！🚀 有问题随时查看文档！
