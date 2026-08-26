enum FaceValidationResult {
  faceDetected,
  noFace,
  multipleFaces,
  faceTooSmall,
  failed,
}

// Eye state for a single liveness frame, produced by ML Kit facial
// classification. Used to detect the open -> closed -> open blink transition.
enum EyeState {
  eyesOpen,
  eyesClosed,
  // No usable face in this frame; treat as "keep sampling".
  noFace,
  // Classification could not be performed (web stub, transient failure).
  failed,
}

// Result of the live blink challenge. `faceBase64` is the final selfie used
// for identity verification; `livenessFrames` is the short base64 JPEG frame
// sequence captured around the blink, sent to the server which validates the
// capture was live (motion) and not a replayed still image. `challengeId` is
// the fresh single-use nonce the server issued for this capture, required so
// pre-recorded frames cannot be replayed.
class FaceVerificationResult {
  final String faceBase64;
  final List<String> livenessFrames;
  final String? challengeId;

  const FaceVerificationResult({
    required this.faceBase64,
    this.livenessFrames = const [],
    this.challengeId,
  });
}
