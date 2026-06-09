import 'package:art_port/features/artist_application/artist_application_entry_view.dart';
import 'package:art_port/features/artist_application/widgets/artist_approved_gate.dart';
import 'package:art_port/features/auth/widgets/login_required_gate.dart';
import 'package:art_port/features/openslot/open_slot_view.dart';
import 'package:flutter/material.dart';

class OpenSlotScreen extends StatelessWidget {
  const OpenSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginRequiredGate(
      title: '로그인이 필요합니다',
      subtitle: '오픈 슬롯을 이용하려면\n로그인 후 이용해 주세요.',
      child: const ArtistApprovedGate(
        entryTab: ArtistApplicationEntryTab.openSlot,
        approvedChild: OpenSlotView(),
      ),
    );
  }
}
