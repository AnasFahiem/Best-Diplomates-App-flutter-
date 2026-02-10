import 'package:camera/camera.dart';

enum VerificationStep {
  instruction,
  scanning,
  processing,
  success,
  failure,
}

abstract class VerificationState {
  final VerificationStep step;
  final String message;

  VerificationState(this.step, this.message);
}

class InstructionState extends VerificationState {
  InstructionState(String message) : super(VerificationStep.instruction, message);
}

class ScanningState extends VerificationState {
  ScanningState(String message) : super(VerificationStep.scanning, message);
}

class ProcessingState extends VerificationState {
  ProcessingState(String message) : super(VerificationStep.processing, message);
}

class SuccessState extends VerificationState {
  final dynamic data; // Extracted MRZ or Face Image
  SuccessState(this.data) : super(VerificationStep.success, "Verification Successful");
}

class FailureState extends VerificationState {
  FailureState(String error) : super(VerificationStep.failure, error);
}
