import 'package:danmuji_flutter/pages/ConfigPage/config_page.dart';
import 'package:danmuji_flutter/pages/ConfigPage/index.dart';
import 'package:danmuji_flutter/pages/ControlListEditorPage/control_list_editor_page.dart';
import 'package:danmuji_flutter/pages/HomePage/home_page.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart' show InputType;
import 'package:get/get.dart';

part 'app_routes.dart';

List<GetPage<dynamic>> get appRoutes => [
      GetPage(
        name: _Paths.home,
        page: () => const MyHomePage(),
      ),
      GetPage(
        name: _Paths.settings,
        page: () => ConfigEditPage(),
        children: [
          GetPage(
            name: _Paths.account,
            page: () => AccountSettingPage(),
          ),
          GetPage(
            name: _Paths.ttsEngines,
            page: () => TtsEnginesSettingPage(),
          ),
          GetPage(
            name: _Paths.theme,
            page: () => ThemeSettingPage(),
          ),
          GetPage(
            name: _Paths.systemPrompt,
            page: () => SystemPromptPage(),
          ),
          GetPage(
            name: _Paths.dmFilter,
            page: () => DmFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.giftFilter,
            page: () => GiftFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.guardBuyFilter,
            page: () => GuardBuyFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.likeFilter,
            page: () => LikeFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.welcomeFilter,
            page: () => WelcomeFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.subscribeFilter,
            page: () => SubscribeFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.superChatFilter,
            page: () => SuperChatFilterSettingPage(),
          ),
          GetPage(
            name: _Paths.warningFilter,
            page: () => WarningFilterSettingPage(),
          ),
        ],
      ),
      GetPage(
        name: _Paths.filterListEditor,
        page: () => EditableListPage(),
        arguments: EditableListParams(
          title: '列表标题',
          initialValue: RxList<dynamic>([]),
          inputType: InputType.stringInputType,
          isObscured: false,
          onChanged: (newList) {},
        ),
      ),
    ];
