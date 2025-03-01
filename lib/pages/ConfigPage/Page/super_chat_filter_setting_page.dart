//super_chat_filter_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuperChatFilterSettingPage extends StatelessWidget {
  SuperChatFilterSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('超级留言过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('醒目留言朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.superChat.enable,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.superChat
                      .enable = value;
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
