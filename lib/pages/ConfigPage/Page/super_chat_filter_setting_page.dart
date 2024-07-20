//super_chat_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class SuperChatFilterSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const SuperChatFilterSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _SuperChatFilterSettingPageState createState() =>
      _SuperChatFilterSettingPageState();
}

class _SuperChatFilterSettingPageState
    extends State<SuperChatFilterSettingPage> {
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
        title: const Text('超级留言过滤器'),
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
                title: const Text('启用醒目留言朗读'),
                value: configMap['dynamic']['filter']['superChat']['enable'],
                onChanged: (value) async {
                  setState(() {
                    configMap['dynamic']['filter']['superChat']['enable'] =
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
