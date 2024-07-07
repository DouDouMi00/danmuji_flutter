import 'package:get/get.dart';
import 'pages/ConfigPage/index.dart';

List<GetPage<dynamic>> get appRoutes => [
      GetPage(
        name: '/accountSettings',
        page: () => const AccountSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/ttsEnginesSettings',
        page: () => const TtsEnginesSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/dmFilterSettings',
        page: () => const DmFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/giftFilterSettings',
        page: () => const GiftFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/guardBuyFilterSettings',
        page: () => const GuardBuyFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/likeFilterSettings',
        page: () => const LikeFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/welcomeFilterSettings',
        page: () => const WelcomeFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/subscribeFilterSettings',
        page: () => const SubscribeFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/superChatFilterSettings',
        page: () => const SuperChatFilterSettingPage(configMap: {}),
      ),
      GetPage(
        name: '/warningFilterSettings',
        page: () => const WarningFilterSettingPage(configMap: {}),
      ),
    ];
