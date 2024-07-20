//welcome_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';
import '/widgets/obscure_text_field.dart';

class WelcomeFilterSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const WelcomeFilterSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeFilterSettingPageState createState() =>
      _WelcomeFilterSettingPageState();
}

class _WelcomeFilterSettingPageState extends State<WelcomeFilterSettingPage> {
  late Map<String, dynamic> configMap;
  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> guardLevelOptions = [
      {'title': '无', 'value': 0},
      {'title': '舰长', 'value': 1},
      {'title': '提督', 'value': 2},
      {'title': '总督', 'value': 3},
    ];
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并启用返回按钮
        title: const Text('进入直播间过滤器'),
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
              SwitchListTile(
                title: const Text('启用进入直播间朗读'),
                value: configMap['dynamic']['filter']['welcome']['enable'],
                onChanged: (value) async {
                  setState(() {
                    configMap['dynamic']['filter']['welcome']['enable'] = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // 粉丝牌必须为本直播间
              SwitchListTile(
                title: const Text('粉丝牌必须为本直播间'),
                value: configMap['dynamic']['filter']['welcome']
                    ['isFansMedalBelongToLive'],
                onChanged: (value) async {
                  setState(() {
                    configMap['dynamic']['filter']['welcome']
                        ['isFansMedalBelongToLive'] = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              // // 大航海大于等于
              ListTile(
                leading: const Icon(Icons.anchor_outlined),
                title: Text(
                    '大航海大于等于: ${guardLevelOptions[configMap['dynamic']['filter']["welcome"]['fansMedalGuardLevelBigger']]['title']}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showRadioDialog(
                    RadioDialogParams(
                      title: '大航海大于等于',
                      initialValue: configMap['dynamic']['filter']["welcome"]
                          ['fansMedalGuardLevelBigger'],
                      valueOptions: guardLevelOptions,
                      onSaved: (newValue) async {
                        setState(() {
                          configMap['dynamic']['filter']["welcome"]
                              ['fansMedalGuardLevelBigger'] = newValue;
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
                    '粉丝勋章等级大于等于: ${configMap['dynamic']['filter']["danmu"]['fansMedalLevelBigger']}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '粉丝勋章等级',
                      initialValue: configMap['dynamic']['filter']["danmu"]
                              ['fansMedalLevelBigger']
                          .toString(),
                      inputType: InputType.intInputType,
                      isObscured: false,
                      minValue: 0,
                      maxValue: 40,
                      onSaved: (value) async {
                        setState(() {
                          configMap['dynamic']['filter']["danmu"]
                              ['fansMedalLevelBigger'] = value;
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
