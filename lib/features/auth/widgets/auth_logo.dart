import 'package:flutter/material.dart';

enum AuthLogoVariant { full, icon }

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.height = 88,
    this.variant = AuthLogoVariant.full,
  });

  final double height;
  final AuthLogoVariant variant;

  String get _assetPath => switch (variant) {
        AuthLogoVariant.full => 'assets/branding/art_port_auth_logo.png',
        AuthLogoVariant.icon => 'assets/branding/art_port_icon.png',
      };

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Image.asset(
        _assetPath,
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
