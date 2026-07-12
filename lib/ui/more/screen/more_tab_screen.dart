import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/more/notion_legal_links.dart';
import 'package:money_mate/ui/more/screen/web_view_screen.dart';

class MoreTabScreen extends StatelessWidget {
  const MoreTabScreen({
    super.key,
    required this.isDarkModeEnabled,
    required this.onDarkModeChanged,
    required this.appVersion,
  });

  final bool isDarkModeEnabled;
  final ValueChanged<bool> onDarkModeChanged;
  final String appVersion;

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

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('help@moneymate.app 으로 문의해주세요.')),
    );
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
          padding: EdgeInsets.fromLTRB(16, 20, 16, safeAreaBottom + 100),
          children: [
            const _Header(),
            const SizedBox(height: 24),
            _SettingsRow(
              icon: Icons.campaign_outlined,
              accentColor: AppColors.hexFF0EA5E9,
              title: '공지사항',
              subtitle: '새로운 소식을 확인해요',
              trailing: const _RowChevron(),
              onTap: () => _openNotices(context),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.dark_mode_outlined,
              accentColor: AppColors.hexFF8B5CF6,
              title: '다크 모드',
              subtitle: '화면을 어둡게 표시해요',
              trailing: Switch(
                value: isDarkModeEnabled,
                activeColor: context.appColors.primary,
                onChanged: onDarkModeChanged,
              ),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.mail_outline_rounded,
              accentColor: context.appColors.success,
              title: '문의하기',
              subtitle: '궁금한 점을 문의해보세요',
              trailing: const _RowChevron(),
              onTap: () => _contactSupport(context),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.privacy_tip_outlined,
              accentColor: context.appColors.primary,
              title: '개인정보처리방침',
              trailing: const _RowChevron(),
              onTap: () => _openPrivacyPolicy(context),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.description_outlined,
              accentColor: AppColors.hexFF6B7280,
              title: '이용약관',
              trailing: const _RowChevron(),
              onTap: () => _openTermsOfService(context),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.article_outlined,
              accentColor: AppColors.hexFFF97316,
              title: '오픈소스 라이선스',
              trailing: const _RowChevron(),
              onTap: () => _openOpenSourceLicenses(context),
            ),
            const SizedBox(height: 8),
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