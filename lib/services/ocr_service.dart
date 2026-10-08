import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/parsed_bank_bill.dart';
import 'bank_bill_parser.dart';

class OcrService {
  TextRecognizer? _textRecognizer;

  TextRecognizer get textRecognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Xử lý nhận diện văn bản On-Device từ file ảnh chuyển khoản
  Future<ParsedBankBill> processBankBill(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      debugPrint('--- OCR RAW OUTPUT ---');
      debugPrint(recognizedText.text);
      debugPrint('-----------------------');

      return BankBillParser.parse(recognizedText.text, imagePath);
    } catch (e) {
      debugPrint('Lỗi OCR: $e');
      // Trả về đối tượng fallback nếu OCR gặp lỗi để không crash app
      return ParsedBankBill(
        amount: null,
        transferContent: '',
        imagePath: imagePath,
        rawOcrText: 'Lỗi nhận dạng: $e',
      );
    }
  }

  void dispose() {
    _textRecognizer?.close();
  }
}
