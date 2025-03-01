//welcome_filter_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeFilterSettingPage extends StatelessWidget {
  WelcomeFilterSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();
  static const List<Map<String, String>> guardLevelOptions = [
    {'title': '无', 'value': '0'},
    {'title': '舰长', 'value': '1'},
    {'title': '提督', 'value': '2'},
    {'title': '总督', 'value': '3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('进入直播间过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('进入直播间朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.welcome.enable,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.welcome
                      .enable = value;
                  configService.configRx.refresh();
                },
              ),
              // 粉丝牌必须为本直播间
              SwitchListTile(
                title: const Text('粉丝牌必须为本直播间'),
                value: configService.configRx.value.dynamicConfig.filter.welcome
                    .isFansMedalBelongToLive,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.welcome
                      .isFansMedalBelongToLive = value;
                  configService.configRx.refresh();
                },
              ),
              // // 大航海大于等于
              ListTile(
                leading: const Icon(Icons.anchor_outlined),
                title: Text(
                    '大航海大于等于: ${guardLevelOptions[configService.configRx.value.dynamicConfig.filter.welcome.fansMedalGuardLevelBigger]['title']}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await RadioDialog(
                    title: '大航海大于等于',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.welcome.fansMedalGuardLevelBigger
                        .toString(),
                    valueOptions: guardLevelOptions,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.welcome
                          .fansMedalGuardLevelBigger = int.parse(value);
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              // 粉丝勋章等级大于等于
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(
                    '粉丝勋章等级大于等于: ${configService.configRx.value.dynamicConfig.filter.welcome.fansMedalLevelBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '粉丝勋章等级',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.welcome.fansMedalLevelBigger
                        .toString(),
                    inputType: InputType.intInputType,
                    isObscured: false,
                    minValue: 0,
                    maxValue: 40,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.welcome
                          .fansMedalLevelBigger = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
