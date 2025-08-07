import 'package:flutter/material.dart';

class QrScanresult extends StatelessWidget {
  final String qrCode;

  const QrScanresult({super.key,required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: Center(
        child: Text(
          'Scanned QR Code:\n$qrCode',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
