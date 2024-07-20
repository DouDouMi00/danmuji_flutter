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
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('UID ${configMap['kvdb']['bili']['uid']}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'UID',
                      initialValue: configMap['kvdb']['bili']['uid'],
                      inputType: InputType.intInputType,
                      isObscured: false,
                      onSaved: (value) async {
                        setState(() {
                          configMap['kvdb']['bili']['uid'] = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'Buvid3 : ${configMap['kvdb']['bili']['buvid3'].isNotEmpty ? '****' : '未输入'}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'Buvid3',
                      initialValue: configMap['kvdb']['bili']['buvid3'],
                      inputType: InputType.stringInputType,
                      isObscured: true,
                      onSaved: (value) async {
                        setState(() {
                          configMap['kvdb']['bili']['buvid3'] = value;
                        });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'Sessdata : ${configMap['kvdb']['bili']['sessdata'].isNotEmpty ? '****' : '未输入'}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'Sessdata',
                      initialValue: configMap['kvdb']['bili']['sessdata'],
                      inputType: InputType.stringInputType,
                      isObscured: true,
                      onSaved: (value) async {
                        setState(() {
                          configMap['kvdb']['bili']['sessdata'] = value;
                          });
                        await updateConfigMap(configMap);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'JCT : ${configMap['kvdb']['bili']['jct'].isNotEmpty ? '****' : '未输入'}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'JCT',
                      initialValue: configMap['kvdb']['bili']['jct'],
                      inputType: InputType.stringInputType,
                      isObscured: true,
                      onSaved: (value)  async{
                        setState(() {
                          configMap['kvdb']['bili']['jct'] = value;
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
