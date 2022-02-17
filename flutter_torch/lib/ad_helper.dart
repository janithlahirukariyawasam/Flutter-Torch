import 'dart:io';

class AdHelper {

  static String get interstitialAdUnitId {
    //Those are original keys
    if (Platform.isAndroid) {
      return "";
    } else if (Platform.isIOS) {
      return "";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

}