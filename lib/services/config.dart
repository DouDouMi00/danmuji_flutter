// services/config.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'default_config_entity.dart';

export '/services/default_config_entity.dart';

// 定义配置的键名
const String _configKey = 'app_config';
late FlutterSecureStorage storage;
late Map<String, dynamic> config;

// 定义配置的默认值
final Map<String, dynamic> _defaultConfig = {
  "kvdb": {
    "kvdbBili": {"uid": 0, "buvid3": "", "sessdata": "", "jct": ""},
    "openLiveBili": {
      "idCode": "",
      "appId": 0,
      "accessKey": "",
      "accessKeySecret": ""
    },
    "isFirstTimeToLogin": true
  },
  "engine": {
    "engineBili": {"liveID": 0}
  },
  "dynamicConfig": {
    "dynamicSystem": {
      "alertWhenMessagesQueueLonger": {
        "enable": true,
        "threshold": 50,
        "interval": 30
      }
    },
    "tts": {
      "engine": "",
      "language": "",
      "volume": 1.0,
      "rate": 1.0,
      "pitch": 1.0,
      "history": {
        "engine": "",
        "language": "",
        "volume": 1.0,
        "rate": 1.0,
        "pitch": 1.0
      }
    },
    "filter": {
      "danmu": {
        "enable": true,
        "symbolEnable": true,
        "emojiEnable": true,
        "deduplicate": false,
        "readfansMedalName": false,
        "readfansMedalGuardLevel": true,
        "isFansMedalBelongToLive": false,
        "fansMedalGuardLevelBigger": 0,
        "fansMedalLevelBigger": 0,
        "lengthShorter": 0,
        "blacklistUsers": [],
        "blacklistOpenUsers": [],
        "blacklistKeywords": [],
        "whitelistUsers": [],
        "whitelistOpenUsers": [],
        "whitelistKeywords": []
      },
      "gift": {
        "enable": true,
        "freeGiftEnable": true,
        "deduplicateTime": 10,
        "freeGiftCountBigger": 0,
        "moneyGiftPriceBigger": 0.0
      },
      "guardBuy": {"enable": true},
      "like": {"enable": true, "deduplicate": true},
      "welcome": {
        "enable": true,
        "isFansMedalBelongToLive": false,
        "fansMedalGuardLevelBigger": 0,
        "fansMedalLevelBigger": 0
      },
      "subscribe": {"enable": true},
      "superChat": {"enable": true},
      "warning": {"enable": true}
    }
  }
};

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

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

// 初始化配置
Future<void> initConfig({bool test = false}) async {
  if (test) {
    config = _defaultConfig;
    return;
  }
  storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  final jsonString = await storage.read(key: _configKey);
  if (await storage.read(key: 'theme') == null) {
    await storage.write(key: 'theme', value: "0");
  }
  if (jsonString != null) {
    config = jsonDecode(jsonString);
    // 合并默认配置和已存在的配置
    mergeConfigRecursively(_defaultConfig, config);
    await storage.write(key: _configKey, value: jsonEncode(config));
  } else {
    config = _defaultConfig;
    await storage.write(key: _configKey, value: jsonEncode(config));
  }
}

// 更新配置
Future<void> updateConfigMap(DefaultConfig newConfig,
    {bool test = false}) async {
  // 将配置转换为JSON字符串并保存
  config = newConfig.toJson();
  if (!test) {
    await storage.write(key: _configKey, value: jsonEncode(config));
  }
}

// 获取配置
DefaultConfig getConfigMap() {
  return defaultConfigFromJson(jsonEncode(config));
}
