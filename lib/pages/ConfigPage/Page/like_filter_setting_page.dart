//like_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class LikeFilterSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const LikeFilterSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _LikeFilterSettingPageState createState() => _LikeFilterSettingPageState();
}

class _LikeFilterSettingPageState extends State<LikeFilterSettingPage> {
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
        title: const Text('点赞过滤器'),
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
                title: const Text('启用点赞过滤器'),
                value: configMap['dynamic']['filter']['like']['enable'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['like']['enable'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('去除重复点赞'),
                value: configMap['dynamic']['filter']['like']['deduplicate'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['like']['deduplicate'] =
                        value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
