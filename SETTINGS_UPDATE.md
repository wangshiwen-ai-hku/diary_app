# 设置页面更新说明

## 更新内容

已移除右上角色盘，完善设置页面的用户信息输入功能。

## 主要改动

### 1. 移除右上角主题选择器
**文件**: `lib/ui/pages/home/home_page.dart`

**改动**:
- ✅ 删除 `_buildThemeSelector` 方法
- ✅ 删除 `_buildThemeMenuItem` 方法
- ✅ 移除 AppBar 中的调色盘图标
- ✅ 保留设置图标，通过设置页面统一管理主题

**原因**: 避免功能重复，统一在设置页面管理所有配置。

### 2. 完善用户信息设置
**文件**: `lib/ui/pages/settings/settings_page.dart`

**新增功能**:

#### a) 昵称设置
- ✅ 我的昵称输入框
- ✅ TA的昵称输入框
- ✅ 实时输入，美观的 TextField 样式
- ✅ 数据持久化保存到本地

#### b) 纪念日设置
- ✅ 点击选择日期
- ✅ 自动计算在一起的天数
- ✅ 显示"已在一起 X 天"
- ✅ 数据持久化保存

#### c) 保存按钮
- ✅ 全宽按钮，带图标
- ✅ 保存后显示成功提示
- ✅ 使用 SnackBar 反馈

### 3. 数据持久化
**依赖**: `shared_preferences: ^2.2.2`

**存储项**:
- `user_name`: 用户昵称
- `partner_name`: 伴侣昵称
- `anniversary_date`: 纪念日时间戳

**Provider**:
```dart
final userNameProvider = StateProvider<String>((ref) => '');
final partnerNameProvider = StateProvider<String>((ref) => '');
final anniversaryDateProvider = StateProvider<DateTime?>((ref) => null);
```

### 4. UI 设计

#### 输入框卡片
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: theme.colorScheme.primary.withOpacity(0.2),
    ),
  ),
  child: Column(
    children: [
      // 标题行（图标 + 文字）
      Row(...),
      // 输入框
      TextField(...),
    ],
  ),
)
```

#### 日期选择卡片
- 点击弹出 DatePicker
- 显示已在一起的天数
- 右侧箭头提示可点击

## 使用指南

### 设置昵称
1. 打开设置页面
2. 在"我的昵称"输入框输入
3. 在"TA的昵称"输入框输入
4. 点击"保存信息"按钮
5. 显示保存成功提示

### 设置纪念日
1. 打开设置页面
2. 点击"在一起的日子"卡片
3. 选择日期（2000年至今天）
4. 确认后自动保存
5. 显示"已在一起 X 天"

### 切换主题
1. 打开设置页面
2. 滑动到"亮度模式"区域
3. 切换开关选择暗色/亮色
4. 滑动到"外观主题"区域
5. 点击喜欢的主题卡片

## 数据流程

### 启动流程
1. 应用启动
2. Settings 页面 initState
3. 从 SharedPreferences 加载数据
4. 更新 TextController 和 Provider

### 保存流程
1. 用户输入信息
2. 点击保存按钮
3. 写入 SharedPreferences
4. 更新 Provider 状态
5. 显示成功提示

### 读取流程
```dart
final prefs = await SharedPreferences.getInstance();
final userName = prefs.getString('user_name') ?? '';
```

## 技术细节

### State 管理
- 使用 `ConsumerStatefulWidget`
- 支持 TextController 和 Provider 同步
- 生命周期管理（dispose）

### 表单验证
- 当前为无验证模式
- 可以输入空值
- 后续可添加验证逻辑

### 主题集成
- 所有组件使用 `theme.colorScheme`
- 自动适配亮暗模式
- 使用 GoogleFonts 字体

## 已知优化空间

- [ ] 添加昵称长度验证
- [ ] 支持头像上传
- [ ] 添加"重置"按钮
- [ ] 数据备份/导出功能
- [ ] 更多个性化设置项

---
**更新时间**: 2025-10-30  
**版本**: v2.1  
**状态**: ✅ 功能完成
