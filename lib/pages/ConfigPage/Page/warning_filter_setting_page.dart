//warning_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class WarningFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const WarningFilterSettingPage({super.key, required this.configMap});

  @override
  WarningFilterSettingPageState createState() =>
      WarningFilterSettingPageState();
}

class WarningFilterSettingPageState extends State<WarningFilterSettingPage> {
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
        // 添加AppBar并启用返回按钮
        title: const Text('警告过滤器')
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('超管警告朗读'),
                value: configMap.dynamicConfig.filter.warning.enable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.warning.enable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
