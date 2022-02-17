import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:torch_light/torch_light.dart';
import 'ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(TorchApp());
}

class TorchApp extends StatefulWidget {
  @override
  _TorchAppState createState() => _TorchAppState();
}

class _TorchAppState extends State<TorchApp> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  InterstitialAd _interstitialAd;
  int num_of_attempt_load = 0;
  void interstitialLoad() async {
    await InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          this._interstitialAd = ad;
          print('Ad was loaded');
          num_of_attempt_load = 0;
        }, onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load');
          num_of_attempt_load + 1;
          _interstitialAd = null;

          if (num_of_attempt_load <= 2) {
            interstitialLoad();
          }
        }));
  }

  void showInterstitial() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('on ad showed'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) =>
          print('on ad dismissed'),
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('on ad failed');
        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) => print('Impression occured'),
    );

    _interstitialAd.show();
    _interstitialAd = null;
    interstitialLoad();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [Locale('en', '')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Flashlight'),
          backgroundColor: Colors.black,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: RaisedButton(
                child: //Text('Enable torch'),
                    Icon(
                  Icons.power_settings_new_outlined,
                  size: 128,
                ),
                onPressed: () async {
                  if (_interstitialAd == null) {
                    interstitialLoad();
                  } else {
                    print('Interstitial present');
                  }
                  showInterstitial();
                  print('button tapped');
                  _enableTorch(context);
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Container(
                    width: 128,
                    child: Center(
                      child: Text(
                        'OFF',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )),
                onPressed: () {
                  if (_interstitialAd == null) {
                    interstitialLoad();
                  } else {
                    print('Interstitial present');
                  }
                  showInterstitial();
                  print('button tapped');
                  _disableTorch(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _enableTorch(BuildContext context) async {
    try {
      await TorchLight.enableTorch();
    } on EnableTorchException catch (e) {
      _showMessage(e.message);
    }
  }

  _disableTorch(BuildContext context) async {
    try {
      await TorchLight.disableTorch();
    } on DisableTorchException catch (e) {
      _showMessage(e.message);
    }
  }

  _showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
