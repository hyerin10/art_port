import 'package:art_port/features/mypage/artist_portfolio_edit_view.dart';
import 'package:flutter/material.dart';

class ArtistPortfolioEditScreen extends StatelessWidget {
  const ArtistPortfolioEditScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ArtistPortfolioEditScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ArtistPortfolioEditView();
  }
}
