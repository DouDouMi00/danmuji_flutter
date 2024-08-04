// gift_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';
import '/widgets/obscure_text_field.dart';

class GiftFilterSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const GiftFilterSettingPage({super.key, required this.configMap});

  @override
  GiftFilterSettingPageState createState() => GiftFilterSettingPageState();
}

class GiftFilterSettingPageState extends State<GiftFilterSettingPage> {
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
        title: const Text('礼物过滤器')
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('礼物朗读'),
                value: configMap.dynamicConfig.filter.gift.enable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.gift.enable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              SwitchListTile(
                title: const Text('免费礼物朗读'),
                value: configMap.dynamicConfig.filter.gift.freeGiftEnable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.filter.gift.freeGiftEnable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(
                    '几秒内礼物不重复朗读 : ${configMap.dynamicConfig.filter.gift.deduplicateTime}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '几秒内礼物不重复朗读',
                      initialValue:
                          configMap.dynamicConfig.filter.gift.deduplicateTime,
                      inputType: InputType.intInputType,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.gift.deduplicateTime =
                              value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              // 免费礼物数量大于等于
              ListTile(
                leading: const Icon(Icons.numbers_outlined),
                title: Text(
                    '免费礼物数量大于等于 : ${configMap.dynamicConfig.filter.gift.freeGiftCountBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '免费礼物数量大于等于',
                      initialValue: configMap
                          .dynamicConfig.filter.gift.freeGiftCountBigger,
                      inputType: InputType.doubleInputType,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.gift
                              .freeGiftCountBigger = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: Text(
                    '付费礼物金额大于等于 : ${configMap.dynamicConfig.filter.gift.moneyGiftPriceBigger}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '付费礼物金额大于等于',
                      initialValue: configMap
                          .dynamicConfig.filter.gift.moneyGiftPriceBigger,
                      inputType: InputType.doubleInputType,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.filter.gift
                              .moneyGiftPriceBigger = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
