import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraProcessorView extends StatefulWidget {
  final Function(InputImage inputImage) onImage;
  final Widget? overlay;
  final String instruction;
  final bool isFrontCamera;

  const CameraProcessorView({
    super.key,
    required this.onImage,
    this.overlay,
    required this.instruction,
    this.isFrontCamera = false,
  });

  @override
  State<CameraProcessorView> createState() => _CameraProcessorViewState();
}

class _CameraProcessorViewState extends State<CameraProcessorView> {
  CameraController? _controller;
  bool _isProcessing = false;
  int _lastFrameTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Camera permission is required.')),
        );
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No cameras found");
        return;
      }

      final camera = widget.isFrontCamera
          ? cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first)
          : cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);

      // 1. Lower Resolution Preset (Medium) for compatibility
      // 2. Explicitly specify ImageFormatGroup.yuv420 for Android (better for ML Kit)
      _controller = CameraController(
        camera,
        ResolutionPreset.medium, 
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      
      // Force focus mode for back camera (Passport Scan)
      if (!widget.isFrontCamera) {
         await _controller!.setFocusMode(FocusMode.auto);
      }

      // Start Stream
      await _controller!.startImageStream(_processImage);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera initialization failed: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error initializing camera: $e')),
         );
      }
    }
  }

  void _processImage(CameraImage image) {
    if (_isProcessing) return;
    
    // Throttle: Process 1 frame every 500ms
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _lastFrameTime < 500) return;
    
    _isProcessing = true;
    _lastFrameTime = currentTime;

    // Convert CameraImage to InputImage for ML Kit
    // Note: A full robust conversion requires handling rotation and format specifics.
    // This is a simplified version.
    
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage != null) {
      // Run the callback (which runs ML Kit)
      // We don't await here to keep stream smooth, but we flag _isProcessing
      widget.onImage(inputImage).then((_) {
        _isProcessing = false;
      }).catchError((e) {
        _isProcessing = false;
      });
    } else {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // This conversion depends heavily on platform and sensor orientation.
    // For a production app, use the official helper functions provided in ML Kit docs.
    // Assuming portrait mode for simplicity in this MVP.
    final sensorOrientation = _controller!.description.sensorOrientation;
    final InputImageRotation rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
    
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;
    
    final plane = image.planes.first;
    
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Force aspect ratio to fix rendering issues
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    
    return Stack(
      children: [
        // Wrap preview with Transform to ensure proper rendering
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        if (widget.overlay != null) widget.overlay!,
        // Top Instruction
        Align(
          alignment: Alignment.topCenter,
          child: Container(
             margin: const EdgeInsets.only(top: 50),
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
             decoration: BoxDecoration(
               color: Colors.black54,
               borderRadius: BorderRadius.circular(20),
             ),
             child: Text(
               widget.instruction,
               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
             ),
          ),
        ),
        // Bottom Shutter Button
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: FloatingActionButton(
              onPressed: _manualCapture,
              backgroundColor: Colors.white,
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _manualCapture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    
    try {
      _isProcessing = true;
      final XFile file = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      
      await widget.onImage(inputImage);
    } catch (e) {
      debugPrint("Error capturing image: $e");
    } finally {
      if (mounted) {
         setState(() {
           _isProcessing = false;
         });
      }
    }
  }
}

class PassportOverlay extends StatelessWidget {
  const PassportOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const HoleOverlay(isCircle: false);
  }
}

class FaceOverlay extends StatelessWidget {
  const FaceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const HoleOverlay(isCircle: true);
  }
}

class HoleOverlay extends StatelessWidget {
  final bool isCircle;
  const HoleOverlay({super.key, required this.isCircle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final width = size.width;
        final height = size.height;

        double cutoutWidth;
        double cutoutHeight;
        double tempTop;

        if (isCircle) {
           final radius = width * 0.35;
           cutoutWidth = radius * 2;
           cutoutHeight = radius * 2;
           tempTop = (height - cutoutHeight) / 2;
        } else {
           // Passport: 0.9 width, 0.65 aspect ratio
           cutoutWidth = width * 0.9;
           cutoutHeight = cutoutWidth * 0.65;
           tempTop = (height - cutoutHeight) / 2;
        }

        final sidePadding = (width - cutoutWidth) / 2;
        final topPadding = tempTop;
        final bottomPadding = height - topPadding - cutoutHeight;

        final Color maskColor = Colors.black.withOpacity(0.7);

        return Stack(
          children: [
            Column(
              children: [
                // Top Mask
                Container(height: topPadding, width: width, color: maskColor),
                
                // Middle Section containing Left, Cutout, Right
                SizedBox(
                  height: cutoutHeight,
                  child: Row(
                    children: [
                      // Left Mask
                      Container(width: sidePadding, height: cutoutHeight, color: maskColor),
                      
                      // Cutout (Transparent)
                      Container(
                        width: cutoutWidth,
                        height: cutoutHeight,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: isCircle ? BorderRadius.circular(cutoutWidth/2) : BorderRadius.circular(12),
                        ),
                      ),
                      
                      // Right Mask
                      Container(width: sidePadding, height: cutoutHeight, color: maskColor),
                    ],
                  ),
                ),
                
                // Bottom Mask
                Container(height: bottomPadding, width: width, color: maskColor),
              ],
            ),
          ],
        );
      },
    );
  }
}
