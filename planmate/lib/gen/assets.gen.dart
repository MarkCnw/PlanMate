// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsAvatarGen {
  const $AssetsAvatarGen();

  /// File path: assets/avatar/NogoogleImage.png
  AssetGenImage get nogoogleImage =>
      const AssetGenImage('assets/avatar/NogoogleImage.png');

  /// File path: assets/avatar/avatar1.png
  AssetGenImage get avatar1 => const AssetGenImage('assets/avatar/avatar1.png');

  /// File path: assets/avatar/avatar2.png
  AssetGenImage get avatar2 => const AssetGenImage('assets/avatar/avatar2.png');

  /// File path: assets/avatar/avatar3.png
  AssetGenImage get avatar3 => const AssetGenImage('assets/avatar/avatar3.png');

  /// File path: assets/avatar/create.svg
  String get create => 'assets/avatar/create.svg';

  /// File path: assets/avatar/his.svg
  String get his => 'assets/avatar/his.svg';

  /// File path: assets/avatar/hisssss.svg
  String get hisssss => 'assets/avatar/hisssss.svg';

  /// File path: assets/avatar/no_project.svg
  String get noProject => 'assets/avatar/no_project.svg';

  /// File path: assets/avatar/profile1.svg
  String get profile1 => 'assets/avatar/profile1.svg';

  /// File path: assets/avatar/se.svg
  String get se => 'assets/avatar/se.svg';

  /// File path: assets/avatar/team_profile.svg
  String get teamProfile => 'assets/avatar/team_profile.svg';

  /// List of all assets
  List<dynamic> get values => [
    nogoogleImage,
    avatar1,
    avatar2,
    avatar3,
    create,
    his,
    hisssss,
    noProject,
    profile1,
    se,
    teamProfile,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/Chess.png
  AssetGenImage get chess => const AssetGenImage('assets/icons/Chess.png');

  /// File path: assets/icons/Egg&Bacon.png
  AssetGenImage get eggBacon =>
      const AssetGenImage('assets/icons/Egg&Bacon.png');

  /// File path: assets/icons/Football.png
  AssetGenImage get football =>
      const AssetGenImage('assets/icons/Football.png');

  /// File path: assets/icons/Gymming.png
  AssetGenImage get gymming => const AssetGenImage('assets/icons/Gymming.png');

  /// File path: assets/icons/Pizza.png
  AssetGenImage get pizza => const AssetGenImage('assets/icons/Pizza.png');

  /// File path: assets/icons/arrow.png
  AssetGenImage get arrow => const AssetGenImage('assets/icons/arrow.png');

  /// File path: assets/icons/arrow_long_left.svg
  String get arrowLongLeft => 'assets/icons/arrow_long_left.svg';

  /// File path: assets/icons/book.png
  AssetGenImage get book => const AssetGenImage('assets/icons/book.png');

  /// File path: assets/icons/check&cal.png
  AssetGenImage get checkCal =>
      const AssetGenImage('assets/icons/check&cal.png');

  /// File path: assets/icons/check.png
  AssetGenImage get check => const AssetGenImage('assets/icons/check.png');

  /// File path: assets/icons/computer.png
  AssetGenImage get computer =>
      const AssetGenImage('assets/icons/computer.png');

  /// File path: assets/icons/crayons.png
  AssetGenImage get crayons => const AssetGenImage('assets/icons/crayons.png');

  /// File path: assets/icons/esports.png
  AssetGenImage get esports => const AssetGenImage('assets/icons/esports.png');

  /// File path: assets/icons/google.png
  AssetGenImage get google => const AssetGenImage('assets/icons/google.png');

  /// File path: assets/icons/pencil.png
  AssetGenImage get pencil => const AssetGenImage('assets/icons/pencil.png');

  /// File path: assets/icons/rocket.png
  AssetGenImage get rocket => const AssetGenImage('assets/icons/rocket.png');

  /// File path: assets/icons/ruler.png
  AssetGenImage get ruler => const AssetGenImage('assets/icons/ruler.png');

  /// List of all assets
  List<dynamic> get values => [
    chess,
    eggBacon,
    football,
    gymming,
    pizza,
    arrow,
    arrowLongLeft,
    book,
    checkCal,
    check,
    computer,
    crayons,
    esports,
    google,
    pencil,
    rocket,
    ruler,
  ];
}

class Assets {
  const Assets._();

  static const String a2 = 'assets/2.svg';
  static const String a3 = 'assets/3.svg';
  static const $AssetsAvatarGen avatar = $AssetsAvatarGen();
  static const String buttonOnboarding = 'assets/button_onboarding.svg';
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const String login = 'assets/login.svg';
  static const String onboarding = 'assets/onboarding.svg';
  static const String signup = 'assets/signup.svg';

  /// List of all assets
  static List<String> get values => [
    a2,
    a3,
    buttonOnboarding,
    login,
    onboarding,
    signup,
  ];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
