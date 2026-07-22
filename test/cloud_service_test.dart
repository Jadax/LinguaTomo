import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/services/cloud_service.dart';

void main() {
  test('cloud-disabled mode exposes a safe empty auth stream', () async {
    const service = CloudService();

    expect(service.isConfigured, isFalse);
    expect(service.currentUser, isNull);
    expect(await service.authChanges.isEmpty, isTrue);
  });
}
