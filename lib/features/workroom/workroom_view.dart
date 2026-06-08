import 'package:art_port/features/workroom/widgets/workroom_chats_list.dart';
import 'package:art_port/features/workroom/widgets/workroom_header.dart';
import 'package:art_port/features/workroom/widgets/workroom_orders_list.dart';
import 'package:art_port/features/workroom/widgets/workroom_segment_bar.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실(Workroom) 탭 내부 스크롤 콘텐츠
class WorkroomView extends ConsumerWidget {
  const WorkroomView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subTab = ref.watch(workroomSubTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkroomHeader(
          segmentBar: WorkroomSegmentBar(
            selected: subTab,
            onSelect: ref.read(workroomSubTabProvider.notifier).select,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: subTab == WorkroomSubTab.chats
              ? const WorkroomChatsList()
              : const WorkroomOrdersList(),
        ),
      ],
    );
  }
}
