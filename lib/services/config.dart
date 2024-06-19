import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


Map<String, dynamic> _configMap = {};
String _configPath = '';

// 合并配置
void mergeConfigRecursively(
    Map<String, dynamic> template, Map<String, dynamic> raw) {
  template.forEach((key, value) {
    if (!raw.containsKey(key)) {
      raw[key] = value;
    } else if (value is Map<String, dynamic>) {
      mergeConfigRecursively(value, raw[key] as Map<String, dynamic>);
    }
  });
}

// 获取应用程序文档目录
Future<void> initConfig() async {
  final directory = await getApplicationDocumentsDirectory();
  _configPath = '${directory.path}/config.json';
  // 读取现有的配置文件
  if (await File(_configPath).exists()) {
    final jsonString = await File(_configPath).readAsString();
    _configMap = jsonDecode(jsonString);
  } else {
    _configMap = {};
  }
  // 从资源加载模板配置文件
  final fileContent =
      await rootBundle.loadString('assets/config.template.json');
  final templateConfig = jsonDecode(fileContent);
  mergeConfigRecursively(templateConfig, _configMap);
  File(_configPath).writeAsStringSync(jsonEncode(_configMap));
}

// 更新配置
Future<Map<String, dynamic>> updateConfigMap(config) async {
    // 遍历新配置并合并到老配置中
  config.forEach((key, value) {
    _configMap[key] = value;
  });
  File(_configPath).writeAsString(jsonEncode(_configMap));
  return _configMap;
}

// 提供访问_configMap的方法，确保在调用前已经初始化了_configMap
Map<String, dynamic> getConfigMap() {
  return _configMap;
}