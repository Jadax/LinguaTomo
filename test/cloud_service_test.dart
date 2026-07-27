import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/services/cloud_service.dart';

void main() {
  test('unconfigured cloud remains safe before bootstrap', () async {
    const service = CloudService();

    expect(service.isConfigured, isFalse);
    expect(service.currentUser, isNull);
    expect(await service.authChanges.isEmpty, isTrue);
  });
}
