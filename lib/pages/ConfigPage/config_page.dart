// pages/ConfigPage/config_page.dart
import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/config.dart';
import '/widgets/obscure_text_field.dart';

class ConfigEditPage extends StatefulWidget {
  const ConfigEditPage({super.key});

  @override
  ConfigEditPageState createState() => ConfigEditPageState();
}

class ConfigEditPageState extends State<ConfigEditPage> {
  late DefaultConfig configMap;

  @override
  void initState() {
    super.initState();
    configMap = getConfigMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: _buildConfig(configMap),
      ),
    );
  }

  /// 打开无障碍设置页面
  void _openAccessibilitySettings() {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    intent.launch();
  }

  /// 打开应用详情页面
  void _openApplicationDetails() {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:com.DouDouMi00.danmuji_flutter',
    );
    intent.launch();
  }

  /// 打开省电模式设置页面
  void _openBatterySaverSettings() {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.BATTERY_SAVER_SETTINGS',
    );
    intent.launch();
  }

  List<Widget> _buildSystemSettings() {
    return [
      const Divider(),
      ListTile(
        leading: const Icon(Icons.accessibility_new_outlined),
        title: const Text('系统辅助功能'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () => _openAccessibilitySettings(),
      ),
      ListTile(
        leading: const Icon(Icons.settings_applications_outlined),
        title: const Text('系统应用设置'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () => _openApplicationDetails(),
      ),
      ListTile(
        leading: const Icon(Icons.battery_saver_outlined),
        title: const Text('系统省电模式设置'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () => _openBatterySaverSettings(),
      ),
    ];
  }

  Widget _buildConfig(DefaultConfig configMap) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.live_tv_outlined),
          title: Text('直播间ID: ${configMap.engine.engineBili.liveId}'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            showInputNumberDialog(
              InputDialogParams(
                title: '直播间ID',
                initialValue: configMap.engine.engineBili.liveId,
                inputType: InputType.intInputType,
                isObscured: false,
                onSaved: (value) async {
                  setState(() {
                    configMap.engine.engineBili.liveId = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('账户'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/accountSettings', arguments: configMap),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.text_fields_outlined),
          title: const Text('TTS 引擎'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/ttsEnginesSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.brightness_medium_outlined),
          title: const Text('主题设置'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/themeSettings', arguments: configMap),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('弹幕机提示'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/systemPrompt', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.chat_outlined),
          title: const Text('弹幕过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/dmFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.card_giftcard_outlined),
          title: const Text('礼物过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/giftFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.anchor_outlined),
          title: const Text('舰队购买过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () =>
              Get.toNamed('/guardBuyFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.thumb_up_off_alt_outlined),
          title: const Text('点赞过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Get.toNamed('/likeFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.live_tv_outlined),
          title: const Text('进入直播间过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () =>
              Get.toNamed('/welcomeFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.star_border_outlined),
          title: const Text('关注过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () =>
              Get.toNamed('/subscribeFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.comment_bank_outlined),
          title: const Text('醒目留言过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () =>
              Get.toNamed('/superChatFilterSettings', arguments: configMap),
        ),
        ListTile(
          leading: const Icon(Icons.warning_amber),
          title: const Text('超管警告过滤器'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () =>
              Get.toNamed('/warningFilterSettings', arguments: configMap),
        ),
        if (Platform.isAndroid) ..._buildSystemSettings(),
      ],
    );
  }
}
