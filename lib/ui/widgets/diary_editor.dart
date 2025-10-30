import 'package:flutter/material.dart';

class DiaryEditor extends StatefulWidget {
  final String? initialContent;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool readOnly;

  const DiaryEditor({
    super.key,
    this.initialContent,
    this.hintText,
    this.onChanged,
    this.maxLines = 10,
    this.readOnly = false,
  });

  @override
  State<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends State<DiaryEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _controller,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.8,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? '写下今天的故事...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class MarkdownEditor extends StatefulWidget {
  final String? initialContent;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const MarkdownEditor({
    super.key,
    this.initialContent,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (!widget.readOnly) _buildToolbar(),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _controller,
            maxLines: null,
            minLines: 10,
            readOnly: widget.readOnly,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.8,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: '支持Markdown格式...\n\n# 标题\n**粗体** *斜体*\n> 引用',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildToolButton(Icons.format_bold, '**粗体**'),
          _buildToolButton(Icons.format_italic, '*斜体*'),
          _buildToolButton(Icons.format_quote, '> 引用'),
          _buildToolButton(Icons.title, '# 标题'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.preview, size: 20),
            onPressed: () {
              // TODO: 预览Markdown
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String markdown) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () {
        final text = _controller.text;
        final selection = _controller.selection;
        final newText = text.replaceRange(
          selection.start,
          selection.end,
          markdown,
        );
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: selection.start + markdown.length,
          ),
        );
      },
    );
  }
}
