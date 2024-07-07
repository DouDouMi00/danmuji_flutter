// gift_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class GiftFilterSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const GiftFilterSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _GiftFilterSettingPageState createState() => _GiftFilterSettingPageState();
}

class _GiftFilterSettingPageState extends State<GiftFilterSettingPage> {
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
        title: const Text('礼物过滤器'),
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
                title: const Text('启用礼物朗读'),
                value: configMap['dynamic']['filter']['gift']['enable'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['gift']['enable'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('启用免费礼物朗读'),
                value: configMap['dynamic']['filter']['gift']['freeGiftEnable'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['gift']['freeGiftEnable'] =
                        value;
                  });
                },
              ),
              // 几秒内礼物不重复朗读
              TextFormField(
                controller: TextEditingController(
                    text: configMap['dynamic']['filter']['gift']
                            ['deduplicateTime']
                        .toString()),
                decoration: const InputDecoration(labelText: '几秒内礼物不重复朗读'),
                onFieldSubmitted: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['gift']
                          ['deduplicateTime'] = 0;
                      return;
                    } else {
                      configMap['dynamic']['filter']['gift']
                          ['deduplicateTime'] = int.parse(value);
                    }
                  });
                },
              ),
              // 免费礼物数量大于等于
              TextFormField(
                controller: TextEditingController(
                    text: configMap['dynamic']['filter']['gift']
                            ['freeGiftCountBigger']
                        .toString()),
                decoration: const InputDecoration(labelText: '免费礼物数量大于等于'),
                onFieldSubmitted: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['gift']
                          ['freeGiftCountBigger'] = 0;
                      return;
                    } else {
                      configMap['dynamic']['filter']['gift']
                          ['freeGiftCountBigger'] = int.parse(value);
                    }
                  });
                },
              ),
              // 付费礼物金额大于等于
              TextFormField(
                controller: TextEditingController(
                    text: configMap['dynamic']['filter']['gift']
                            ['moneyGiftPriceBigger']
                        .toString()),
                decoration: const InputDecoration(labelText: '付费礼物金额大于等于'),
                onFieldSubmitted: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['gift']
                          ['moneyGiftPriceBigger'] = 0;
                      return;
                    } else {
                      configMap['dynamic']['filter']['gift']
                          ['moneyGiftPriceBigger'] = int.parse(value);
                    }
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
