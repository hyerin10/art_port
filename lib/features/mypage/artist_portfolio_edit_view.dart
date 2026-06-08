import 'package:art_port/features/mypage/artist_portfolio_edit_actions.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_controllers.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_providers.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_edit_form.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_edit_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_save_footer_button.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistPortfolioEditView extends ConsumerStatefulWidget {
  const ArtistPortfolioEditView({super.key});

  @override
  ConsumerState<ArtistPortfolioEditView> createState() =>
      _ArtistPortfolioEditViewState();
}

class _ArtistPortfolioEditViewState
    extends ConsumerState<ArtistPortfolioEditView> {
  final _controllers = ArtistPortfolioEditControllers();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(artistPortfolioEditProvider);
    final notifier = ref.read(artistPortfolioEditProvider.notifier);
    _controllers.syncFrom(form);

    return MyPageSubScreenScaffold(
      header: ArtistPortfolioEditHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ArtistPortfolioEditForm(
        form: form,
        controllers: _controllers,
        notifier: notifier,
        onBackgroundTap: () =>
            ArtistPortfolioEditActions.pickBackground(context, ref),
        onAvatarTap: () => ArtistPortfolioEditActions.pickAvatar(context, ref),
        onAddPortfolioImages: () =>
            ArtistPortfolioEditActions.pickPortfolioImages(context, ref),
      ),
      footer: MyPageSaveFooterButton(
        label: '저장하기',
        isSaving: form.isSaving,
        onPressed: () => ArtistPortfolioEditActions.save(context, ref),
      ),
    );
  }
}
