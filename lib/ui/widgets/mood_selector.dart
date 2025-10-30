import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/configs/defaults.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final defaults = json.decode(snapshot.data!);
        final moods = defaults['mood_tags'] as List;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: moods.map((mood) {
            final isSelected = selectedMood == mood['id'];
            return MoodChip(
              emoji: mood['emoji'],
              label: mood['name'],
              color: Color(int.parse(mood['color'].replaceFirst('#', '0xFF'))),
              isSelected: isSelected,
              onTap: () {
                onMoodSelected(isSelected ? null : mood['id']);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class MoodChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodChip({
    super.key,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
