//subscribe_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class SubscribeFilterSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const SubscribeFilterSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _SubscribeFilterSettingPageState createState() =>
      _SubscribeFilterSettingPageState();
}

class _SubscribeFilterSettingPageState
    extends State<SubscribeFilterSettingPage> {
  late Map<String, dynamic> configMap;
  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并启用返回按钮
        title: const Text('关注过滤器'),
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
                title: const Text('启用关注朗读'),
                value: configMap['dynamic']['filter']['subscribe']['enable'],
                onChanged: (value) async {
                  setState(() {
                    configMap['dynamic']['filter']['subscribe']['enable'] =
                        value;
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
