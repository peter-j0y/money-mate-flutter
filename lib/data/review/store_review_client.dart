import 'package:in_app_review/in_app_review.dart';

/// OS 리뷰 API 래퍼. 테스트에서 가짜로 바꿔 끼울 수 있도록 분리한다.
abstract class StoreReviewClient {
  Future<bool> isAvailable();

  /// OS 리뷰 시트를 요청한다. 실제 노출 여부와 별점 제출 여부는 OS가 알려주지 않는다.
  Future<void> requestReview();

  /// 스토어의 앱 페이지를 연다.
  Future<void> openStoreListing();
}

class InAppReviewStoreClient implements StoreReviewClient {
  InAppReviewStoreClient({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  /// App Store Connect의 앱 Apple ID. Android는 패키지명으로 찾으므로 필요 없다.
  static const String _appStoreId = '6792507401';

  final InAppReview _inAppReview;

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> requestReview() => _inAppReview.requestReview();

  @override
  Future<void> openStoreListing() =>
      _inAppReview.openStoreListing(appStoreId: _appStoreId);
}
