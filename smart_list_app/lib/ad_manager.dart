import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7581133893794696~7717799221";
    }
    // else if (Platform.isIOS) {
    //   return "<YOUR_IOS_ADMOB_APP_ID>";
    // }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test Only!!!
      return "ca-app-pub-3940256099942544/6300978111";
      // return "ca-app-pub-7581133893794696/3921367906";
    }
    // else if (Platform.isIOS) {
    //   return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
    // }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Test only!!!
      return "ca-app-pub-3940256099942544/1033173712";
      // return "ca-app-pub-7581133893794696/6355959554";
    }
    // else if (Platform.isIOS) {
    //   return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    // }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "<YOUR_ANDROID_REWARDED_AD_UNIT_ID>";
  //   } else if (Platform.isIOS) {
  //     return "<YOUR_IOS_REWARDED_AD_UNIT_ID>";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }
}