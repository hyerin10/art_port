import 'package:art_port/features/artist_profile/artist_profile_view.dart';
import 'package:flutter/material.dart';

class ArtistProfileScreen extends StatelessWidget {
  const ArtistProfileScreen({super.key, required this.artistId});

  final String artistId;

  static void open(BuildContext context, {required String artistId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArtistProfileScreen(artistId: artistId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ArtistProfileView(artistId: artistId);
  }
}
