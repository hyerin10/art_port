import 'package:flutter/material.dart';

class ReviewStars extends StatelessWidget {
  const ReviewStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.onChanged,
  });

  final double rating;
  final double size;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(i.toDouble()),
            child: Icon(
              i <= rating.round()
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: const Color(0xFFF59E0B),
            ),
          ),
      ],
    );
  }
}
