import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class FeatureErrorBoundary extends StatefulWidget {
  final Widget child;
  final String featureName;
  final VoidCallback? onReset;

  const FeatureErrorBoundary({
    super.key,
    required this.child,
    required this.featureName,
    this.onReset,
  });

  @override
  State<FeatureErrorBoundary> createState() => _FeatureErrorBoundaryState();
}

class _FeatureErrorBoundaryState extends State<FeatureErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  void reset() {
    setState(() {
      _error = null;
    });
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bgSurfaceBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, color: accentCyan, size: 36),
            const SizedBox(height: 10),
            Text(
              '${widget.featureName} Self-Healing',
              style: GoogleFonts.plusJakartaSans(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A sub-module encountered an isolated issue. Main shield protection remains active.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: reset,
              child: Text(
                'Recover Component',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }
}
