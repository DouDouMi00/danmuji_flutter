//account_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/obscure_text_field.dart';
import '/services/config.dart';

class AccountSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const AccountSettingPage({super.key, required this.configMap});

  @override
  AccountSettingPageState createState() => AccountSettingPageState();
}

class AccountSettingPageState extends State<AccountSettingPage> {
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
                title: Text('UID ${configMap.kvdb.kvdbBili.uid}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'UID',
                      initialValue: configMap.kvdb.kvdbBili.uid,
                      inputType: InputType.intInputType,
                      isObscured: false,
                      onSaved: (value) async {
                        setState(() {
                          configMap.kvdb.kvdbBili.uid = value;
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
                    'Buvid3 : ${configMap.kvdb.kvdbBili.buvid3.isNotEmpty ? '****' : '未输入'}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'Buvid3',
                      initialValue: configMap.kvdb.kvdbBili.buvid3,
                      inputType: InputType.stringInputType,
                      isObscured: true,
                      onSaved: (value) async {
                        setState(() {
                          configMap.kvdb.kvdbBili.buvid3 = value;
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
                    'Sessdata : ${configMap.kvdb.kvdbBili.sessdata.isNotEmpty ? '****' : '未输入'}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'Sessdata',
                      initialValue: configMap.kvdb.kvdbBili.sessdata,
                      inputType: InputType.stringInputType,
                      isObscured: true,
                      onSaved: (value) async {
                        setState(() {
                          configMap.kvdb.kvdbBili.sessdata = value;
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
                    'JCT : ${configMap.kvdb.kvdbBili.jct.isNotEmpty ? '****' : '未输入'}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  showInputNumberDialog(
                    InputDialogParams(
                      title: 'JCT',
                      initialValue: configMap.kvdb.kvdbBili.jct,
                      inputType: InputType.stringInputType,
                      isObscured: true,
                      onSaved: (value) async {
                        setState(() {
                          configMap.kvdb.kvdbBili.jct = value;
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
