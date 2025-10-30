import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  factory ConfigManager() => _instance;
  ConfigManager._internal();

  // 缓存配置
  final Map<String, dynamic> _configs = {};
  final Map<String, String> _prompts = {};

  bool _initialized = false;

  // 初始化配置
  Future<void> init() async {
    if (_initialized) return;
    
    await _loadPrompts();
    await _loadConfigs();
    
    _initialized = true;
  }

  // 加载Prompt文件
  Future<void> _loadPrompts() async {
    final promptFiles = [
      'base_diary',
      'highlight_moment',
      'dual_perspective',
    ];

    for (var file in promptFiles) {
      try {
        _prompts[file] = await rootBundle.loadString(
          'assets/prompts/$file.txt',
        );
      } catch (e) {
        print('Error loading prompt $file: $e');
      }
    }
  }

  // 加载JSON配置
  Future<void> _loadConfigs() async {
    _configs['styles'] = await _loadJson('assets/configs/styles.json');
    _configs['defaults'] = await _loadJson('assets/configs/defaults.json');
  }

  Future<Map<String, dynamic>> _loadJson(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('Error loading config $path: $e');
      return {};
    }
  }

  // 获取Prompt（支持变量替换）
  String getPrompt(String name, Map<String, dynamic> variables) {
    String prompt = _prompts[name] ?? '';

    // 简单变量替换
    variables.forEach((key, value) {
      prompt = prompt.replaceAll('{{$key}}', value.toString());
    });

    return prompt;
  }

  // 获取配置
  dynamic getConfig(String category, [String? key]) {
    if (key == null) return _configs[category];
    return _configs[category]?[key];
  }

  // 获取所有风格
  List<dynamic> getStyles() {
    return _configs['styles']?['styles'] ?? [];
  }

  // 获取默认风格
  String getDefaultStyle() {
    return _configs['styles']?['default_style'] ?? 'warm';
  }

  // 获取输入提示列表
  List<String> getInputPlaceholders() {
    return List<String>.from(
      _configs['defaults']?['input_placeholders'] ?? [],
    );
  }

  // 获取心情标签
  List<dynamic> getMoodTags() {
    return _configs['defaults']?['mood_tags'] ?? [];
  }

  // 获取日记类型
  List<dynamic> getDiaryTypes() {
    return _configs['defaults']?['diary_types'] ?? [];
  }

  // 根据ID获取风格配置
  Map<String, dynamic>? getStyleById(String id) {
    final styles = getStyles();
    try {
      return styles.firstWhere((style) => style['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // 根据类型获取日记配置
  Map<String, dynamic>? getDiaryTypeById(String id) {
    final types = getDiaryTypes();
    try {
      return types.firstWhere((type) => type['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
