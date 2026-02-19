import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_parser/mrz_parser.dart';

class PassportScanner {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Map<String, String>?> processImage(InputImage inputImage) async {
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Filter for MRZ
      final mrzLines = _extractMRZLines(recognizedText);

      if (mrzLines.isNotEmpty) {
        // Try manual parsing first (more lenient)
        final manualResult = _manualParseMRZ(mrzLines);
        if (manualResult != null) {
          return manualResult;
        }

        // Fallback to strict parser if manual fails (unlikely)
        try {
          // Clean up strictly for library
          final cleanedLines = mrzLines.map((line) => _cleanMRZLine(line)).toList();
          final result = MRZParser.parse(cleanedLines);
          return {
            'surname': result.surnames,
            'givenNames': result.givenNames,
            'documentNumber': result.documentNumber,
            'nationality': result.nationalityCountryCode,
            'birthDate': result.birthDate.toString().split(' ')[0],
            'expiryDate': result.expiryDate.toString().split(' ')[0],
            'sex': result.sex.toString().split('.').last,
          };
        } catch (e) {
          print("Strict parsing also failed: $e");
          return null;
        }
      }
      return null;
    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }

  // Manually parse TD3 (Passport) format - 2 lines, 44 chars
  Map<String, String>? _manualParseMRZ(List<String> lines) {
    if (lines.length < 2) return null;

    final line1 = lines[0].replaceAll(' ', '').toUpperCase();
    final line2 = lines[1].replaceAll(' ', '').toUpperCase();

    // Basic Structure Check: Line 1 starts P, Line 2 needs numbers
    if (!line1.startsWith('P') && !line1.startsWith('I') && !line1.startsWith('A')) return null;

    try {
      // Extract Surname/Given Names from Line 1
      // Format: P<CCCPrimaryIdentifier<<SecondaryIdentifier<<<<<<<<<<<<
      // Skip first 5 chars (P<Eg)
      final namePart = line1.substring(5).replaceAll('<', ' ').trim();
      final names = namePart.split('  '); // Double space separates surname/given
      String surname = names.isNotEmpty ? names[0] : "";
      String givenName = names.length > 1 ? names[1] : "";

      // Extract Document Number from Line 2 (Chars 0-9)
      String docNumber = line2.length > 9 ? line2.substring(0, 9).replaceAll('<', '') : "";

      // Extract Nationality from Line 2 (Chars 10-13)
      String nationality = line2.length > 13 ? line2.substring(10, 13).replaceAll('<', '') : "";

      // Extract DOB (Chars 13-19: YYMMDD)
      String dob = line2.length > 19 ? line2.substring(13, 19) : "";
      dob = _formatDate(dob);

      // Extract Expiry (Chars 21-27: YYMMDD)
      String expiry = line2.length > 27 ? line2.substring(21, 27) : "";
      expiry = _formatDate(expiry);

      // Extract Sex (Char 20)
      String sexCode = line2.length > 20 ? line2.substring(20, 21) : "";
      String sex = sexCode == 'M' ? 'Male' : sexCode == 'F' ? 'Female' : sexCode;

      return {
        'surname': surname,
        'givenNames': givenName,
        'documentNumber': docNumber,
        'nationality': nationality,
        'birthDate': dob,
        'expiryDate': expiry,
        'sex': sex,
        'rawMRZ': "$line1\n$line2"
      };
    } catch (e) {
      print("Manual parsing error: $e");
      return null;
    }
  }

  String _formatDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;
    int yy = int.tryParse(yymmdd.substring(0, 2)) ?? 0;
    String century = yy > 50 ? '19' : '20'; // 50+ = 1900s, <50 = 2000s
    return "$century${yymmdd.substring(0, 2)}-${yymmdd.substring(2, 4)}-${yymmdd.substring(4, 6)}";
  }

  // Clean common OCR errors in MRZ text
  String _cleanMRZLine(String line) {
    String cleaned = line;
    
    // Replace common OCR mistakes for special characters
    cleaned = cleaned.replaceAll('«', '<');  // Left angle quote → less than
    cleaned = cleaned.replaceAll('»', '<');  // Right angle quote → less than
    cleaned = cleaned.replaceAll('‹', '<');  // Single left angle quote
    cleaned = cleaned.replaceAll('›', '<');  // Single right angle quote
    cleaned = cleaned.replaceAll(' ', '');   // Remove any spaces
    cleaned = cleaned.replaceAll('|', 'I');  // Pipe → I
    
    // Ensure uppercase
    cleaned = cleaned.toUpperCase();
    
    return cleaned;
  }

  List<String> _extractMRZLines(RecognizedText text) {
    List<String> lines = [];
    List<String> allLines = []; // For debugging
    
    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        final String cleanedText = line.text.replaceAll(' ', '').toUpperCase();
        allLines.add(cleanedText); // Capture all for debugging
        
        // More lenient MRZ detection:
        // 1. Starts with P< (passport), I<, V<, A<, C<
        // 2. OR contains < characters and is long enough (likely MRZ)
        // 3. OR looks like second MRZ line (starts with letter+digit pattern)
        
        final bool startsWithMRZPrefix = cleanedText.startsWith('P<') || 
                                          cleanedText.startsWith('I<') || 
                                          cleanedText.startsWith('V<') ||
                                          cleanedText.startsWith('A<') ||
                                          cleanedText.startsWith('C<');
        
        final bool hasMultipleBrackets = cleanedText.split('<').length >= 3;
        final bool isLongEnough = cleanedText.length >= 30;
        
        // Check if it matches second line pattern (starts with letter followed by digits)
        final bool looksLikeSecondLine = RegExp(r'^[A-Z]\d{8,}').hasMatch(cleanedText) && isLongEnough;
        
        if ((startsWithMRZPrefix || (hasMultipleBrackets && isLongEnough) || looksLikeSecondLine)) {
           print("✅ MRZ Line detected: $cleanedText");
           lines.add(cleanedText);
        }
      }
    }
    
    // Debug output
    print("════════ OCR DEBUG ════════");
    print("Total lines read: ${allLines.length}");
    print("All lines: $allLines");
    print("MRZ lines found: ${lines.length}");
    print("MRZ content: $lines");
    print("═══════════════════════════");
    
    return lines;
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}
