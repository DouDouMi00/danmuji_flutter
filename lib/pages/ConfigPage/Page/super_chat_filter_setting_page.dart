//super_chat_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/config.dart';

class SuperChatFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const SuperChatFilterSettingPage({super.key, required this.configMap});

  @override
  SuperChatFilterSettingPageState createState() =>
      SuperChatFilterSettingPageState();
}

class SuperChatFilterSettingPageState
    extends State<SuperChatFilterSettingPage> {
  late DefaultConfig configMap;

  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as DefaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('超级留言过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('醒目留言朗读'),
              value: configMap.dynamicConfig.filter.superChat.enable,
              onChanged: (value) async {
                setState(() {
                  configMap.dynamicConfig.filter.superChat.enable = value;
                });
                await updateConfigMap(configMap);
              },
            ),
          ],
        ),
      ),
    );
  }
}
