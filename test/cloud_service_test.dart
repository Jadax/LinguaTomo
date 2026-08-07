import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/services/cloud_service.dart';

void main() {
  test('configured cloud remains safe before bootstrap', () async {
    const service = CloudService();

    expect(service.isConfigured, isTrue);
    expect(service.currentUser, isNull);
    expect(await service.authChanges.isEmpty, isTrue);
  });

  test('email-link validation rejects malformed addresses locally', () {
    expect(CloudService.isValidEmail('learner@example.com'), isTrue);
    expect(CloudService.isValidEmail('learner'), isFalse);
    expect(CloudService.isValidEmail('learner@'), isFalse);
  });

  test('deleting cloud data before sign-in fails safely, never crashes', () {
    const service = CloudService();
    // Bootstrap never ran in this test, so there is no session to delete —
    // this must raise a clear StateError, not attempt a network call.
    expect(() => service.deleteCloudData(), throwsStateError);
  });
}
