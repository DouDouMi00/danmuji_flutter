// gift_filter_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftFilterSettingPage extends StatelessWidget {
  GiftFilterSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('礼物过滤器')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('礼物朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.gift.enable,
                onChanged: (value) {
                  configService
                      .configRx.value.dynamicConfig.filter.gift.enable = value;
                  configService.configRx.refresh();
                },
              ),
              SwitchListTile(
                title: const Text('免费礼物朗读'),
                value: configService
                    .configRx.value.dynamicConfig.filter.gift.freeGiftEnable,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.filter.gift
                      .freeGiftEnable = value;
                  configService.configRx.refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(
                    '几秒内礼物不重复朗读 : ${configService.configRx.value.dynamicConfig.filter.gift.deduplicateTime}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '几秒内礼物不重复朗读',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.gift.deduplicateTime,
                    inputType: InputType.intInputType,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.gift
                          .deduplicateTime = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              // 免费礼物数量大于等于
              ListTile(
                leading: const Icon(Icons.numbers_outlined),
                title: Text(
                    '免费礼物数量大于等于 : ${configService.configRx.value.dynamicConfig.filter.gift.freeGiftCountBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '免费礼物数量大于等于',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.gift.freeGiftCountBigger,
                    inputType: InputType.doubleInputType,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.gift
                          .freeGiftCountBigger = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: Text(
                    '付费礼物金额大于等于 : ${configService.configRx.value.dynamicConfig.filter.gift.moneyGiftPriceBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '付费礼物金额大于等于',
                    initialValue: configService.configRx.value.dynamicConfig
                        .filter.gift.moneyGiftPriceBigger,
                    inputType: InputType.doubleInputType,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.filter.gift
                          .moneyGiftPriceBigger = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
