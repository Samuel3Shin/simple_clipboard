import 'dart:io';
import 'dart:io' show Platform;
import 'package:firebase_admob/firebase_admob.dart';

class AdManager {
  BannerAd _bannerAd;

  String appID = Platform.isIOS
      ? 'ca-app-pub-2551410065860924~3350581677' // iOS Test App ID
      : 'ca-app-pub-2551410065860924~7132439238'; // Android Test App ID
  String bannerID = BannerAd.testAdUnitId;
  String interstitialID = InterstitialAd.testAdUnitId;

  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'firebase', 'admob'],
    testDevices: <String>[],
  );

  init() async {
    FirebaseAdMob.instance.initialize(appId: appID);
    _bannerAd = createBannerAd();
    _bannerAd
      ..load()
      ..show();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerID,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544~4354546703";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544~2594085930";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/8865242552";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4339318960";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/7049598008";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/3964253750";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/8673189370";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/7552160883";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
