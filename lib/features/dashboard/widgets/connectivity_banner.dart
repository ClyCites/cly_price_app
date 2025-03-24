import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        SlideEffect(
          begin: Offset(0, -1),
          end: Offset.zero,
          duration: Duration(milliseconds: 300),
        ),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.red.shade700,
        child: const Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'You are offline. Some features may be limited.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

