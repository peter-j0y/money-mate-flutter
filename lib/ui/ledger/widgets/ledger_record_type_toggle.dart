import 'package:flutter/material.dart';

class LedgerRecordTypeToggle extends StatelessWidget {
  const LedgerRecordTypeToggle({
    super.key,
    required this.selectedIndex,
    this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: _RecordTypeButton(
              label: '수입',
              isSelected: selectedIndex == 0,
              onTap: () => onChanged?.call(0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RecordTypeButton(
              label: '지출',
              isSelected: selectedIndex == 1,
              onTap: () => onChanged?.call(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTypeButton extends StatelessWidget {
  const _RecordTypeButton({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF137FEC) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.transparent, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
