import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (isScanned) return;

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            setState(() {
              isScanned = true;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scanned: $code')),
              );
            }

            Future.delayed(const Duration(seconds: 1), () async {
              await _controller.stop();
              if (mounted) {
                context.push('/result/$code');
              }
            });
          }
        },
      ),
    );
  }
}
