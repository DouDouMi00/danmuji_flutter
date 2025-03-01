//dm_filter_setting_page.dart
import 'package:danmuji_flutter/pages/ControlListEditorPage/control_list_editor_page.dart';
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DmFilterSettingPage extends StatelessWidget {
  DmFilterSettingPage({super.key});

  static const List<Map<String, String>> guardLevelOptions = [
    {'title': '无', 'value': '0'},
    {'title': '舰长', 'value': '1'},
    {'title': '提督', 'value': '2'},
    {'title': '总督', 'value': '3'},
  ];

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('弹幕过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              // 弹幕朗读
              SwitchListTile(
                title: const Text('弹幕朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.danmu.enable,
                onChanged: (value) async {
                  configService
                      .configRx.value.dynamicConfig.filter.danmu.enable = value;

                  configService.configRx.refresh();
                },
              ),
              // 纯标点符号弹幕朗读
              SwitchListTile(
                title: const Text('纯标点符号弹幕朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.danmu.symbolEnable,
                onChanged: (value) async {
                  configService.configRx.value.dynamicConfig.filter.danmu
                      .symbolEnable = value;
                  configService.configRx.refresh();
                },
              ),
              // 纯表情弹幕朗读
              SwitchListTile(
                title: const Text('纯表情弹幕朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.danmu.emojiEnable,
                onChanged: (value) async {
                  configService.configRx.value.dynamicConfig.filter.danmu
                      .emojiEnable = value;
                  configService.configRx.refresh();
                },
              ),
              // 大航海头衔朗读
              SwitchListTile(
                title: const Text('大航海头衔朗读'),
                value: configService.configRx.value.dynamicConfig.filter.danmu
                    .readfansMedalGuardLevel,
                onChanged: (value) async {
                  configService.configRx.value.dynamicConfig.filter.danmu
                      .readfansMedalGuardLevel = value;
                  configService.configRx.refresh();
                },
              ),
              // 粉丝勋章等级播报
              SwitchListTile(
                title: const Text('粉丝勋章等级播报'),
                value: configService.configRx.value.dynamicConfig.filter.danmu
                    .readfansMedalName,
                onChanged: (value) async {
                  configService.configRx.value.dynamicConfig.filter.danmu
                      .readfansMedalName = value;
                  configService.configRx.refresh();
                },
              ),
              // 去除短时间内重复弹幕
              SwitchListTile(
                title: const Text('去除短时间内重复弹幕'),
                value: configService
                    .configRx.value.dynamicConfig.filter.danmu.deduplicate,
                onChanged: (value) async {
                  configService.configRx.value.dynamicConfig.filter.danmu
                      .deduplicate = value;
                  configService.configRx.refresh();
                },
              ),
              // 粉丝勋章必须为本直播间
              SwitchListTile(
                title: const Text('粉丝勋章必须为本直播间'),
                value: configService.configRx.value.dynamicConfig.filter.danmu
                    .isFansMedalBelongToLive,
                onChanged: (value) async {
                  configService.configRx.value.dynamicConfig.filter.danmu
                      .isFansMedalBelongToLive = value;
                  configService.configRx.refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.anchor_outlined),
                title: Text(
                    '大航海大于等于: ${guardLevelOptions[configService.configRx.value.dynamicConfig.filter.danmu.fansMedalGuardLevelBigger]['title']}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await RadioDialog(
                    title: '大航海大于等于',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.danmu.fansMedalGuardLevelBigger
                        .toString(),
                    valueOptions: guardLevelOptions,
                    onChanged: (value) async {
                      configService.configRx.value.dynamicConfig.filter.danmu
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
                    '粉丝勋章等级大于等于: ${configService.configRx.value.dynamicConfig.filter.danmu.fansMedalLevelBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '粉丝勋章等级',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.danmu.fansMedalLevelBigger,
                    inputType: InputType.intInputType,
                    isObscured: false,
                    minValue: 0,
                    maxValue: 40,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.danmu
                          .fansMedalLevelBigger = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              // 文本长度小于等于
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: Text(
                    '读出文本长度小于等于: ${configService.configRx.value.dynamicConfig.filter.danmu.lengthShorter}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '文本长度',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.danmu.lengthShorter,
                    inputType: InputType.intInputType,
                    isObscured: false,
                    minValue: 0,
                    maxValue: 20,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.danmu
                          .lengthShorter = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              //黑名关键词
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('黑名单关键词'),
                subtitle: Text(
                    '${configService.configRx.value.dynamicConfig.filter.danmu.blacklistKeywords.length} 个关键词'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '黑名单关键词',
                      initialValue: configService.configRx.value.dynamicConfig
                          .filter.danmu.blacklistKeywords,
                      inputType: InputType.stringInputType,
                      isObscured: false,
                      onChanged: (value) async {
                        // 将 List<dynamic> 转换为 List<String>
                        final List<String> stringList =
                            value.map((e) => e.toString()).toList();
                        configService.configRx.value.dynamicConfig.filter.danmu
                            .blacklistKeywords = stringList;
                        configService.configRx.refresh();
                      },
                    ),
                  );
                },
              ),
              // 黑名单用户UID
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('黑名单用户UID'),
                subtitle: Text(
                    '${configService.configRx.value.dynamicConfig.filter.danmu.blacklistUsers.length} 个用户'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '黑名单用户UID',
                      initialValue: configService.configRx.value.dynamicConfig
                          .filter.danmu.blacklistUsers,
                      inputType: InputType.intInputType,
                      isObscured: false,
                      onChanged: (value) async {
                        // 将 List<dynamic> 转换为 List<int>
                        final List<int> intList =
                            value.map((e) => int.parse(e.toString())).toList();
                        configService.configRx.value.dynamicConfig.filter.danmu
                            .blacklistUsers = intList;
                        configService.configRx.refresh();
                      },
                    ),
                  );
                },
              ),
              // 白名单关键词
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('白名单关键词'),
                subtitle: Text(
                    '${configService.configRx.value.dynamicConfig.filter.danmu.whitelistKeywords.length} 个关键词'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '白名单关键词',
                      initialValue: configService.configRx.value.dynamicConfig
                          .filter.danmu.whitelistKeywords,
                      inputType: InputType.stringInputType,
                      isObscured: false,
                      onChanged: (value) async {
                        final List<String> stringList =
                            value.map((e) => e.toString()).toList();
                        configService.configRx.value.dynamicConfig.filter.danmu
                            .whitelistKeywords = stringList;
                        configService.configRx.refresh();
                      },
                    ),
                  );
                },
              ),
              // 白名单用户UID
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('白名单用户UID'),
                subtitle: Text(
                    '${configService.configRx.value.dynamicConfig.filter.danmu.whitelistUsers.length} 个用户'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '白名单用户UID',
                      initialValue: configService.configRx.value.dynamicConfig
                          .filter.danmu.whitelistUsers,
                      inputType: InputType.intInputType,
                      isObscured: false,
                      onChanged: (value) async {
                        final List<int> intList =
                            value.map((e) => int.parse(e.toString())).toList();
                        configService.configRx.value.dynamicConfig.filter.danmu
                            .whitelistUsers = intList;
                        configService.configRx.refresh();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
