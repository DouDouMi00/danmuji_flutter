import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '/controllers/home_controller.dart';
import '/pages/ConfigPage/config_page.dart';
import '/pages/control_page.dart';
import '/pages/custom_theme.dart';
import '/routes.dart';
import '/services/config.dart';

// import '/services/logger.dart';
// https://juejin.cn/post/6844904039495237639

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initConfig();
  final theme = await storage.read(key: 'theme');
  runApp(MyApp(theme: theme));
  // 添加监听器处理日志记录
  // logger.onRecord.listen(handleLogRecord);
}

class MyApp extends StatelessWidget {
  final String? theme;

  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final themeModeMap = {
      '0': ThemeMode.system,
      '1': ThemeMode.light,
      '2': ThemeMode.dark,
    };
    return GetMaterialApp(
      locale: Get.deviceLocale,
      // showSemanticsDebugger: true,
      localizationsDelegates: const [
        // 本地化的代理类
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // 美国英语
        Locale('zh', 'CN'), // 中文简体
        //其它Locales
      ],
      initialRoute: '/',
      home: const MyHomePage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeModeMap[theme] ?? ThemeMode.system,
      getPages: appRoutes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: controller.currentIndex.value == 0
            ? const ControlPage()
            : const ConfigEditPage(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.control_camera),
              label: '主页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              label: '配置',
            ),
          ],
          currentIndex: controller.currentIndex.value,
          onTap: controller.onTabChange,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
