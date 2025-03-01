//warning_filter_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WarningFilterSettingPage extends StatelessWidget {
  WarningFilterSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('警告过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('超管警告朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.warning.enable,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.warning
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
