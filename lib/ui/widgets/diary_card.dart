import 'package:flutter/material.dart';
import '../../data/models/diary.dart';
import 'glowing_card.dart';

class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlowingCard(
      glowColor: _getMoodColor(diary.mood),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期和心情
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(diary.date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                if (diary.mood != null) ...[
                  Text(
                    _getMoodEmoji(diary.mood!),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getMoodText(diary.mood!),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const Spacer(),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 原始内容
            Text(
              diary.rawContent,
              style: theme.textTheme.bodyLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // AI标记和照片
            Row(
              children: [
                if (diary.aiContent != null) ...[
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI已生成',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
                const Spacer(),
                if (diary.photos.isNotEmpty) ...[
                  Icon(
                    Icons.image,
                    size: 14,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${diary.photos.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  String _getMoodEmoji(String mood) {
    const moodEmojis = {
      'happy': '😊',
      'sweet': '💕',
      'miss': '🥺',
      'excited': '🤩',
      'calm': '😌',
      'sad': '😢',
      'angry': '😤',
    };
    return moodEmojis[mood] ?? '😊';
  }

  String _getMoodText(String mood) {
    const moodTexts = {
      'happy': '开心',
      'sweet': '甜蜜',
      'miss': '想念',
      'excited': '激动',
      'calm': '平静',
      'sad': '难过',
      'angry': '生气',
    };
    return moodTexts[mood] ?? '';
  }

  Color _getMoodColor(String? mood) {
    if (mood == null) return Colors.pink;
    const moodColors = {
      'happy': Colors.orange,
      'sweet': Colors.pink,
      'miss': Colors.blue,
      'excited': Colors.purple,
      'calm': Colors.teal,
      'sad': Colors.grey,
      'angry': Colors.red,
    };
    return moodColors[mood] ?? Colors.pink;
  }
}
