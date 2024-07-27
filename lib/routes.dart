import 'package:get/get.dart';
import 'pages/ConfigPage/index.dart';
import '/widgets/obscure_text_field.dart' show InputType;
import '/pages/white_list_editor_page.dart';
import '/services/config.dart';

List<GetPage<dynamic>> get appRoutes => [
      GetPage(
        name: '/accountSettings',
        page: () => AccountSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/ttsEnginesSettings',
        page: () => TtsEnginesSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/dmFilterSettings',
        page: () => DmFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/giftFilterSettings',
        page: () => GiftFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/guardBuyFilterSettings',
        page: () => GuardBuyFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/likeFilterSettings',
        page: () => LikeFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/welcomeFilterSettings',
        page: () => WelcomeFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/subscribeFilterSettings',
        page: () => SubscribeFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/superChatFilterSettings',
        page: () => SuperChatFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/warningFilterSettings',
        page: () => WarningFilterSettingPage(configMap: getConfigMap()),
      ),
      GetPage(
        name: '/filterListEditor',
        page: () => EditableListPage(
          params: EditableListParams(
            title: '',
            inputType: InputType.stringInputType,
            initialValue: [],
            onSaved: (value) {},
          ),
        ),
      ),
    ];
