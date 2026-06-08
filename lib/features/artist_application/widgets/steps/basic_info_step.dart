import 'package:art_port/features/artist_application/artist_application_providers.dart';
import 'package:art_port/features/artist_application/models/artist_application_data.dart';
import 'package:art_port/features/artist_application/widgets/artist_application_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicInfoStep extends ConsumerWidget {
  const BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(artistApplicationFormProvider).data;
    final notifier = ref.read(artistApplicationFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArtistApplicationStepTitle(
          titleKo: ArtistApplicationStep.basicInfo.titleKo,
          titleEn: ArtistApplicationStep.basicInfo.titleEn,
        ),
        const SizedBox(height: 24),
        ArtistApplicationTextField(
          key: ValueKey('artist-name-${data.artistName}'),
          label: '활동명 (Artist Name)',
          hintText: '예: 아트마스터',
          value: data.artistName,
          onChanged: notifier.setArtistName,
        ),
        const SizedBox(height: 24),
        const ArtistApplicationSectionHeader(
          title: '정산 계좌 정보 (Settlement Account)',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 16),
        ArtistApplicationDropdown<String>(
          label: '은행 선택 (Bank)',
          hintText: '은행을 선택하세요',
          value: data.bankName,
          items: ArtistApplicationData.bankOptions,
          itemLabel: (v) => v,
          onChanged: notifier.setBankName,
        ),
        const SizedBox(height: 16),
        ArtistApplicationTextField(
          key: ValueKey('account-number-${data.accountNumber}'),
          label: '계좌번호 (Account Number)',
          hintText: "'-' 없이 숫자만 입력",
          value: data.accountNumber,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: notifier.setAccountNumber,
        ),
        const SizedBox(height: 16),
        ArtistApplicationTextField(
          key: ValueKey('account-holder-${data.accountHolder}'),
          label: '예금주 (Account Holder)',
          hintText: '본인 실명',
          value: data.accountHolder,
          onChanged: notifier.setAccountHolder,
        ),
      ],
    );
  }
}
