import 'dart:io';

// 앱에서 사용하는 모든 광고 유닛 ID를 관리하는 클래스입니다.
class AdConstants {
  // 비공개 생성자로, 이 클래스가 인스턴스화되는 것을 방지합니다.
  AdConstants._();

  // 스페셜 조언 화면에서 사용할 리워드 광고 ID
  static String get specialAdviceRewardedAdUnitId {
    // 안드로이드와 iOS에 맞는 테스트 광고 ID입니다.
    // 배포 시에는 실제 AdMob 광고 단위 ID로 교체해야 합니다.
    if (Platform.isAndroid) {
      return 'ca-app-pub-1036680323060821/1821391042';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      // 지원하지 않는 플랫폼일 경우 예외를 발생시킵니다.
      throw UnsupportedError('Unsupported platform');
    }
  }

  // 홈 화면의 네이티브 광고 ID (추가)
  static String get homeNativeAdUnitId {
    // 안드로이드와 iOS에 맞는 테스트 광고 ID입니다.
    // 배포 시에는 실제 AdMob 광고 단위 ID로 교체해야 합니다.
    if (Platform.isAndroid) {
      return 'ca-app-pub-1036680323060821/6719614066';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // 홈 화면의 네이티브 광고 ID (추가)
  static String get personalityAdUnitId {
    // 안드로이드와 iOS에 맞는 테스트 광고 ID입니다.
    // 배포 시에는 실제 AdMob 광고 단위 ID로 교체해야 합니다.
    if (Platform.isAndroid) {
      return 'ca-app-pub-1036680323060821/3630416291';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
