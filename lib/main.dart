import 'package:flutter/material.dart';
import 'pages/ConfigPage/index.dart';
import 'pages/controlPage.dart';
import './services/messages_handler.dart';
import '../services/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 在运行应用前设置事件监听器
  setupEventListeners();
  await initConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

enum PageIndex { config, tts }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; // 回退到使用int类型，因为onTap接收的是int

  final List<Widget> _pages = [
    const ConfigEditPage(),
    const ControlPage(),
  ];

  // 优化1: 提供从int到PageIndex的安全访问方法
  PageIndex indexFromInt(int value) {
    if (value >= 0 && value < PageIndex.values.length) {
      return PageIndex.values[value];
    } else {
      throw ArgumentError('Invalid index: $value');
    }
  }

  PageIndex getCurrentPageIndex() {
    try {
      // 使用安全访问方法
      return indexFromInt(_currentIndex);
    } catch (e) {
      return PageIndex.config; // 假设config是默认页
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '配置',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: '快捷键',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          // 优化2: 边界检查
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
