//system_prompt_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/config.dart';
import '/widgets/obscure_text_field.dart';

class SystemPromptPage extends StatefulWidget {
  final DefaultConfig configMap;

  const SystemPromptPage({super.key, required this.configMap});

  @override
  SystemPromptPageState createState() => SystemPromptPageState();
}

class SystemPromptPageState extends State<SystemPromptPage> {
  late DefaultConfig configMap;

  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as DefaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('系统提示')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('弹幕延迟较高时自动播报'),
                value: configMap.dynamicConfig.dynamicSystem
                    .alertWhenMessagesQueueLonger.enable,
                onChanged: (value) async {
                  setState(() {
                    configMap.dynamicConfig.dynamicSystem
                        .alertWhenMessagesQueueLonger.enable = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
              ListTile(
                leading: const Icon(Icons.numbers_outlined),
                title: Text(
                    '积压弹幕数量大于: ${configMap.dynamicConfig.dynamicSystem.alertWhenMessagesQueueLonger.threshold}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '积压弹幕数量',
                      initialValue: configMap.dynamicConfig.dynamicSystem
                          .alertWhenMessagesQueueLonger.threshold
                          .toString(),
                      inputType: InputType.intInputType,
                      isObscured: false,
                      minValue: 0,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.dynamicSystem
                              .alertWhenMessagesQueueLonger.threshold = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.watch_later_outlined),
                title: Text(
                    '播报间隔: ${configMap.dynamicConfig.dynamicSystem.alertWhenMessagesQueueLonger.interval}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: '播报间隔',
                      initialValue: configMap.dynamicConfig.dynamicSystem
                          .alertWhenMessagesQueueLonger.interval
                          .toString(),
                      inputType: InputType.intInputType,
                      isObscured: false,
                      minValue: 0,
                      onSaved: (value) async {
                        setState(() {
                          configMap.dynamicConfig.dynamicSystem
                              .alertWhenMessagesQueueLonger.interval = value;
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
