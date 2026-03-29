import 'package:flutter/material.dart';

class LedgerMemoSection extends StatelessWidget {
  const LedgerMemoSection.editable({
    super.key,
    required this.controller,
    this.maxLines = 4,
    this.onTap,
    this.placeholder,
  }) : text = null;

  const LedgerMemoSection.readOnly({
    super.key,
    required this.text,
    this.placeholder,
  }) : controller = null,
       maxLines = 1,
       onTap = null;

  final TextEditingController? controller;
  final String? text;
  final int maxLines;
  final VoidCallback? onTap;
  final String? placeholder;

  static const String _defaultPlaceholder = '내용을 입력해주세요 (예: 퇴근길 버스비)';

  @override
  Widget build(BuildContext context) {
    final placeholderText = placeholder ?? _defaultPlaceholder;

    if (controller != null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(5),
        child: TextField(
          controller: controller,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: placeholderText,
            hintStyle: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
          ),
        ),
      );
    }

    final memoText = text?.trim();
    final hasMemo = memoText != null && memoText.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(17, 13, 17, 13),
      child: Text(
        hasMemo ? memoText : placeholderText,
        style: TextStyle(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w500,
          color: hasMemo ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
