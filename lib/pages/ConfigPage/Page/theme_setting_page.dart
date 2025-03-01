//system_prompt_page.dart
import 'package:danmuji_flutter/common/colors/custom_theme.dart';
import 'package:danmuji_flutter/services/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// https://cloud.tencent.com/developer/article/2421058

class ThemeSettingPage extends StatelessWidget {
  ThemeSettingPage({super.key});

  final configService = Get.find<ConfigService>();
  static const themeTitles = ['跟随系统', '浅色模式', '深色模式'];

  @override
  Widget build(BuildContext context) {
    Future<void> changeTheme(int index) async {
      ThemeData theme;
      switch (index) {
        case 1:
          theme = lightTheme;
          break;
        case 2:
          theme = darkTheme;
          break;
        default:
          // 默认使用自动模式
          final defaultBrightness = MediaQuery.of(context).platformBrightness;
          theme = defaultBrightness == Brightness.dark ? darkTheme : lightTheme;
      }

      configService.configRx.value.system.theme = index;
      configService.configRx.refresh();
      Get.changeTheme(theme);
      await Get.forceAppUpdate();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (_, index) => RadioListTile<int>(
            title: Text(themeTitles[index]),
            value: index,
            groupValue: configService.configRx.value.system.theme,
            onChanged: (value) => changeTheme(value!),
          ),
        ),
      ),
    );
  }
}
