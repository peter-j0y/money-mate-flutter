import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/app_theme_mode.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

extension AppThemeModeLabel on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.system:
        return '시스템 설정에 따름';
      case AppThemeMode.light:
        return '라이트 모드';
      case AppThemeMode.dark:
        return '다크 모드';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.system:
        return '기기의 화면 모드 설정을 그대로 따라가요';
      case AppThemeMode.light:
        return '항상 밝은 화면으로 표시해요';
      case AppThemeMode.dark:
        return '항상 어두운 화면으로 표시해요';
    }
  }
}

class ThemeSettingScreen extends StatefulWidget {
  const ThemeSettingScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  final AppThemeMode currentThemeMode;
  final ValueChanged<AppThemeMode> onThemeModeChanged;

  @override
  State<ThemeSettingScreen> createState() => _ThemeSettingScreenState();
}

class _ThemeSettingScreenState extends State<ThemeSettingScreen> {
  late AppThemeMode _selected = widget.currentThemeMode;

  void _select(AppThemeMode mode) {
    if (_selected == mode) return;
    setState(() => _selected = mode);
    widget.onThemeModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(onBackTap: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  for (final mode in AppThemeMode.values) ...[
                    _ThemeOptionRow(
                      mode: mode,
                      isSelected: _selected == mode,
                      onTap: () => _select(mode),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 15,
                        height: 20 / 15,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mode.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color:
                    isSelected
                        ? context.appColors.primary
                        : context.appColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onBackTap,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '테마 설정',
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
