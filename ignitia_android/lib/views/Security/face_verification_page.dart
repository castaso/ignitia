import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../components/button_widget.dart';
import '../../components/textview_widget.dart';
import '../../repo/attendance_services.dart';
import '../../services/face_detection_result.dart';
import '../../services/face_detection_service.dart';
import '../../utils/colors.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';

// Page that runs a live blink challenge and captures a selfie, validating
// that exactly one clear face is present before the photo is attached to the
// attendance record. This prevents proxy (buddy) attendance where one
// employee punches in for another and stops a static or replayed photo from
// passing the check. On native platforms the user must blink on camera (ML Kit
// eye classification) and the short frame sequence plus a fresh server-issued
// challenge id are submitted for validation. On web the challenge is a live
// capture burst (no ML Kit) whose frames are still validated server-side for
// motion, so a static photo cannot pass there either.
class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({Key? key}) : super(key: key);

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  static const int _maxLivenessFrames = 8;
  static const int _minLivenessFrames = 3;
  static const int _maxChallengeAttempts = 16;

  CameraController? _controller;
  bool _isInitializing = true;
  bool _isProcessing = false;
  bool _challengeRunning = false;
  String? _errorText;
  String? _challengeStatusText;
  String? _challengeId;
  Uint8List? _capturedBytes;
  List<String> _livenessFrames = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorText = Messages.errorFaceCaptureFailed;
        });
        return;
      }
      CameraDescription frontCamera;
      try {
        frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        frontCamera = cameras.first;
      }
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() => _isInitializing = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = Messages.errorFaceCaptureFailed;
      });
    }
  }

  @override
  void dispose() {
    _challengeRunning = false;
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() {
      _isProcessing = true;
      _errorText = null;
      _challengeStatusText = null;
    });
    try {
      // A fresh single-use challenge must accompany the frames; without it the
      // server rejects the capture. Fetched right before recording.
      _challengeId = await AttendanceService.getLivenessChallenge();
      if (_challengeId == null) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _errorText = Messages.blinkChallengeSetupFailed;
        });
        return;
      }
      if (isBlinkChallengeSupported) {
        await _runBlinkChallengeAndCapture();
      } else {
        await _runBurstCaptureAndCapture();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _challengeRunning = false;
        _errorText = Messages.errorFaceCaptureFailed;
      });
    }
  }

  Future<void> _runBlinkChallengeAndCapture() async {
    _challengeRunning = true;
    _livenessFrames = [];
    setState(() => _challengeStatusText = Messages.blinkChallengeHint);

    final blinkDetected = await _runBlinkChallenge();
    if (!mounted) return;
    _challengeRunning = false;
    if (!blinkDetected) {
      setState(() {
        _isProcessing = false;
        _errorText = Messages.blinkChallengeTimeout;
      });
      return;
    }
    setState(() => _challengeStatusText = Messages.blinkChallengeDetected);

    // Guarantee at least the server's minimum frame count even when the blink
    // was caught on an early sample.
    await _topUpLivenessFrames();
    if (!mounted || !_challengeRunning) return;

    // The user just blinked and opened their eyes again; take the final selfie
    // while the face is clearly visible.
    await Future.delayed(const Duration(milliseconds: 400));
    final file = await _controller!.takePicture();
    final bytes = await file.readAsBytes();
    final result = await validateFaceImage(bytes);
    if (!mounted) return;
    if (result == FaceValidationResult.faceDetected) {
      setState(() {
        _capturedBytes = bytes;
        _isProcessing = false;
        _challengeStatusText = null;
      });
    } else {
      setState(() {
        _isProcessing = false;
        _challengeStatusText = null;
        _errorText = _messageForResult(result);
      });
    }
  }

  // Samples the preview frames and returns true once an eyes-open ->
  // eyes-closed transition is observed (a blink). Keeps sampling after the
  // blink until the minimum number of liveness frames has been collected.
  Future<bool> _runBlinkChallenge() async {
    var lastWasOpen = false;
    var blinkDetected = false;
    for (var i = 0; i < _maxChallengeAttempts; i++) {
      if (!mounted || !_challengeRunning) return blinkDetected;
      Uint8List bytes;
      try {
        final file = await _controller!.takePicture();
        bytes = await file.readAsBytes();
      } catch (_) {
        continue;
      }
      if (!mounted || !_challengeRunning) return blinkDetected;

      final state = await classifyEyes(bytes);
      final encoded = await encodeLivenessFrame(bytes);
      if (encoded != null) {
        _livenessFrames.add(encoded);
        if (_livenessFrames.length > _maxLivenessFrames) {
          _livenessFrames.removeAt(0);
        }
      }

      if (state == EyeState.eyesOpen) {
        lastWasOpen = true;
      } else if (state == EyeState.eyesClosed && lastWasOpen) {
        blinkDetected = true;
      }
      if (blinkDetected && _livenessFrames.length >= _minLivenessFrames) {
        return true;
      }
      if (i < _maxChallengeAttempts - 1) {
        await Future.delayed(const Duration(milliseconds: 450));
      }
    }
    return blinkDetected;
  }

  // Fills _livenessFrames up to _minLivenessFrames so the server-side minimum
  // is always satisfied.
  Future<void> _topUpLivenessFrames() async {
    while (_livenessFrames.length < _minLivenessFrames) {
      if (!mounted || !_challengeRunning) return;
      try {
        final file = await _controller!.takePicture();
        final bytes = await file.readAsBytes();
        final encoded = await encodeLivenessFrame(bytes);
        if (encoded == null) {
          return;
        }
        _livenessFrames.add(encoded);
      } catch (_) {
        return;
      }
      if (_livenessFrames.length < _minLivenessFrames) {
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }
  }

  // Web fallback: ML Kit blink classification is unavailable, so capture a
  // short burst of live frames while prompting the user to blink. The burst
  // still proves a live capture (the server rejects a replayed still because
  // identical consecutive frames show no motion), keeping LIVENESS_REQUIRED
  // enforceable on web.
  Future<void> _runBurstCaptureAndCapture() async {
    _challengeRunning = true;
    _livenessFrames = [];
    setState(() => _challengeStatusText = Messages.blinkChallengeHint);
    Uint8List? lastGood;
    for (var i = 0; i < _maxLivenessFrames; i++) {
      if (!mounted || !_challengeRunning) return;
      Uint8List bytes;
      try {
        final file = await _controller!.takePicture();
        bytes = await file.readAsBytes();
      } catch (_) {
        continue;
      }
      if (!mounted || !_challengeRunning) return;
      final result = await validateFaceImage(bytes);
      if (result == FaceValidationResult.faceDetected) {
        lastGood = bytes;
        final encoded = await encodeLivenessFrame(bytes);
        if (encoded != null) {
          _livenessFrames.add(encoded);
        }
      }
      if (i < _maxLivenessFrames - 1) {
        await Future.delayed(const Duration(milliseconds: 450));
      }
    }
    _challengeRunning = false;
    if (!mounted) return;
    if (lastGood == null || _livenessFrames.length < _minLivenessFrames) {
      setState(() {
        _isProcessing = false;
        _errorText = Messages.blinkChallengeTimeout;
      });
      return;
    }
    setState(() {
      _capturedBytes = lastGood;
      _isProcessing = false;
      _challengeStatusText = null;
    });
  }

  String _messageForResult(FaceValidationResult result) {
    switch (result) {
      case FaceValidationResult.noFace:
        return Messages.errorFaceNotDetected;
      case FaceValidationResult.multipleFaces:
        return Messages.errorMultipleFacesDetected;
      case FaceValidationResult.faceTooSmall:
        return Messages.errorFaceTooSmall;
      default:
        return Messages.errorFaceCaptureFailed;
    }
  }

  String _encodeBase64FromBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final resized = img.copyResize(decoded, width: 480);
      final compressed =
          Uint8List.fromList(img.encodeJpg(resized, quality: 80));
      return base64Encode(compressed);
    }
    return base64Encode(bytes);
  }

  void _confirm() {
    if (_capturedBytes == null) return;
    final base64 = _encodeBase64FromBytes(_capturedBytes!);
    Navigator.of(context).pop(FaceVerificationResult(
      faceBase64: base64,
      livenessFrames: List.unmodifiable(_livenessFrames),
      challengeId: _challengeId,
    ));
  }

  void _retake() {
    setState(() {
      _capturedBytes = null;
      _livenessFrames = [];
      _errorText = null;
    });
  }

  void _cancel() {
    _challengeRunning = false;
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: TitleTextView(
          Messages.faceVerificationTitle,
          textColor: Colors.white,
          textSize: 18,
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            TitleTextView(
              Messages.progressInProgress,
              textColor: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_errorText != null && _controller == null) {
      return _buildErrorState();
    }
    if (_capturedBytes != null) {
      return _buildCapturedState();
    }
    return _buildCameraState();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            TitleTextView(
              _errorText ?? Messages.errorFaceCaptureFailed,
              textSize: 14,
              textColor: Colors.white,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              onTap: _cancel,
              text: Strings.btnTextCancel,
              textSize: 16,
              buttonColor: kPrimaryLightColor,
              textColor: Colors.white,
              buttonWidth: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraState() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              if (_isProcessing && !_challengeRunning)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        TitleTextView(
                          Messages.progressInProgress,
                          textColor: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TitleTextView(
                _challengeStatusText ?? Messages.faceVerificationHint,
                textSize: 13,
                textColor: Colors.white70,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_errorText != null)
                TitleTextView(
                  _errorText!,
                  textSize: 13,
                  textColor: Colors.orangeAccent,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              CustomButton(
                onTap: _isProcessing ? () {} : _capture,
                text: Messages.faceVerificationTitle,
                textSize: 16,
                buttonColor: kPrimaryLightColor,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedState() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.memory(
                _capturedBytes!,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  onTap: _retake,
                  text: Messages.btnTextRetakeFace,
                  textSize: 16,
                  buttonColor: Colors.grey.shade700,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  onTap: _confirm,
                  text: Messages.btnTextUseFace,
                  textSize: 16,
                  buttonColor: kPrimaryLightColor,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
