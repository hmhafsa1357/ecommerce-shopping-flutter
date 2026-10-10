import 'package:flutter/material.dart';

/// A network image with a spinner while loading and a placeholder icon
/// if the image can't be loaded.
class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(
      Icons.image_not_supported_outlined,
      color: Theme.of(context).hintColor,
    );

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: url.isEmpty
          ? placeholder
          : Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}