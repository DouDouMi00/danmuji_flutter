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
  late int _selectedThemeIndex;

  @override
  void initState() {
    super.initState();
    _selectedThemeIndex = prefs.getInt('theme') ?? 0;
  }

  ///切换主题
  Future<void> changeTheme(BuildContext context, int themeIndex) async {
    ThemeData themeData;
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
    await prefs.setInt('theme', themeIndex);
    Get.changeTheme(themeData);
    Get.forceAppUpdate();
    setState(() {
      _selectedThemeIndex = themeIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('跟随系统'),
                trailing: Radio(
                  value: 0,
                  groupValue: _selectedThemeIndex,
                  onChanged: (value) {
                    changeTheme(context, 0);
                  },
                ),
                onTap: () async {
                  await changeTheme(context, 0);
                },
              ),
              ListTile(
                title: const Text('浅色模式'),
                trailing: Radio(
                  value: 1,
                  groupValue: _selectedThemeIndex,
                  onChanged: (value) {
                    changeTheme(context, 1);
                  },
                ),
                onTap: () async {
                  await changeTheme(context, 1);
                },
              ),
              ListTile(
                title: const Text('深色模式'),
                trailing: Radio(
                  value: 2,
                  groupValue: _selectedThemeIndex,
                  onChanged: (value) {
                    changeTheme(context, 2);
                  },
                ),
                onTap: () async {
                  await changeTheme(context, 2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
