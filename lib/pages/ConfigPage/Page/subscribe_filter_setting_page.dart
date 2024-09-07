//subscribe_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/config.dart';

class SubscribeFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const SubscribeFilterSettingPage({super.key, required this.configMap});

  @override
  SubscribeFilterSettingPageState createState() =>
      SubscribeFilterSettingPageState();
}

class SubscribeFilterSettingPageState
    extends State<SubscribeFilterSettingPage> {
  late DefaultConfig configMap;

  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as DefaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关注过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView(
            children: [
              SwitchListTile(
                title: const Text('关注朗读'),
                value: configMap.dynamicConfig.filter.subscribe.enable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.subscribe.enable = value;
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
