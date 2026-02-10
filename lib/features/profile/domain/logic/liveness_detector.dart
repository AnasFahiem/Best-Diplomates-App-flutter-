import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum LivenessGesture {
  smile,
  blink,
  turnHeadLeft,
  turnHeadRight,
  none
}

class LivenessDetector {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // For smile/eyes
      enableLandmarks: true, // For head pose
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    ),
  );

  LivenessGesture currentGestureRequest = LivenessGesture.none;
  
  // Thresholds
  static const double _smileThreshold = 0.8;
  static const double _blinkThreshold = 0.1;
  static const double _headTurnThreshold = 20.0;

  Future<bool> processImage(InputImage inputImage, LivenessGesture requiredGesture) async {
    final List<Face> faces = await _faceDetector.processImage(inputImage);
    
    if (faces.isEmpty) return false;
    final Face face = faces.first;

    switch (requiredGesture) {
      case LivenessGesture.smile:
        return (face.smilingProbability ?? 0) > _smileThreshold;
        
      case LivenessGesture.blink:
        // Check if either eye is closed
        return (face.leftEyeOpenProbability ?? 1) < _blinkThreshold || 
               (face.rightEyeOpenProbability ?? 1) < _blinkThreshold;
               
      case LivenessGesture.turnHeadLeft:
         // Head Euler Angle Y: Positive is left, Negative is right (typically, depends on camera sensor orientation)
         // Let's assume standard front camera mirroring
         return (face.headEulerAngleY ?? 0) > _headTurnThreshold;

      case LivenessGesture.turnHeadRight:
         return (face.headEulerAngleY ?? 0) < -_headTurnThreshold;

      case LivenessGesture.none:
        return true; // Just face detection
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
