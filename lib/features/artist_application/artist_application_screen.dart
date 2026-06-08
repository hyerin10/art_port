import 'package:art_port/features/artist_application/artist_application_view.dart';
import 'package:flutter/material.dart';

class ArtistApplicationScreen extends StatelessWidget {
  const ArtistApplicationScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const ArtistApplicationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ArtistApplicationView();
  }
}
