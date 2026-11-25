import 'package:fastise/features/fasting/data/fasting_repository.dart';

class MemoryStringStore implements StringStore {
  final Map<String, String> values = {};
  Object? writeError;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    if (writeError != null) {
      throw writeError!;
    }
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}
