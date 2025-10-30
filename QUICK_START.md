# 🚀 快速启动指南

## 当前状态
✅ UI框架完成  
✅ 数据层完成  
⚠️ 需要配置文件  
⚠️ 需要生成代码  

---

## 立即运行（5分钟）

### 步骤1：创建配置文件 (2分钟)

```bash
# 在项目根目录执行
cd /Users/wangshiwen/Desktop/workspace/diary_app

# 创建目录
mkdir -p assets/configs assets/prompts

# 创建 styles.json
cat > assets/configs/styles.json << 'JSON'
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
JSON

# 创建 defaults.json
cat > assets/configs/defaults.json << 'JSON'
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
JSON

# 创建 base_diary.txt
cat > assets/prompts/base_diary.txt << 'PROMPT'
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
PROMPT

echo "✅ 配置文件创建完成！"
```

### 步骤2：生成Hive代码 (1分钟)

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 步骤3：运行应用 (2分钟)

```bash
# 查看可用设备
flutter devices

# 运行（会自动选择设备）
flutter run

# 或指定设备运行
flutter run -d chrome          # 浏览器
flutter run -d "iPhone 15 Pro" # iOS模拟器
```

---

## 🎮 应用功能演示

启动后可以测试：

1. **查看首页** - 会显示Mock生成的日记列表
2. **创建日记** - 点击"记录今天"按钮
   - 选择心情（开心/甜蜜/想念等）
   - 选择风格（温馨/诗意/真实）
   - 输入内容
   - 点击"AI生成"（目前是Mock实现）
3. **查看详情** - 点击任意日记卡片
4. **编辑日记** - 在详情页点击编辑按钮
5. **删除日记** - 在首页长按或点击删除按钮
6. **分享日记** - 在详情页点击分享按钮

---

## 📱 调试技巧

### 热重载
- 修改UI代码后，按 `r` 键即可热重载
- 修改逻辑代码后，按 `R` 键热重启

### 查看日志
```bash
flutter logs
```

### 性能检查
在应用运行时按 `P` 键显示性能叠加层

### Widget检查
按 `w` 键启用Widget Inspector

---

## 🐛 可能遇到的问题

### Q1: 配置文件找不到
**解决**: 检查 `pubspec.yaml` 中的 assets 配置：
```yaml
flutter:
  assets:
    - assets/configs/
    - assets/prompts/
```

### Q2: Hive报错
**解决**: 运行
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Q3: 依赖错误
**解决**:
```bash
flutter clean
flutter pub get
```

### Q4: 模拟器找不到
**解决**:
```bash
# iOS
open -a Simulator

# Android
flutter emulators --launch <emulator_id>
```

---

## 🎯 下一步开发

现在你已经有了可运行的应用，可以开始：

1. **集成真实AI** - 参考 `NEXT_STEPS.md` 中的AI集成指南
2. **添加图片功能** - 实现图片选择和展示
3. **美化UI** - 调整颜色、字体、动画
4. **添加新功能** - 根据需求扩展

---

## 📚 相关文档

- `SESSION_SUMMARY.md` - 本次开发总结
- `DEVELOPMENT_PROGRESS.md` - 详细开发进度
- `NEXT_STEPS.md` - 下一步开发指南
- `technical_design.md` - 技术设计文档

---

## 🎉 开始吧！

```bash
# 一键启动（从头到尾）
cd /Users/wangshiwen/Desktop/workspace/diary_app && \
mkdir -p assets/configs assets/prompts && \
flutter packages pub run build_runner build --delete-conflicting-outputs && \
flutter run
```

祝开发愉快！💪
