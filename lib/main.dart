import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/home_controller.dart';
import '/services/messages_handler.dart';
import '/services/config.dart';
import 'pages/ConfigPage/config_page.dart';
import 'pages/control_page.dart';
import '/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupEventListeners();
  await initConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      home: const MyHomePage(),
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
            ? const ConfigEditPage()
            : const ControlPage(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
            BottomNavigationBarItem(
                icon: Icon(Icons.control_camera), label: '快捷键'),
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
