import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7581133893794696~7717799221";
    }
    else if (Platform.isIOS) {
      return "ca-app-pub-7581133893794696~7937209892";
    }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test Only!!!
      // return "ca-app-pub-3940256099942544/6300978111";
      return "ca-app-pub-7581133893794696/3921367906";
    }
    else if (Platform.isIOS) {
      return "ca-app-pub-7581133893794696/4460983400";
    }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}