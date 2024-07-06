import './services/messages_handler.dart';
import './services/config.dart';
import 'package:flutter/material.dart';
import 'pages/ConfigPage/index.dart';
import 'pages/controlPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupEventListeners();
  await initConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: MyHomePage(),
      );
}

enum PageIndex { config, control }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ConfigEditPage(),
    const ControlPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '配置'),
            BottomNavigationBarItem(
                icon: Icon(Icons.control_camera), label: '快捷键'),
          ],
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
      );
}
