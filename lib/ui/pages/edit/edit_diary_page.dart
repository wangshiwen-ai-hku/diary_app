import 'package:flutter/material.dart';
import '../../../data/models/diary.dart';
import '../../../data/repositories/local_diary_repository.dart';
import '../../widgets/diary_editor.dart';

class EditDiaryPage extends StatefulWidget {
  final Diary diary;

  const EditDiaryPage({super.key, required this.diary});

  @override
  State<EditDiaryPage> createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  late TextEditingController _rawController;
  late TextEditingController _aiController;

  @override
  void initState() {
    super.initState();
    _rawController = TextEditingController(text: widget.diary.rawContent);
    _aiController = TextEditingController(text: widget.diary.aiContent);
  }

  @override
  void dispose() {
    _rawController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    final updatedDiary = widget.diary.copyWith(
      rawContent: _rawController.text,
      aiContent: _aiController.text,
    );

    final repository = LocalDiaryRepository();
    await repository.updateDiary(updatedDiary);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑日记'),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 原始内容
            Text(
              '原始记录',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DiaryEditor(
              initialContent: widget.diary.rawContent,
              onChanged: (value) {
                _rawController.text = value;
              },
              maxLines: 8,
            ),
            
            const SizedBox(height: 24),
            
            // AI内容
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI美化版',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 重新生成AI内容
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重新生成'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownEditor(
              initialContent: widget.diary.aiContent,
              onChanged: (value) {
                _aiController.text = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 提示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '支持Markdown格式编辑，可以自由调整AI生成的内容',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
