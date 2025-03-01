//like_filter_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LikeFilterSettingPage extends StatelessWidget {
  LikeFilterSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('点赞过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('点赞朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.like.enable,
                onChanged: (value) {
                  configService
                      .configRx.value.dynamicConfig.filter.like.enable = value;
                  configService.configRx.refresh();
                },
              ),
              SwitchListTile(
                title: const Text('去除重复点赞'),
                value: configService
                    .configRx.value.dynamicConfig.filter.like.deduplicate,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.like
                      .deduplicate = value;
                  configService.configRx.refresh();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
