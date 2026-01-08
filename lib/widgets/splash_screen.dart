import 'package:flutter/material.dart';
import '../main_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo simple
            Image.asset(
              'assets/images/logo3.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 250,
                  height: 250,
                  color: Colors.grey.withAlpha(20),
                  child: Icon(
                    Icons.content_cut,
                    color: SystemMovilColors.primary,
                    size: 80,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            
            // Loader simple
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SystemMovilColors.primary),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

