import 'dart:ui' as ui;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'ocr_result.dart';

class JapaneseOcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.japanese,
  );

  bool get isSupported => true;

  Future<OcrAnalysis> analyze(XFile file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final size = ui.Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
    frame.image.dispose();
    codec.dispose();
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(file.path),
    );
    return OcrAnalysis(
      text: result.text,
      boxes: result.blocks.map((block) => block.boundingBox).toList(),
      imageSize: size,
    );
  }

  void dispose() => _recognizer.close();
}
