//guard_buy_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:danmuji_flutter/services/config.dart';

class GuardBuyFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const GuardBuyFilterSettingPage({super.key, required this.configMap});

  @override
  GuardBuyFilterSettingPageState createState() =>
      GuardBuyFilterSettingPageState();
}

class GuardBuyFilterSettingPageState extends State<GuardBuyFilterSettingPage> {
  late DefaultConfig configMap;

  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as DefaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('舰队购买过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('舰队购买朗读'),
              value: configMap.dynamicConfig.filter.guardBuy.enable,
              onChanged: (value) async {
                setState(() {
                  configMap.dynamicConfig.filter.guardBuy.enable = value;
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
