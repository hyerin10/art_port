import 'package:art_port/features/review/my_reviews_view.dart';
import 'package:flutter/material.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key, required this.kind});

  final ReviewListKind kind;

  static void open(BuildContext context, {required ReviewListKind kind}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyReviewsScreen(kind: kind),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyReviewsView(kind: kind);
  }
}
