import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PizzaImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BorderRadius? radius;

  const PizzaImage({super.key, this.url, this.height, this.width, this.radius});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: width,
      color: AppTheme.orangeLight,
      child: const Icon(Icons.local_pizza, size: 48, color: AppTheme.orange),
    );

    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(16),
      child: (url == null || url!.trim().isEmpty)
          ? placeholder
          : Image.network(
              url!,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}