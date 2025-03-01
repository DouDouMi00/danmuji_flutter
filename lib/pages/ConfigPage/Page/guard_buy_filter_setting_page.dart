// guard_buy_filter_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuardBuyFilterSettingPage extends StatelessWidget {
  GuardBuyFilterSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('舰队购买过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('舰队购买朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.guardBuy.enable,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.guardBuy
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
