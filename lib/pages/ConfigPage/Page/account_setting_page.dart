//account_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/config.dart';
import '/widgets/obscure_text_field.dart';

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
      appBar: AppBar(title: const Text('账户设置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView(
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
            const Text('开放平台'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(
                  '主播身份码 : ${configMap.kvdb.openLiveBili.idCode.isNotEmpty ? '****' : '未输入'}'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showInputNumberDialog(
                  InputDialogParams(
                    title: '主播身份码',
                    initialValue: configMap.kvdb.openLiveBili.idCode,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    onSaved: (value) async {
                      setState(() {
                        configMap.kvdb.openLiveBili.idCode = value;
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
                  '应用id : ${configMap.kvdb.openLiveBili.appId != 0 ? '****' : '未输入'}'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showInputNumberDialog(
                  InputDialogParams(
                    title: '应用id',
                    initialValue: configMap.kvdb.openLiveBili.appId,
                    inputType: InputType.intInputType,
                    isObscured: true,
                    onSaved: (value) async {
                      setState(() {
                        configMap.kvdb.openLiveBili.appId = value;
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
                  'access_key : ${configMap.kvdb.openLiveBili.accessKey.isNotEmpty ? '****' : '未输入'}'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showInputNumberDialog(
                  InputDialogParams(
                    title: 'access_key',
                    initialValue: configMap.kvdb.openLiveBili.accessKey,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    onSaved: (value) async {
                      setState(() {
                        configMap.kvdb.openLiveBili.accessKey = value;
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
                  'access_key_secret : ${configMap.kvdb.openLiveBili.accessKeySecret.isNotEmpty ? '****' : '未输入'}'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showInputNumberDialog(
                  InputDialogParams(
                    title: 'access_key_secret',
                    initialValue: configMap.kvdb.openLiveBili.accessKeySecret,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    onSaved: (value) async {
                      setState(() {
                        configMap.kvdb.openLiveBili.accessKeySecret = value;
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
    );
  }
}
