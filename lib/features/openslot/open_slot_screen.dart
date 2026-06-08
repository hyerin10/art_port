import 'package:art_port/features/artist_application/artist_application_entry_view.dart';
import 'package:art_port/features/artist_application/widgets/artist_approved_gate.dart';
import 'package:art_port/features/openslot/open_slot_view.dart';
import 'package:flutter/material.dart';

class OpenSlotScreen extends StatelessWidget {
  const OpenSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ArtistApprovedGate(
      entryTab: ArtistApplicationEntryTab.openSlot,
      approvedChild: OpenSlotView(),
    );
  }
}
