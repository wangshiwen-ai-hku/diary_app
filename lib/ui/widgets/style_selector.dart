import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class StyleSelector extends StatelessWidget {
  final String selectedStyle;
  final ValueChanged<String> onStyleSelected;

  const StyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/configs/styles.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stylesData = json.decode(snapshot.data!);
        final styles = stylesData['styles'] as List;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: styles.map((style) {
            final isSelected = selectedStyle == style['id'];
            return StyleChip(
              icon: style['icon'],
              label: style['name'],
              description: style['description'],
              isSelected: isSelected,
              onTap: () => onStyleSelected(style['id']),
            );
          }).toList(),
        );
      },
    );
  }
}

class StyleChip extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const StyleChip({
    super.key,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
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
          mainAxisSize: MainAxisSize.min,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
