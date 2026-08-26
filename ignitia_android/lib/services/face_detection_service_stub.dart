import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'face_detection_result.dart';

// Web implementation. ML Kit is not supported on web, so the photo is accepted
// locally (still captured and sent to the server which performs the actual
// identity verification against the employee's registered profile). The blink
// challenge cannot classify eyes on web, but the UI still captures a short
// live burst (isBlinkChallengeSupported is false) whose frames are encoded
// here and validated server-side for motion, so a static photo cannot pass.

Future<FaceValidationResult> validateFaceImage(Uint8List bytes) async {
  return bytes.isNotEmpty
      ? FaceValidationResult.faceDetected
      : FaceValidationResult.failed;
}

bool get isBlinkChallengeSupported => false;

Future<EyeState> classifyEyes(Uint8List bytes) async {
  return EyeState.failed;
}

Future<String?> encodeLivenessFrame(
  Uint8List bytes, {
  int maxWidth = 160,
}) async {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }
    final scaled = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;
    final compressed = img.encodeJpg(scaled, quality: 70);
    return base64Encode(compressed);
  } catch (_) {
    return null;
  }
}

