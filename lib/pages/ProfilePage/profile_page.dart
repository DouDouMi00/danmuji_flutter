// profile_page.dart
import 'package:danmuji_flutter/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(children: [
        ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            onTap: () => Get.toNamed(Routes.settings)),
      ]),
    );
  }
}
