import 'package:flutter/material.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

class ScannerLoader extends StatefulWidget {
  final double size;
  const ScannerLoader({super.key, this.size = 120});

  @override
  State<ScannerLoader> createState() => _ScannerLoaderState();
}

class _ScannerLoaderState extends State<ScannerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    final start = widget.size * (22.0 / 120.0);
    final end = widget.size * (88.0 / 120.0);

    _laserAnimation = Tween<double>(begin: start, end: end).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final outlineSize = size * (100.0 / 120.0);
    final docIconSize = size * (48.0 / 120.0);
    final frameSize = size * (80.0 / 120.0);
    final laserHeight = size * (3.0 / 120.0);
    final laserPadding = size * (24.0 / 120.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentTeal.withAlpha(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentTeal.withAlpha(30),
            blurRadius: size * 0.25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _scannerController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: outlineSize,
                height: outlineSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentTeal.withAlpha(40),
                    width: 1.5,
                  ),
                ),
              ),
              Icon(
                Icons.description_rounded,
                size: docIconSize,
                color: Colors.white,
              ),
              Icon(
                Icons.document_scanner_outlined,
                size: frameSize,
                color: AppTheme.accentTeal,
              ),
              Positioned(
                top: _laserAnimation.value,
                left: laserPadding,
                right: laserPadding,
                child: Container(
                  height: laserHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentIndigo.withAlpha(200),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
