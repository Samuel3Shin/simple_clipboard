import 'dart:io';
import 'dart:io' show Platform;

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544~4354546703";
      return "ca-app-pub-2551410065860924~7132439238";
    } else if (Platform.isIOS) {
      // return "ca-app-pub-3940256099942544~2594085930";
      return "ca-app-pub-2551410065860924~3350581677";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544/8865242552";
      return "ca-app-pub-2551410065860924/7044809324";
    } else if (Platform.isIOS) {
      // return "ca-app-pub-3940256099942544/4339318960";
      return "ca-app-pub-2551410065860924/4123132510";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3940256099942544/7049598008";
  //   } else if (Platform.isIOS) {
  //     return "ca-app-pub-3940256099942544/3964253750";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }

  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3940256099942544/8673189370";
  //   } else if (Platform.isIOS) {
  //     return "ca-app-pub-3940256099942544/7552160883";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }
}
