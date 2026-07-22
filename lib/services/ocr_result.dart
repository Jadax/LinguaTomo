import 'dart:ui';

class OcrAnalysis {
  const OcrAnalysis({
    required this.text,
    required this.boxes,
    required this.imageSize,
  });

  final String text;
  final List<Rect> boxes;
  final Size imageSize;
}
