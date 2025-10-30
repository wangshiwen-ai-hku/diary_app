# 🔥 Firebase Functions后端集成指南

## 📋 目录

1. [前置准备](#前置准备)
2. [Firebase项目设置](#firebase项目设置)
3. [配置API Keys](#配置api-keys)
4. [本地测试](#本地测试)
5. [部署到Firebase](#部署到firebase)
6. [Flutter集成](#flutter集成)
7. [常见问题](#常见问题)

---

## 前置准备

### 1. 安装Node.js

确保安装了Node.js 18或更高版本：

```bash
node --version
# 应该显示 v18.x.x 或更高
```

如果没有，请访问：https://nodejs.org/

### 2. 安装Firebase CLI

```bash
npm install -g firebase-tools

# 验证安装
firebase --version
```

### 3. 登录Firebase

```bash
firebase login
```

会打开浏览器，使用Google账号登录。

---

## Firebase项目设置

### 1. 创建Firebase项目（如果还没有）

访问 https://console.firebase.google.com/ 创建新项目。

### 2. 初始化Firebase Functions

在项目根目录：

```bash
cd /Users/wangshiwen/Desktop/workspace/diary_app

# 初始化（如果还没有）
firebase init functions
```

选择：
- 使用已存在的项目
- 选择JavaScript
- 安装依赖：Yes

### 3. 安装依赖

```bash
cd functions
npm install
```

---

## 配置API Keys

### 方式1：使用Firebase环境变量（推荐-生产环境）

```bash
# 配置Gemini API Key
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"

# 可选：配置OpenAI
firebase functions:config:set openai.api_key="YOUR_OPENAI_API_KEY"

# 可选：配置Claude
firebase functions:config:set claude.api_key="YOUR_CLAUDE_API_KEY"

# 查看所有配置
firebase functions:config:get
```

### 方式2：本地测试配置

创建 `functions/.runtimeconfig.json`：

```json
{
  "gemini": {
    "api_key": "YOUR_GEMINI_API_KEY"
  },
  "openai": {
    "api_key": "YOUR_OPENAI_API_KEY"
  },
  "claude": {
    "api_key": "YOUR_CLAUDE_API_KEY"
  }
}
```

**⚠️ 重要**：不要将此文件提交到Git！已添加到.gitignore。

### 获取API Keys

- **Gemini**: https://makersuite.google.com/app/apikey
- **OpenAI**: https://platform.openai.com/api-keys  
- **Claude**: https://console.anthropic.com/

---

## 本地测试

### 1. 启动Firebase Emulator

```bash
cd functions
npm run serve
```

成功后会显示：
```
✔  functions[asia-northeast1-generateDiary]: http function initialized
✔  functions[asia-northeast1-regenerateDiary]: http function initialized  
✔  functions[asia-northeast1-health]: http function initialized
```

### 2. 测试健康检查

在浏览器访问：
```
http://localhost:5001/YOUR_PROJECT_ID/asia-northeast1/health
```

### 3. 测试生成日记

使用curl：

```bash
curl -X POST http://localhost:5001/YOUR_PROJECT_ID/asia-northeast1/generateDiary \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "content": "今天和他一起看了电影",
      "style": "warm",
      "mood": "sweet"
    }
  }'
```

---

## 部署到Firebase

### 1. 部署Functions

```bash
# 从项目根目录
firebase deploy --only functions
```

或者：

```bash
# 从functions目录
npm run deploy
```

### 2. 查看部署的Functions

访问：https://console.firebase.google.com → Functions

你会看到：
- `generateDiary`
- `regenerateDiary`
- `health`

### 3. 测试部署的Functions

获取Functions的URL，格式通常是：
```
https://asia-northeast1-YOUR_PROJECT_ID.cloudfunctions.net/generateDiary
```

---

## Flutter集成

### 1. 添加依赖

在 `pubspec.yaml` 中：

```yaml
dependencies:
  firebase_core: ^2.24.0
  cloud_functions: ^4.5.0
```

然后运行：

```bash
flutter pub get
```

### 2. 配置Flutter Firebase

使用FlutterFire CLI：

```bash
# 安装FlutterFire CLI
dart pub global activate flutterfire_cli

# 配置Firebase
flutterfire configure
```

选择你的Firebase项目，会自动生成 `firebase_options.dart`。

### 3. 初始化Firebase

在 `lib/main.dart` 中：

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DiaryAdapter());
  
  // 🔥 初始化Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### 4. 使用FirebaseAIService

已创建 `lib/data/services/firebase_ai_service.dart`。

在 `lib/ui/pages/create/create_diary_page.dart` 中使用：

```dart
import 'package:your_app/data/services/firebase_ai_service.dart';

class _CreateDiaryPageState extends ConsumerState<CreateDiaryPage> {
  final FirebaseAIService _aiService = FirebaseAIService();
  
  Future<void> _generateAIDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入内容')),
      );
      return;
    }

    ref.read(aiGeneratingProvider.notifier).state = true;

    try {
      final aiContent = await _aiService.generateDiary(
        content: _contentController.text,
        style: ref.read(selectedStyleProvider),
        mood: ref.read(selectedMoodProvider),
      );

      await _saveDiary(aiContent);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI生成失败: $e')),
        );
      }
    } finally {
      ref.read(aiGeneratingProvider.notifier).state = false;
    }
  }
}
```

### 5. 本地测试连接（可选）

在开发时连接本地Emulator：

```dart
import 'package:flutter/foundation.dart';

void main() async {
  // ... 其他初始化

  // 🧪 开发环境使用Emulator
  if (kDebugMode) {
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
  
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## 常见问题

### Q1: 部署失败，提示权限错误

**A**: 检查Firebase计费账户，Functions需要Blaze计划（按量付费，有免费额度）。

访问：https://console.firebase.google.com → 设置 → 使用情况和账单

### Q2: Flutter连接不上Functions

**A**: 检查几点：
1. Firebase已正确初始化
2. `firebase_options.dart` 已生成
3. Region是否一致（都是 `asia-northeast1`）
4. 网络连接正常

### Q3: 本地测试报错找不到API Key

**A**: 确保创建了 `functions/.runtimeconfig.json` 并配置了API Key。

### Q4: Gemini API报错地区不支持

**A**: 
1. 使用VPN切换到支持地区
2. 或使用OpenAI/Claude
3. 在Flutter中指定provider：
   ```dart
   provider: 'openai', // 或 'claude'
   ```

### Q5: 本地Emulator启动失败

**A**: 
```bash
# 停止所有Emulator
firebase emulators:kill

# 清除端口
lsof -ti:5001 | xargs kill -9

# 重新启动
cd functions && npm run serve
```

### Q6: 部署后调用超时

**A**: Functions默认60秒超时，AI调用通常5-15秒。如果超时：
1. 检查网络
2. 尝试切换AI提供商
3. 增加超时设置（在index.js的runWith中）

---

## 💰 成本估算

Firebase Functions定价：
- **免费额度**：
  - 每月200万次调用
  - 40万GB-秒计算时间
  - 5GB出站流量

- **超出后**：
  - 每100万次调用：$0.40
  - 每GB-秒：$0.0000025

**实际使用**：
- 每次AI生成约2-5秒
- 每月1000次调用 ≈ $0.01
- **完全在免费范围内**

---

## 🎯 优势

### vs 自建后端服务

| 特性 | Firebase Functions | 自建后端 |
|-----|-------------------|---------|
| 服务器管理 | ✅ 无需管理 | ❌ 需要维护 |
| 扩展性 | ✅ 自动扩展 | ❌ 手动配置 |
| 成本 | ✅ 按使用付费 | ❌ 固定成本 |
| 部署 | ✅ 一条命令 | ❌ 复杂流程 |
| HTTPS | ✅ 自动配置 | ❌ 需要配置 |

---

## 📊 监控

### 查看日志

```bash
firebase functions:log
```

### 在Console查看

访问：https://console.firebase.google.com → Functions → 日志

可以看到：
- 调用次数
- 错误率
- 执行时间
- 成本

---

## 🚀 下一步

1. ✅ 完成Firebase Functions部署
2. ✅ 在Flutter中集成
3. ✅ 测试AI生成功能
4. 📱 发布应用

---

## 📚 参考资源

- [Firebase Functions文档](https://firebase.google.com/docs/functions)
- [Cloud Functions for Firebase](https://cloud.google.com/functions)
- [FlutterFire](https://firebase.flutter.dev/)

---

**祝使用愉快！** 🎉

有问题随时查看文档或Firebase Console的日志。
