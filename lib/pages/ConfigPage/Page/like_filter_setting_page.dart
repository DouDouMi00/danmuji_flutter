//like_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class LikeFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const LikeFilterSettingPage({super.key, required this.configMap});

  @override
  LikeFilterSettingPageState createState() => LikeFilterSettingPageState();
}

class LikeFilterSettingPageState extends State<LikeFilterSettingPage> {
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
        title: const Text('点赞过滤器')
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('点赞朗读'),
                value: configMap.dynamicConfig.filter.like.enable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.like.enable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              SwitchListTile(
                title: const Text('去除重复点赞'),
                value: configMap.dynamicConfig.filter.like.deduplicate,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.like.deduplicate = value;
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
