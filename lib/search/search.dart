import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;

  const SearchWidget({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = "Search wallpapers...",
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final text = _controller.text;

      final hasText = text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }

      widget.onChanged?.call(text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  String _cleanQuery(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  void _handleSubmit(String value) {
    final cleaned = _cleanQuery(value);
    widget.onSubmitted?.call(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 16),

        onSubmitted: _handleSubmit,

        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                  onPressed: _clearText,
                )
              : null,

          // 👇 Outline border styles
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none, 
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
