import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../data/models/diary.dart';
import '../../../data/repositories/local_diary_repository.dart';

// Provider for selected mood
final selectedMoodProvider = StateProvider<String?>((ref) => null);

// Provider for selected style
final selectedStyleProvider = StateProvider<String>((ref) => 'warm');

// Provider for diary type
final diaryTypeProvider = StateProvider<String>((ref) => 'daily');

// Provider for generating AI content
final aiGeneratingProvider = StateProvider<bool>((ref) => false);

class CreateDiaryPage extends ConsumerStatefulWidget {
  const CreateDiaryPage({super.key});

  @override
  ConsumerState<CreateDiaryPage> createState() => _CreateDiaryPageState();
}

class _CreateDiaryPageState extends ConsumerState<CreateDiaryPage> {
  final TextEditingController _contentController = TextEditingController();
  Map<String, dynamic> _defaults = {};
  String _currentPlaceholder = '';

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final defaultsJson = await rootBundle.loadString('assets/configs/defaults.json');
    setState(() {
      _defaults = json.decode(defaultsJson);
      _currentPlaceholder = (_defaults['input_placeholders'] as List).first;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _generateAIDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入内容')),
      );
      return;
    }

    ref.read(aiGeneratingProvider.notifier).state = true;

    // 模拟AI生成延迟
    await Future.delayed(const Duration(seconds: 2));

    // 这里应该调用真实的AI API
    // 目前使用模拟数据
    final mockAIContent = '''
# ${DateTime.now().month}月${DateTime.now().day}日

${_contentController.text}

虽然是简单的记录，却藏着满满的温暖。这些平凡的日子，因为有你，变得格外珍贵。

> "爱在细节里，幸福在点滴中。"

期待我们的每一个明天。💕
''';

    ref.read(aiGeneratingProvider.notifier).state = false;

    // 保存日记
    await _saveDiary(mockAIContent);
  }

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
      photos: [],
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
    final theme = Theme.of(context);
    final selectedMood = ref.watch(selectedMoodProvider);
    final selectedStyle = ref.watch(selectedStyleProvider);
    final isGenerating = ref.watch(aiGeneratingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录今天'),
        actions: [
          TextButton.icon(
            onPressed: isGenerating ? null : _generateAIDiary,
            icon: isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isGenerating ? '生成中...' : 'AI生成'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 心情选择
            Text(
              '今天的心情',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMoodSelector(selectedMood),
            
            const SizedBox(height: 24),
            
            // 风格选择
            Text(
              '生成风格',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStyleSelector(selectedStyle),
            
            const SizedBox(height: 24),
            
            // 输入框
            Text(
              '记录内容',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: _currentPlaceholder,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 提示文本
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '简单记录就好，AI会帮你扩写成完整的日记',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(String? selectedMood) {
    if (_defaults.isEmpty) return const SizedBox.shrink();
    
    final moods = _defaults['mood_tags'] as List;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood['id'];
        return _MoodChip(
          emoji: mood['emoji'],
          label: mood['name'],
          color: Color(int.parse(mood['color'].replaceFirst('#', '0xFF'))),
          isSelected: isSelected,
          onTap: () {
            ref.read(selectedMoodProvider.notifier).state = mood['id'];
          },
        );
      }).toList(),
    );
  }

  Widget _buildStyleSelector(String selectedStyle) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/configs/styles.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final stylesData = json.decode(snapshot.data!);
        final styles = stylesData['styles'] as List;
        
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: styles.map((style) {
            final isSelected = selectedStyle == style['id'];
            return _StyleChip(
              icon: style['icon'],
              label: style['name'],
              description: style['description'],
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedStyleProvider.notifier).state = style['id'];
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleChip({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
