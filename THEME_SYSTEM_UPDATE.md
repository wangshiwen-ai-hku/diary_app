# 主题色系统更新说明

## 更新内容

已完成系统级主题色调度功能，实现卡片与主题色联动，改善视觉体验。

## 主要改动

### 1. 新增统一主题色系统
**文件**: `lib/ui/theme/theme_colors.dart`

**特性**:
- ✅ 定义深、中、浅三级主题色
- ✅ 为每个主题色定义对应的文本颜色
- ✅ 根据日记类型返回相应的渐变色组合
- ✅ 支持 5 种主题: Dark Space, Light Minimal, Elegant Dark, Nordic Light, Cyberpunk

**主题色结构**:
```dart
ThemeColors {
  primary   // 主色
  light     // 浅色
  medium    // 中色
  dark      // 深色
  onPrimary // 主色上的文本色
  onLight   // 浅色上的文本色
  onMedium  // 中色上的文本色
  onDark    // 深色上的文本色
}
```

### 2. 更新卡片组件
**文件**: `lib/ui/widgets/sliding_diary_card.dart`

**改进**:
- ✅ 卡片边距增大 (16px) 留白更多
- ✅ 增强阴影效果 - 双层阴影增加立体感
- ✅ 提高不透明度 (0.85-0.95) 改善可读性
- ✅ 根据系统主题动态调整所有颜色
- ✅ 渐变色由主题色统一生成
- ✅ 文本颜色自动适配深/浅主题
- ✅ 边框和装饰色与主题色协调

**阴影层次**:
- 外层: 主题色阴影 (opacity 0.3, blur 24px)
- 内层: 黑色阴影 (opacity 0.2, blur 32px)

### 3. 完善设置页面
**文件**: `lib/ui/pages/settings/settings_page.dart`

**新增功能**:
- ✅ 主题色选择器（右上角设置按钮进入）
- ✅ 可视化主题预览卡片
- ✅ 显示主题的四种颜色点
- ✅ 实时切换主题
- ✅ 选中状态高亮显示

**主题预览卡片**:
- 渐变色预览方块
- 四色圆点指示器
- 主题名称
- 选中图标

### 4. 导航完善
**文件**: `lib/ui/pages/home/home_page.dart`

**改动**:
- ✅ 设置按钮可点击，跳转到设置页面

## 颜色调度逻辑

### 日记类型 → 渐变色映射
- **Sweet**: primary → light
- **Highlight**: medium → light
- **Quarrel**: dark → medium
- **Travel**: light → primary
- **Default**: primary → medium

### 深浅主题适配
```dart
// 文本颜色
isDark ? themeColors.light : themeColors.dark

// 装饰颜色
themeColors.primary.withOpacity(0.15)
```

## 视觉改进

### 立体效果提升
1. **双层阴影**: 主题色 + 黑色阴影组合
2. **更高不透明度**: 卡片背景从 0.95 → 0.85-0.92
3. **边框加强**: 宽度从 1px → 1.5px，颜色与主题关联
4. **留白增加**: 边距从 8px → 16px

### 主题一致性
- 所有UI元素颜色统一来源于主题色系统
- 文本颜色自动适配背景明暗
- 渐变、边框、阴影全部响应主题切换

## 使用方法

1. **切换主题**:
   - 点击首页右上角设置图标
   - 在"外观主题"区域选择喜欢的主题
   - 点击后立即生效

2. **效果预览**:
   - 日记卡片渐变色随主题变化
   - 文本颜色自动适配
   - 阴影和边框颜色协调统一

3. **自定义主题** (开发者):
   - 在 `theme_colors.dart` 添加新主题
   - 定义四级颜色和对应文本色
   - 在 `colors.dart` 添加 ColorScheme

## 技术细节

- 使用 Riverpod 状态管理主题切换
- ConsumerWidget 监听主题变化
- 实时重建UI响应主题
- 无需重启应用即可切换

## 下一步优化建议

- [ ] 添加更多主题选项
- [ ] 支持用户自定义主题色
- [ ] 保存主题选择到本地存储
- [ ] 添加主题切换过渡动画
