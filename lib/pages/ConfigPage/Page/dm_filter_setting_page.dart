//dm_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';
import '/widgets/obscure_text_field.dart';
import '/pages/white_list_editor_page.dart';

class DmFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const DmFilterSettingPage({super.key, required this.configMap});

  @override
  DmFilterSettingPageState createState() => DmFilterSettingPageState();
}

class DmFilterSettingPageState extends State<DmFilterSettingPage> {
  final List<Map<String, dynamic>> guardLevelOptions = [
    {'title': '无', 'value': 0},
    {'title': '舰长', 'value': 1},
    {'title': '提督', 'value': 2},
    {'title': '总督', 'value': 3},
  ];
  late DefaultConfig configMap;
  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as DefaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并返回按钮
        title: const Text('弹幕过滤器'),
        leading: IconButton(
          // 这里是返回按钮
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 弹幕朗读
              SwitchListTile(
                title: const Text('弹幕朗读'),
                value: configMap.dynamicConfig.filter.danmu.enable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu.enable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 纯标点符号弹幕朗读
              SwitchListTile(
                title: const Text('纯标点符号弹幕朗读'),
                value: configMap.dynamicConfig.filter.danmu.symbolEnable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu.symbolEnable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 纯表情弹幕朗读
              SwitchListTile(
                title: const Text('纯表情弹幕朗读'),
                value: configMap.dynamicConfig.filter.danmu.emojiEnable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu.emojiEnable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 大航海头衔朗读
              SwitchListTile(
                title: const Text('大航海头衔朗读'),
                value: configMap
                    .dynamicConfig.filter.danmu.readfansMedalGuardLevel,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu
                        .readfansMedalGuardLevel = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 粉丝勋章等级播报
              SwitchListTile(
                title: const Text('粉丝勋章等级播报'),
                value: configMap.dynamicConfig.filter.danmu.readfansMedalName,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu.readfansMedalName =
                        value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 去除短时间内重复弹幕
              SwitchListTile(
                title: const Text('去除短时间内重复弹幕'),
                value: configMap.dynamicConfig.filter.danmu.deduplicate,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu.deduplicate = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 粉丝勋章必须为本直播间
              SwitchListTile(
                title: const Text('粉丝勋章必须为本直播间'),
                value: configMap
                    .dynamicConfig.filter.danmu.isFansMedalBelongToLive,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.danmu
                        .isFansMedalBelongToLive = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              ListTile(
                leading: const Icon(Icons.anchor_outlined),
                title: Text(
                    '大航海大于等于: ${guardLevelOptions[configMap.dynamicConfig.filter.danmu.fansMedalGuardLevelBigger]['title']}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showRadioDialog(
                    RadioDialogParams(
                      title: '大航海大于等于',
                      initialValue: configMap
                          .dynamicConfig.filter.danmu.fansMedalGuardLevelBigger,
                      valueOptions: guardLevelOptions,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu
                              .fansMedalGuardLevelBigger = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              // 粉丝勋章等级大于等于
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(
                    '粉丝勋章等级大于等于: ${configMap.dynamicConfig.filter.danmu.fansMedalLevelBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '粉丝勋章等级',
                      initialValue: configMap
                          .dynamicConfig.filter.danmu.fansMedalLevelBigger
                          .toString(),
                      inputType: InputType.intInputType,
                      isObscured: false,
                      minValue: 0,
                      maxValue: 40,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu
                              .fansMedalLevelBigger = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              // 文本长度小于等于
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: Text(
                    '文本长度小于等于: ${configMap.dynamicConfig.filter.danmu.lengthShorter}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '文本长度',
                      initialValue: configMap
                          .dynamicConfig.filter.danmu.lengthShorter
                          .toString(),
                      inputType: InputType.intInputType,
                      isObscured: false,
                      minValue: 0,
                      maxValue: 20,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu.lengthShorter =
                              value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              //黑名关键词
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('黑名单关键词'),
                subtitle: Text(
                    '${configMap.dynamicConfig.filter.danmu.blacklistKeywords.length} 个关键词'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '黑名单关键词',
                      initialValue: configMap
                          .dynamicConfig.filter.danmu.blacklistKeywords,
                      inputType: InputType.stringInputType,
                      isObscured: false,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu
                              .blacklistKeywords = value;
                        });
                        await updateConfigMap(configMap);
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
                    '${configMap.dynamicConfig.filter.danmu.blacklistUsers.length} 个用户'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '黑名单用户UID',
                      initialValue:
                          configMap.dynamicConfig.filter.danmu.blacklistUsers,
                      inputType: InputType.intInputType,
                      isObscured: false,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu.blacklistUsers =
                              value;
                        });
                        await updateConfigMap(configMap);
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
                    '${configMap.dynamicConfig.filter.danmu.whitelistKeywords.length} 个关键词'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '白名单关键词',
                      initialValue: configMap
                          .dynamicConfig.filter.danmu.whitelistKeywords,
                      inputType: InputType.stringInputType,
                      isObscured: false,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu
                              .whitelistKeywords = value;
                        });
                        await updateConfigMap(configMap);
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
                    '${configMap.dynamicConfig.filter.danmu.whitelistUsers.length} 个用户'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Get.toNamed(
                    '/filterListEditor',
                    arguments: EditableListParams(
                      title: '白名单用户UID',
                      initialValue:
                          configMap.dynamicConfig.filter.danmu.whitelistUsers,
                      inputType: InputType.intInputType,
                      isObscured: false,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.danmu.whitelistUsers =
                              value;
                        });
                        await updateConfigMap(configMap);
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
