# 💕 我们的日记 - AI情侣日记应用

一个使用AI帮助情侣记录美好时光的Flutter应用

---

## 🚀 快速开始

### 第一次运行（5分钟）

```bash
# 1. 进入项目目录
cd /Users/wangshiwen/Desktop/workspace/diary_app

# 2. 创建配置文件（必需！）
bash -c "$(curl -fsSL https://raw.githubusercontent.com/your-repo/setup.sh)"
# 或手动创建：参考 TESTING_GUIDE.md 步骤1

# 3. 生成代码


# 4. 运行
flutter run -d chrome  # 推荐用Chrome调试
```

---

## 📚 文档导航

| 文档 | 用途 | 适合人群 |
|------|------|---------|
| **[TESTING_GUIDE.md](TESTING_GUIDE.md)** | 🧪 如何测试应用 | 测试人员 |
| **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** | 🔧 开发重点和修改位置 | 开发人员 |
| **[SESSION_SUMMARY.md](SESSION_SUMMARY.md)** | 📊 本次开发总结 | 所有人 |
| **[NEXT_STEPS.md](NEXT_STEPS.md)** | 🎯 下一步计划 | 项目经理 |
| **[technical_design.md](technical_design.md)** | 📐 技术架构设计 | 架构师 |

---

## ✨ 功能特性

### 已完成 ✅
- [x] 精美的UI设计（Material 3）
- [x] 日记CRUD（创建、查看、编辑、删除）
- [x] 心情选择器（5种心情）
- [x] 风格选择器（3种风格）
- [x] 本地数据存储（Hive）
- [x] 分享功能
- [x] Mock数据生成

### 待完成 ⏳
- [ ] 真实AI接口集成 ⭐⭐⭐⭐⭐
- [ ] 图片选择和显示 ⭐⭐⭐⭐
- [ ] Markdown渲染 ⭐⭐⭐⭐
- [ ] 搜索功能 ⭐⭐⭐
- [ ] 数据导出 ⭐⭐⭐
- [ ] 云端同步 ⭐⭐

---

## 🎯 核心任务（MVP）

完成以下任务即可发布MVP版本：

### 1. 创建配置文件 (5分钟) 🔥
```bash
mkdir -p assets/configs assets/prompts
# 然后创建 styles.json, defaults.json, base_diary.txt
# 详见: TESTING_GUIDE.md 步骤1
```

### 2. 集成AI API (2-4小时) 🔥
- 创建 `lib/data/services/ai_service.dart`
- 修改 `lib/ui/pages/create/create_diary_page.dart`
- 详见: **DEVELOPMENT_GUIDE.md 第2节**

### 3. 完善Hive初始化 (10分钟)
- 修改 `lib/main.dart`
- 详见: **DEVELOPMENT_GUIDE.md 第3节**

### 4. 添加Markdown渲染 (30分钟)
- 修改 `lib/ui/pages/detail/diary_detail_page.dart`
- 详见: **DEVELOPMENT_GUIDE.md 第4节**

### 5. 实现图片功能 (2小时)
- 创建 `lib/utils/image_helper.dart`
- 修改创建和详情页面
- 详见: **DEVELOPMENT_GUIDE.md 第5节**

---

## 📱 测试应用

### 功能测试
```bash
# 参考 TESTING_GUIDE.md
# 包含详细的测试步骤和检查清单
```

### 性能测试
```bash
flutter run --profile
# 按 P 键查看性能叠加层
```

---

## 🏗️ 项目结构

```
lib/
├── main.dart                          # 应用入口
├── core/                              # 核心功能
│   ├── config_manager.dart            # 配置管理
│   └── constants.dart                 # 常量
├── data/                              # 数据层
│   ├── models/                        # 数据模型
│   │   └── diary.dart                 # 日记模型
│   ├── repositories/                  # 数据仓库
│   │   ├── diary_repository.dart      # 接口
│   │   └── local_diary_repository.dart # 本地实现
│   └── services/                      # 服务
│       └── ai_service.dart            # AI服务（待创建）
├── ui/                                # UI层
│   ├── theme/                         # 主题
│   ├── pages/                         # 页面
│   │   ├── home/                      # 首页
│   │   ├── create/                    # 创建
│   │   ├── detail/                    # 详情
│   │   ├── edit/                      # 编辑
│   │   └── settings/                  # 设置
│   └── widgets/                       # 组件
│       ├── diary_card.dart            # 日记卡片
│       ├── diary_editor.dart          # 编辑器
│       ├── glowing_card.dart          # 光晕卡片
│       ├── mood_selector.dart         # 心情选择
│       └── style_selector.dart        # 风格选择
└── utils/                             # 工具
    ├── mock_data.dart                 # Mock数据
    └── image_helper.dart              # 图片工具（待创建）
```

---

## 🛠️ 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **状态管理**: Riverpod
- **本地存储**: Hive
- **UI**: Material 3
- **AI**: OpenAI/Claude/通义千问（可选）
- **图片**: image_picker
- **分享**: share_plus
- **Markdown**: flutter_markdown

---

## 🔧 常用命令

```bash
# 安装依赖
flutter pub get

# 代码生成
flutter packages pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run
flutter run -d chrome          # Chrome
flutter run -d "iPhone 15 Pro" # iOS模拟器

# 代码检查
flutter analyze

# 格式化代码
dart format lib/

# 清理缓存
flutter clean
```

---

## 📊 开发进度

### 第一阶段：UI框架 ✅ (100%)
- [x] 主题系统
- [x] 页面框架
- [x] 自定义组件
- [x] 数据模型

### 第二阶段：核心功能 ⏳ (40%)
- [x] Mock数据
- [x] 本地存储
- [ ] AI集成 🔥
- [ ] 图片功能 🔥

### 第三阶段：增强功能 ⏳ (0%)
- [ ] Markdown渲染
- [ ] 搜索功能
- [ ] 数据导出
- [ ] 统计分析

### 第四阶段：高级功能 📅 (未开始)
- [ ] 双视角日记
- [ ] 云端同步
- [ ] 社交分享
- [ ] 主题定制

**当前进度**: 约 60% 完成

---

## 🐛 问题排查

### Q: 配置文件找不到
**A**: 确保创建了 `assets/configs/` 和 `assets/prompts/` 目录及文件

### Q: Hive报错
**A**: 运行 `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Q: 热重载不生效
**A**: 某些修改需要按 `R` 热重启，而不是 `r` 热重载

### Q: Mock数据不显示
**A**: 在 `main.dart` 中添加 Mock数据初始化代码

更多问题参考: [TESTING_GUIDE.md](TESTING_GUIDE.md#常见问题)

---

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- Flutter团队提供的优秀框架
- Riverpod状态管理库
- Hive本地存储解决方案
- 所有开源贡献者

---

## 📞 联系方式

- 📧 Email: your-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-repo/issues)
- 💬 讨论: [GitHub Discussions](https://github.com/your-repo/discussions)

---

**💖 用AI记录你们的美好时光 💖**

最后更新: 2025-10-30
