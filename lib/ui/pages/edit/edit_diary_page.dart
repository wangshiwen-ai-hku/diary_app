import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: Text(
          'Edit Diary',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: Text(
              'Save',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Raw content
            Text(
              'Original Note',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
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
            
            const SizedBox(height: 32),
            
            // AI content
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Enhanced',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Regenerate AI content
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    'Regenerate',
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
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
            
            // Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
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
                      'You can edit the AI generated content using Markdown.',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
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
