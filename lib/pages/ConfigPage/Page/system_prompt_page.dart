//system_prompt_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemPromptPage extends StatelessWidget {
  SystemPromptPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('系统提示')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('弹幕延迟较高时自动播报'),
                value: configService.configRx.value.dynamicConfig.dynamicSystem
                    .alertWhenMessagesQueueLonger.enable,
                onChanged: (value) {
                  configService.configRx.value.dynamicConfig.dynamicSystem
                      .alertWhenMessagesQueueLonger.enable = value;
                  configService.configRx.refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.numbers_outlined),
                title: Text(
                  '积压弹幕数量大于: ${configService.configRx.value.dynamicConfig.dynamicSystem.alertWhenMessagesQueueLonger.threshold}',
                ),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '积压弹幕数量',
                    initialValue: configService.configRx.value.dynamicConfig
                        .dynamicSystem.alertWhenMessagesQueueLonger.threshold
                        .toString(),
                    inputType: InputType.intInputType,
                    minValue: 0,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.dynamicSystem
                          .alertWhenMessagesQueueLonger.threshold = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.watch_later_outlined),
                title: Text(
                  '播报间隔: ${configService.configRx.value.dynamicConfig.dynamicSystem.alertWhenMessagesQueueLonger.interval}',
                ),
                trailing: const Icon(Icons.navigate_next),
                onTap: () async {
                  await InputDialog(
                    title: '播报间隔',
                    initialValue: configService.configRx.value.dynamicConfig
                        .dynamicSystem.alertWhenMessagesQueueLonger.interval
                        .toString(),
                    inputType: InputType.intInputType,
                    minValue: 0,
                    onChanged: (value) {
                      configService.configRx.value.dynamicConfig.dynamicSystem
                          .alertWhenMessagesQueueLonger.interval = value;
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
