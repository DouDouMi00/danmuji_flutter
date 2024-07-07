//account_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/obscure_text_field.dart';
import '/services/config.dart';

class AccountSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const AccountSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _AccountSettingPageState createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  TextEditingController uidController = TextEditingController();
  TextEditingController buvid3Controller = TextEditingController();
  TextEditingController sessdataController = TextEditingController();
  TextEditingController jctController = TextEditingController();
  late Map<String, dynamic> configMap;
  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as Map<String, dynamic>;
    uidController.text = configMap['kvdb']['bili']['uid'].toString();
    buvid3Controller.text = configMap['kvdb']['bili']['Buvid3'] ?? '';
    sessdataController.text = configMap['kvdb']['bili']['sessdata'] ?? '';
    jctController.text = configMap['kvdb']['bili']['jct'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并启用返回按钮
        title: const Text('账户设置'),
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
              TextFormField(
                controller: uidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'UID'),
                onFieldSubmitted: (value) {
                  setState(() {
                    configMap['kvdb']['bili']['uid'] = int.parse(value);
                  });
                },
              ),
              // 使用自定义的ObscureTextField
              ObscureTextField(
                controller: buvid3Controller,
                labelText: 'Buvid3',
                onFieldSubmitted: (value) {
                  setState(() {
                    configMap['kvdb']['bili']['buvid3'] = value;
                  });
                },
              ),
              ObscureTextField(
                controller: sessdataController,
                labelText: 'Sessdata',
                onFieldSubmitted: (value) {
                  setState(() {
                    configMap['kvdb']['bili']['sessdata'] = value;
                  });
                },
              ),
              ObscureTextField(
                controller: jctController,
                labelText: 'JCT',
                onFieldSubmitted: (value) {
                  setState(() {
                    configMap['kvdb']['bili']['jct'] = value;
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
