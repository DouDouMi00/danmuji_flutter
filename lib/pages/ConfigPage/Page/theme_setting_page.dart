//system_prompt_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/pages/custom_theme.dart';
import '/services/config.dart';

// https://cloud.tencent.com/developer/article/2421058

class ThemeSettingPage extends StatefulWidget {
  const ThemeSettingPage({super.key});

  @override
  ThemeSettingPageState createState() => ThemeSettingPageState();
}

class ThemeSettingPageState extends State<ThemeSettingPage> {
  int? _selectedThemeIndex;

  @override
  void initState() {
    super.initState();
    loadSelectedThemeIndex();
  }

  /// 加载主题设置
  Future<void> loadSelectedThemeIndex() async {
    String? themeValue = await storage.read(key: 'theme');
    if (themeValue == null) {
      _selectedThemeIndex = null;
    } else {
      _selectedThemeIndex = int.parse(themeValue);
    }
    setState(() {});
  }

  ///切换主题
  Future<void> changeTheme(BuildContext context, int themeIndex) async {
    ThemeData themeData;
    _selectedThemeIndex = themeIndex;
    setState(() {});
    switch (themeIndex) {
      case 0: //跟随系统
        themeData = MediaQuery.of(context).platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
        break;
      case 1: //浅色模式
        themeData = lightTheme;
        break;
      case 2: //深色模式
        themeData = darkTheme;
        break;
      default:
        themeData = MediaQuery.of(context).platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
        break;
    }
    //保存到本地
    await storage.write(key: 'theme', value: themeIndex.toString());
    Get.changeTheme(themeData);
    await Get.forceAppUpdate();
  }

  String getThemeTitle(int index) {
    switch (index) {
      case 0:
        return '跟随系统';
      case 1:
        return '浅色模式';
      case 2:
        return '深色模式';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return RadioListTile<int>(
              title: Text(getThemeTitle(index)),
              value: index,
              groupValue: _selectedThemeIndex,
              onChanged: (value) async {
                await changeTheme(context, value!);
              },
            );
          },
        ),
      ),
    );
  }
}
