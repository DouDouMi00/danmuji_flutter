//welcome_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

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
    final List<int> guardLevelOptions = [0, 1, 2]; // 大航海等级选项
    final List<int> medalLevelOptions = [0, 5, 10, 15, 20, 25]; // 粉丝牌等级选项
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
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 使子元素间间距相等，两端对齐
                children: [
                  Expanded(
                    // 使按钮自适应宽度并均匀分配空间
                    child: ElevatedButton(
                      onPressed: () {
                        updateConfigMap(configMap);
                      },
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('启用进入直播间朗读'),
                value: configMap['dynamic']['filter']['welcome']['enable'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['welcome']['enable'] = value;
                  });
                },
              ),
              // 粉丝牌必须为本直播间
              SwitchListTile(
                title: const Text('粉丝牌必须为本直播间'),
                value: configMap['dynamic']['filter']['welcome']
                    ['isFansMedalBelongToLive'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['welcome']
                        ['isFansMedalBelongToLive'] = value;
                  });
                },
              ),
              // 大航海大于等于
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: '大航海大于等于'),
                value: configMap['dynamic']['filter']["welcome"]
                    ['fansMedalGuardLevelBigger'],
                items: guardLevelOptions.map((level) {
                  return DropdownMenuItem<int>(
                    value: level,
                    child: Text('$level'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      configMap['dynamic']['filter']["welcome"]
                          ['fansMedalGuardLevelBigger'] = value;
                    });
                  }
                },
              ),
              // 粉丝牌等级大于等于
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: '粉丝牌等级大于等于'),
                value: configMap['dynamic']['filter']["danmu"]
                    ['fansMedalLevelBigger'],
                items: medalLevelOptions.map((level) {
                  return DropdownMenuItem<int>(
                      value: level, child: Text('$level'));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      configMap['dynamic']['filter']["danmu"]
                          ['fansMedalLevelBigger'] = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
