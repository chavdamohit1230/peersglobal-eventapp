import 'package:flutter/material.dart';
import '../modelClass/exhibiter_model.dart';

class ExhibiterWidgets extends StatelessWidget {

  final Exhibiter exhibiter;

  const ExhibiterWidgets({super.key, required this. exhibiter});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(exhibiter.Imageurl, height: 50, fit: BoxFit.contain),
                const SizedBox(height: 10),
                Text(
                  exhibiter.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(8)),
              ),
              child: Text(exhibiter
                  .badge, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
