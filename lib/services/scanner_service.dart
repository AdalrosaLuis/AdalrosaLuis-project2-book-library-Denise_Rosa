import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class ScannerService {
  // Função para abrir o ecrã de scan e devolver o código ISBN
  static Future<String?> scanBarcode(BuildContext context) async {
    String? barcode;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              barcode = barcodes.first.rawValue;
              Navigator.pop(context); // Fecha o scanner ao detetar
            }
          },
        ),
      ),
    );
    return barcode;
  }
}