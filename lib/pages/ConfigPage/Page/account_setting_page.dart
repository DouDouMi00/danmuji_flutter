//account_setting_page.dart
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSettingPage extends StatelessWidget {
  AccountSettingPage({super.key});

  final ConfigService configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账户设置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Obx(
          () => ListView(
            children: [
              const Text('Web端'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(
                    'UID:${configService.configRx.value.kvdb.kvdbBili.uid}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: 'UID',
                    initialValue:
                        configService.configRx.value.kvdb.kvdbBili.uid,
                    inputType: InputType.intInputType,
                    isObscured: false,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.kvdbBili.uid = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'Buvid3:${configService.configRx.value.kvdb.kvdbBili.buvid3.isEmpty ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: 'Buvid3',
                    initialValue:
                        configService.configRx.value.kvdb.kvdbBili.buvid3,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.kvdbBili.buvid3 = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'Sessdata:${configService.configRx.value.kvdb.kvdbBili.sessdata.isEmpty ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: 'Sessdata',
                    initialValue:
                        configService.configRx.value.kvdb.kvdbBili.sessdata,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.kvdbBili.sessdata =
                          value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'JCT:${configService.configRx.value.kvdb.kvdbBili.jct.isEmpty ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: 'JCT',
                    initialValue:
                        configService.configRx.value.kvdb.kvdbBili.jct,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.kvdbBili.jct = value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              const Text('开放平台'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(
                    '主播身份码:${configService.configRx.value.kvdb.openLiveBili.idCode.isEmpty ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: '主播身份码',
                    initialValue:
                        configService.configRx.value.kvdb.openLiveBili.idCode,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.openLiveBili.idCode =
                          value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    '应用id:${configService.configRx.value.kvdb.openLiveBili.appId == 0 ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: '应用id',
                    initialValue:
                        configService.configRx.value.kvdb.openLiveBili.appId,
                    inputType: InputType.intInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.openLiveBili.appId =
                          value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'access_key:${configService.configRx.value.kvdb.openLiveBili.accessKey.isEmpty ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: 'access_key',
                    initialValue: configService
                        .configRx.value.kvdb.openLiveBili.accessKey,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.openLiveBili.accessKey =
                          value;
                      configService.configRx.refresh();
                    },
                  ).show();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                    'access_key_secret:${configService.configRx.value.kvdb.openLiveBili.accessKeySecret.isEmpty ? '未输入' : '****'}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  await InputDialog(
                    title: 'access_key_secret',
                    initialValue: configService
                        .configRx.value.kvdb.openLiveBili.accessKeySecret,
                    inputType: InputType.stringInputType,
                    isObscured: true,
                    allowEmpty: true,
                    onChanged: (value) {
                      configService.configRx.value.kvdb.openLiveBili
                          .accessKeySecret = value;
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
