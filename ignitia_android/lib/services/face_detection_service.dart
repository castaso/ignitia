import 'dart:typed_data';

import 'face_detection_result.dart';
import 'face_detection_service_io.dart'
    if (dart.library.js_interop) 'face_detection_service_stub.dart' as impl;

// Face validation is delegated to a platform-specific implementation:
// - Native (Android/iOS): google_mlkit_face_detection verifies that the
//   captured JPEG contains exactly one clear face.
// - Web: ML Kit is not available on web, so a captured photo is accepted
//   locally and the server is responsible for the identity verification.
Future<FaceValidationResult> validateFaceImage(Uint8List bytes) {
  return impl.validateFaceImage(bytes);
}

// Whether the native blink challenge can run on this platform. Always false
// on web, where ML Kit is unavailable and the server must verify identity
// against the submitted photo alone.
bool get isBlinkChallengeSupported => impl.isBlinkChallengeSupported;

// Classifies the eye state of the face in the given JPEG frame. Returns
// EyeState.failed when classification is not supported (web).
Future<EyeState> classifyEyes(Uint8List bytes) {
  return impl.classifyEyes(bytes);
}

// Down-scales and compresses a raw frame into a small base64 JPEG suitable for
// uploading as a liveness frame. Returns null when the frame cannot be
// encoded or the platform does not support it (web).
Future<String?> encodeLivenessFrame(Uint8List bytes, {int maxWidth = 160}) {
  return impl.encodeLivenessFrame(bytes, maxWidth: maxWidth);
}
