import 'package:image_picker/image_picker.dart';

import 'ocr_result.dart';

class JapaneseOcrService {
  bool get isSupported => false;

  Future<OcrAnalysis> analyze(XFile file) {
    throw UnsupportedError(
      'Japanese photo OCR is currently available in the Android app.',
    );
  }

  void dispose() {}
}
