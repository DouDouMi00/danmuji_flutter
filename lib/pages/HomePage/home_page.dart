//home_page.dart
import 'package:danmuji_flutter/pages/ControlPage/control_page.dart';
import 'package:danmuji_flutter/pages/ProfilePage/profile_page.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  // 使用列表来管理页面
  final List<Widget> pages = [
    const ControlPage(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '我的',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
