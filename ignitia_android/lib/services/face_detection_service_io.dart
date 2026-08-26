import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'face_detection_result.dart';

// Native (Android / iOS) implementation. Verifies with Google ML Kit that the
// captured JPEG contains exactly one clear, reasonably large face, and class
// each liveness frame as eyes-open / eyes-closed so the UI can run a live
// blink challenge. This is a liveness / proxy-prevention check: a real person
// must physically present themselves to the camera.

const double _eyesClosedProbability = 0.35;

FaceDetector _detector() {
  return FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
      enableClassification: true,
    ),
  );
}

// ML Kit's InputImage.fromBytes format enum no longer exposes a jpeg variant,
// so the compressed JPEG frame is handed to ML Kit through a temp file path
// instead, which the platform implementation decodes natively.
File _tempJpegFile(Uint8List bytes) {
  final file = File(
    '${Directory.systemTemp.path}/mlkit_${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  file.writeAsBytesSync(bytes);
  return file;
}

Future<FaceValidationResult> validateFaceImage(Uint8List bytes) async {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return FaceValidationResult.failed;
    }
    final inputImage = InputImage.fromFilePath(_tempJpegFile(bytes).path);
    final detector = _detector();
    final faces = await detector.processImage(inputImage);
    await detector.close();
    if (faces.isEmpty) {
      return FaceValidationResult.noFace;
    }
    if (faces.length > 1) {
      return FaceValidationResult.multipleFaces;
    }
    final face = faces.first;
    final minFaceWidth = decoded.width * 0.15;
    if (face.boundingBox.width < minFaceWidth) {
      return FaceValidationResult.faceTooSmall;
    }
    return FaceValidationResult.faceDetected;
  } catch (_) {
    return FaceValidationResult.failed;
  }
}

bool get isBlinkChallengeSupported => true;

Future<EyeState> classifyEyes(Uint8List bytes) async {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return EyeState.failed;
    }
    final inputImage = InputImage.fromFilePath(_tempJpegFile(bytes).path);
    final detector = _detector();
    final faces = await detector.processImage(inputImage);
    await detector.close();
    if (faces.isEmpty || faces.length > 1) {
      return EyeState.noFace;
    }
    final face = faces.first;
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null || right == null) {
      return EyeState.failed;
    }
    final average = (left + right) / 2;
    return average < _eyesClosedProbability
        ? EyeState.eyesClosed
        : EyeState.eyesOpen;
  } catch (_) {
    return EyeState.failed;
  }
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
