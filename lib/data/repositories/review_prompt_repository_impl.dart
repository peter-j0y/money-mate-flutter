import 'package:money_mate/data/local/review_prompt_local_data_source.dart';
import 'package:money_mate/data/repositories/review_prompt_repository.dart';

class ReviewPromptRepositoryImpl implements ReviewPromptRepository {
  ReviewPromptRepositoryImpl({ReviewPromptLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? ReviewPromptLocalDataSource();

  final ReviewPromptLocalDataSource _localDataSource;

  @override
  Future<DateTime?> getAnchorAt() => _localDataSource.getAnchorAt();

  @override
  Future<void> setAnchorAt(DateTime value) =>
      _localDataSource.setAnchorAt(value);

  @override
  Future<DateTime?> getLastRequestedAt() =>
      _localDataSource.getLastRequestedAt();

  @override
  Future<void> setLastRequestedAt(DateTime value) =>
      _localDataSource.setLastRequestedAt(value);
}
