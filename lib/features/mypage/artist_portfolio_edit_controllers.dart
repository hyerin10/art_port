import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:flutter/material.dart';

/// 프로필/포트폴리오 편집 화면 텍스트 컨트롤러 묶음
class ArtistPortfolioEditControllers {
  final nickname = TextEditingController();
  final oneLineIntro = TextEditingController();
  final detailedIntro = TextEditingController();
  final workNotice = TextEditingController();
  final twitter = TextEditingController();
  final instagram = TextEditingController();
  final website = TextEditingController();

  var _initialized = false;

  void syncFrom(ArtistPortfolioEditState form) {
    if (_initialized) return;

    nickname.text = form.nickname;
    oneLineIntro.text = form.oneLineIntro;
    detailedIntro.text = form.detailedIntro;
    workNotice.text = form.workNotice;
    twitter.text = form.twitterHandle;
    instagram.text = form.instagramHandle;
    website.text = form.websiteUrl;
    _initialized = true;
  }

  void dispose() {
    nickname.dispose();
    oneLineIntro.dispose();
    detailedIntro.dispose();
    workNotice.dispose();
    twitter.dispose();
    instagram.dispose();
    website.dispose();
  }
}
