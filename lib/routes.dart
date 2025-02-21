import 'package:get/get.dart';

import 'package:danmuji_flutter/pages/control_list_editor_page.dart';
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart' show InputType;
import 'package:danmuji_flutter/pages/ConfigPage/index.dart';

List<GetPage<dynamic>> get appRoutes => [
      GetPage(
        name: '/systemPrompt',
        page: () => SystemPromptPage(configMap: getConfigMap()),
      ),
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
        name: '/themeSettings',
        page: () => const ThemeSettingPage(),
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
