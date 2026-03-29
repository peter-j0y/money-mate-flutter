import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class MoneyMateBottomNavigationBar extends StatelessWidget {
  const MoneyMateBottomNavigationBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = AppColors.hexFF137FEC;
    const unselectedColor = AppColors.hexFF94A3B8;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.hexFFF1F5F9, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 9, 24, 11),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = index == currentIndex;
              final tab = tabs[index];

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 20,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class BottomNavTabItem {
  const BottomNavTabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
