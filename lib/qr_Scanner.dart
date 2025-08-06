import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool isScanned = false; // 👈 to prevent multiple triggers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanned) return; // 👈 stop duplicate scans

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            setState(() {
              isScanned = true;
            });

            // 👇 Snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Scanned: $code')),
            );

            // 👇 Add any action here (navigate or pass data)
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context, code); // 👈 return scanned value
            });
          }
        },
      ),
    );
  }
}
