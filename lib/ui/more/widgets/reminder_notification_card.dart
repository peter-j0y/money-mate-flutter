import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_mate/data/repositories/reminder_repository.dart';
import 'package:money_mate/data/repositories/reminder_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/core/notification_permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderNotificationCard extends StatefulWidget {
  ReminderNotificationCard({super.key, ReminderRepository? repository})
    : repository = repository ?? ReminderRepositoryImpl();

  final ReminderRepository repository;

  @override
  State<ReminderNotificationCard> createState() =>
      _ReminderNotificationCardState();
}

class _ReminderNotificationCardState extends State<ReminderNotificationCard>
    with WidgetsBindingObserver {
  bool _enabled = false;
  bool _awaitingSettingsReturn = false;
  Set<int> _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};
  TimeOfDay _time = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFromRepository();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_awaitingSettingsReturn) {
      return;
    }
    _awaitingSettingsReturn = false;
    _syncAfterSettingsReturn();
  }

  Future<void> _syncAfterSettingsReturn() async {
    final status = await Permission.notification.status;
    if (!mounted) return;
    // 설정 화면으로 이동해서 권한을 켰다면, 리마인드 알림을 켜려는 의도였던 것이므로
    // 앱으로 돌아왔을 때 토글도 함께 켜준다.
    if (status.isGranted) {
      await _setEnabled(true);
    }
  }

  Future<void> _loadFromRepository() async {
    final storedEnabled = await widget.repository.isEnabled();
    final weekdays = await widget.repository.getWeekdays();
    final hour = await widget.repository.getHour();
    final minute = await widget.repository.getMinute();
    final status = await Permission.notification.status;
    // 토글이 켜져 있으려면 시스템 알림 권한이 항상 허용되어 있어야 하므로,
    // 앱 밖에서 권한이 취소된 경우를 대비해 저장된 값과 실제 권한 상태를 동기화한다.
    final enabled = storedEnabled && status.isGranted;
    if (enabled != storedEnabled) {
      unawaited(widget.repository.setEnabled(enabled));
    } else if (enabled) {
      // 알림 문구가 앱을 열 때마다 새로 뽑히도록, 켜져 있으면 매번 다시 예약한다.
      unawaited(
        widget.repository.updateSchedule(
          weekdays: weekdays,
          hour: hour,
          minute: minute,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _selectedWeekdays = weekdays;
      _time = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _onToggleChanged(bool value) async {
    if (!value) {
      setState(() => _enabled = false);
      await widget.repository.setEnabled(false);
      return;
    }

    final currentStatus = await Permission.notification.status;
    if (currentStatus.isGranted) {
      await _setEnabled(true);
      return;
    }

    if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
      if (!mounted) return;
      _awaitingSettingsReturn =
          await NotificationPermissionDialog.showSettingsRedirect(context);
      return;
    }

    final requestedStatus = await Permission.notification.request();
    if (requestedStatus.isGranted) {
      await _setEnabled(true);
    } else if (requestedStatus.isPermanentlyDenied && mounted) {
      _awaitingSettingsReturn =
          await NotificationPermissionDialog.showSettingsRedirect(context);
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    setState(() => _enabled = enabled);
    await widget.repository.setEnabled(enabled);
  }

  Future<void> _toggleWeekday(int weekday) async {
    final next = Set<int>.of(_selectedWeekdays);
    if (next.contains(weekday)) {
      if (next.length > 1) next.remove(weekday);
    } else {
      next.add(weekday);
    }
    setState(() => _selectedWeekdays = next);
    await widget.repository.updateSchedule(
      weekdays: next,
      hour: _time.hour,
      minute: _time.minute,
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
    await widget.repository.updateSchedule(
      weekdays: _selectedWeekdays,
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekdayLabels = weekdayShortLabels(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = context.appColors.primary;
    final iconBackgroundColor = accentColor.withValues(
      alpha: isDark ? 0.2 : 0.1,
    );

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.alarm_outlined, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.reminderTitle,
                      style: TextStyle(
                        fontSize: 15,
                        height: 20 / 15,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.reminderSubtitle,
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
              const SizedBox(width: 8),
              Switch(
                value: _enabled,
                onChanged: _onToggleChanged,
                activeColor: context.appColors.inverseText,
                activeTrackColor: accentColor,
                inactiveThumbColor: context.appColors.inverseText,
                inactiveTrackColor: context.appColors.border,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child:
                _enabled
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Divider(height: 1, color: context.appColors.border),
                        const SizedBox(height: 16),
                        Text(
                          l10n.reminderWeekdayLabel,
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            final weekday = index + 1;
                            final isSelected = _selectedWeekdays.contains(
                              weekday,
                            );
                            return _WeekdayDot(
                              label: weekdayLabels[index],
                              selected: isSelected,
                              accentColor: accentColor,
                              onTap: () => _toggleWeekday(weekday),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.reminderTimeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: context.appColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickTime,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 18,
                                    color: context.appColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _time.format(context),
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 20 / 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.appColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: context.appColors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _WeekdayDot extends StatelessWidget {
  const _WeekdayDot({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accentColor : context.appColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                height: 18 / 13,
                fontWeight: FontWeight.w600,
                color:
                    selected
                        ? context.appColors.inverseText
                        : context.appColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
