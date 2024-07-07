// pages/ConfigPage/config_page.dart
import 'package:flutter/material.dart';
import '/services/config.dart';
import 'package:get/get.dart';
import '/widgets/obscure_text_field.dart';

class ConfigEditPage extends StatefulWidget {
  const ConfigEditPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ConfigEditPageState createState() => _ConfigEditPageState();
}

class _ConfigEditPageState extends State<ConfigEditPage> {
  late Future<Map<String, dynamic>> _configFuture;
  late Map<String, dynamic> configMap;
  @override
  void initState() {
    super.initState();
    _configFuture = loadConfig();
  }

  Future<Map<String, dynamic>> loadConfig() async {
    return getConfigMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _configFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              configMap = snapshot.data as Map<String, dynamic>;
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _buildConfig(configMap),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildConfig(Map<String, dynamic> configMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.live_tv_outlined),
          title: Text('直播间ID: ${configMap['engine']['bili']['liveID']}'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => showInputNumberDialog({
            'title': '编辑直播间ID',
            'initialValue': configMap['engine']['bili']['liveID'].toString(),
            'onSaved': (value) {
              configMap['engine']['bili']['liveID'] = int.parse(value);
              updateConfigMap(configMap);
              setState(() {});
            },
          }),
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
      ],
    );
  }
}
