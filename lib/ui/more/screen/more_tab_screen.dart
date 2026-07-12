import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/app_theme_mode.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/more/notion_legal_links.dart';
import 'package:money_mate/ui/more/screen/theme_setting_screen.dart';
import 'package:money_mate/ui/more/screen/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

const String _supportEmail = 'support.peterstudio@gmail.com';

Future<({String osVersion, String deviceModel})> _getDeviceInfo() async {
  final plugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final info = await plugin.androidInfo;
    return (osVersion: 'Android ${info.version.release}', deviceModel: info.model);
  }
  if (Platform.isIOS) {
    final info = await plugin.iosInfo;
    return (osVersion: 'iOS ${info.systemVersion}', deviceModel: info.utsname.machine);
  }
  return (
    osVersion: Platform.operatingSystemVersion,
    deviceModel: Platform.operatingSystem,
  );
}

String _buildSupportEmailBody({
  required String appVersion,
  required String osVersion,
  required String deviceModel,
}) {
  return '✍️ 오류 제보 및 문의 내용:\n'
      '\n'
      '\n'
      '\n'
      '----------------------------------\n'
      '💡 아래 정보는 오류 해결을 위한 기술 데이터로 오류 해결을 위해서만 사용됩니다.\n'
      '• 앱 버전: $appVersion\n'
      '• OS 버전: $osVersion\n'
      '• 기기명: $deviceModel\n'
      '----------------------------------';
}

class MoreTabScreen extends StatelessWidget {
  const MoreTabScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.appVersion,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final String appVersion;

  void _openThemeSetting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => ThemeSettingScreen(
              currentThemeMode: themeMode,
              onThemeModeChanged: onThemeModeChanged,
            ),
      ),
    );
  }

  void _openNotices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => const WebViewScreen(
              title: '공지사항',
              url: NotionLegalLinks.notice,
            ),
      ),
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    final deviceInfo = await _getDeviceInfo();
    final subject = Uri.encodeComponent('[머니메이트] 문의하기');
    final body = Uri.encodeComponent(
      _buildSupportEmailBody(
        appVersion: appVersion,
        osVersion: deviceInfo.osVersion,
        deviceModel: deviceInfo.deviceModel,
      ),
    );
    final uri = Uri.parse(
      'mailto:$_supportEmail?subject=$subject&body=$body',
    );

    var launched = false;
    try {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메일 앱을 열 수 없어요. $_supportEmail 으로 문의해주세요.')),
      );
    }
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => const WebViewScreen(
              title: '개인정보처리방침',
              url: NotionLegalLinks.privacyPolicy,
            ),
      ),
    );
  }

  void _openTermsOfService(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => const WebViewScreen(
              title: '이용약관',
              url: NotionLegalLinks.termsOfService,
            ),
      ),
    );
  }

  void _openOpenSourceLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Money Mate',
      applicationVersion: appVersion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 20, 16, safeAreaBottom + 36),
          children: [
            const _Header(),
            const SizedBox(height: 24),
            _SettingsSection(
              title: '일반',
              rows: [
                _SettingsRow(
                  icon: Icons.campaign_outlined,
                  accentColor: AppColors.hexFF0EA5E9,
                  title: '공지사항',
                  trailing: const _RowChevron(),
                  onTap: () => _openNotices(context),
                ),
                _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  accentColor: AppColors.hexFF8B5CF6,
                  title: '테마 설정',
                  subtitle: themeMode.label,
                  trailing: const _RowChevron(),
                  onTap: () => _openThemeSetting(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsSection(
              title: '고객지원',
              rows: [
                _SettingsRow(
                  icon: Icons.mail_outline_rounded,
                  accentColor: context.appColors.success,
                  title: '문의하기',
                  trailing: const _RowChevron(),
                  onTap: () => _contactSupport(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsSection(
              title: '약관 및 정책',
              rows: [
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  accentColor: context.appColors.primary,
                  title: '개인정보처리방침',
                  trailing: const _RowChevron(),
                  onTap: () => _openPrivacyPolicy(context),
                ),
                _SettingsRow(
                  icon: Icons.description_outlined,
                  accentColor: AppColors.hexFF6B7280,
                  title: '이용약관',
                  trailing: const _RowChevron(),
                  onTap: () => _openTermsOfService(context),
                ),
                _SettingsRow(
                  icon: Icons.article_outlined,
                  accentColor: AppColors.hexFFF97316,
                  title: '오픈소스 라이선스',
                  trailing: const _RowChevron(),
                  onTap: () => _openOpenSourceLicenses(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsSection(
              title: '앱 정보',
              rows: [
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  accentColor: AppColors.hexFF6B7280,
                  title: '앱 정보',
                  trailing: Text(
                    appVersion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '더보기',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              height: 16 / 13,
              fontWeight: FontWeight.w600,
              color: context.appColors.textTertiary,
            ),
          ),
        ),
        for (var i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i != rows.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackgroundColor = accentColor.withValues(
      alpha: isDark ? 0.2 : 0.1,
    );

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        height: 20 / 15,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w400,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _RowChevron extends StatelessWidget {
  const _RowChevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: context.appColors.textTertiary,
    );
  }
}