import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  // Removi o const daqui para evitar conflitos
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCANNER DE ISBN'),
        backgroundColor: const Color(0xFFFFB7C5),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (!isScanCompleted) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String code = barcode.rawValue ?? "---";
              isScanCompleted = true;
              debugPrint('Código detetado: $code');
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}