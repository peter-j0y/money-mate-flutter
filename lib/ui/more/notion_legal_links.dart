class NotionLegalLinks {
  const NotionLegalLinks._();

  static const String noticeKo =
      'https://festive-recorder-88c.notion.site/39bd4d2df2e281269a08db2a9ac7504d?source=copy_link';
  static const String noticeEn =
      'https://festive-recorder-88c.notion.site/Notices-3b0d4d2df2e281bf8c1acaf3cc39c6d8?source=copy_link';

  static const String privacyPolicyKo =
      'https://festive-recorder-88c.notion.site/39bd4d2df2e28084907aeebf64936ceb?source=copy_link';
  static const String privacyPolicyEn =
      'https://festive-recorder-88c.notion.site/Privacy-Policy-3b0d4d2df2e281c99e5aee9228c00505?source=copy_link';

  static const String termsOfServiceKo =
      'https://festive-recorder-88c.notion.site/39bd4d2df2e28191a89cea0d6536c0f1?source=copy_link';
  static const String termsOfServiceEn =
      'https://festive-recorder-88c.notion.site/Terms-of-Service-3b0d4d2df2e281f1b280f12aa26f6a4c?source=copy_link';

  static String notice(bool isKorean) => isKorean ? noticeKo : noticeEn;

  static String privacyPolicy(bool isKorean) =>
      isKorean ? privacyPolicyKo : privacyPolicyEn;

  static String termsOfService(bool isKorean) =>
      isKorean ? termsOfServiceKo : termsOfServiceEn;
}
