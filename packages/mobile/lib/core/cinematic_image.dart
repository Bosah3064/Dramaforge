import 'package:flutter/material.dart';
import 'theme.dart';

class CinematicImage extends StatelessWidget {
  final String? imageUrl;
  final String? placeholderText;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const CinematicImage({
    Key? key,
    this.imageUrl,
    this.placeholderText,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        color: AppTheme.darkBackground,
        child: (imageUrl != null && imageUrl!.startsWith('http'))
            ? Image.network(
                imageUrl!,
                fit: fit,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildStylizedArtPlaceholder();
                },
              )
            : _buildStylizedArtPlaceholder(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade900.withOpacity(0.5),
            Colors.indigo.shade900.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPurple),
        ),
      ),
    );
  }

  Widget _buildStylizedArtPlaceholder() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1B4B),
                const Color(0xFF311042),
                AppTheme.darkBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Cinematic Viewfinder Grid
        Positioned.fill(
          child: CustomPaint(
            painter: _CinematicGridPainter(),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryPurple.withOpacity(0.25),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.6)),
                ),
                child: const Icon(Icons.movie_creation_outlined, color: Colors.white, size: 28),
              ),
              if (placeholderText != null && placeholderText!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    placeholderText!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CinematicGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Corner reticles
    const double len = 12.0;
    // Top-left
    canvas.drawLine(const Offset(8, 8), const Offset(8 + len, 8), paint);
    canvas.drawLine(const Offset(8, 8), const Offset(8, 8 + len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - 8, 8), Offset(size.width - 8 - len, 8), paint);
    canvas.drawLine(Offset(size.width - 8, 8), Offset(size.width - 8, 8 + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(8, size.height - 8), Offset(8 + len, size.height - 8), paint);
    canvas.drawLine(Offset(8, size.height - 8), Offset(8, size.height - 8 - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - 8, size.height - 8), Offset(size.width - 8 - len, size.height - 8), paint);
    canvas.drawLine(Offset(size.width - 8, size.height - 8), Offset(size.width - 8, size.height - 8 - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
