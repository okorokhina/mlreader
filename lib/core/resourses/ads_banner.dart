import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io';

const bannerAndroidId = "ca-app-pub-7986696519803132/8919906509";
const banneriOSId = "ca-app-pub-7986696519803132/2797011978";

class Ads {

  BannerAd bannerAd;

   Future showBanner() {
    bannerAd ??= createBannerAd();
    bannerAd
      ..load()
      ..show(
        anchorOffset: 0.0,
        anchorType: AnchorType.bottom,
      );
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: 
     BannerAd.testAdUnitId,
      // TODO: Release version ADS
      //  Platform.isAndroid
      //    ? bannerAndroidId
      //    : banneriOSId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print('BannerAd event $event');
        if(event == MobileAdEvent.loaded){
          bannerAd..show();
        }
      },
    );
  }
}