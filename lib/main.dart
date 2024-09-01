import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/controllers/home_controller.dart';
import '/pages/ConfigPage/config_page.dart';
import '/pages/control_page.dart';
import '/pages/custom_theme.dart';
import '/routes.dart';
import '/services/config.dart';

// import '/services/logger.dart';

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
    return GetMaterialApp(
      initialRoute: '/',
      home: const MyHomePage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme == '0'
          ? MediaQuery.of(context).platformBrightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light
          : theme == '1'
              ? ThemeMode.light
              : ThemeMode.dark,
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
                icon: Icon(Icons.control_camera), label: '主页'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
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
