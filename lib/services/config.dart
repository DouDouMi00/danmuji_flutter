// services/config.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'default_config_entity.dart';
export '/services/default_config_entity.dart';

// 定义配置的键名
const String _configKey = 'app_config';
late SharedPreferences prefs;
late Map<String, dynamic> config;

// 定义配置的默认值
final Map<String, dynamic> _defaultConfig = {
  "kvdb": {
    "kvdbBili": {"uid": 0, "buvid3": "", "sessdata": "", "jct": ""},
    "isFirstTimeToLogin": true
  },
  "engine": {
    "engineBili": {"liveID": 21654925}
  },
  "dynamicConfig": {
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
        "blacklistKeywords": [],
        "whitelistUsers": [],
        "whitelistKeywords": []
      },
      "gift": {
        "enable": true,
        "freeGiftEnable": true,
        "deduplicateTime": 10,
        "freeGiftCountBigger": 0,
        "moneyGiftPriceBigger": 0
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

// 初始化配置
Future<void> initConfig() async {
  prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString(_configKey);
  if (jsonString != null) {
    config = jsonDecode(jsonString);
    // 合并默认配置和已存在的配置
    mergeConfigRecursively(_defaultConfig, config);
    await prefs.setString(_configKey, jsonEncode(config));
  } else {
    config = _defaultConfig;
    await prefs.setString(_configKey, jsonEncode(config));
  }
}

// 更新配置
Future<void> updateConfigMap(DefaultConfig newConfig) async {
  // 将配置转换为JSON字符串并保存
  config = newConfig.toJson();
  await prefs.setString(_configKey, jsonEncode(config));
}

// 获取配置
DefaultConfig getConfigMap() {
  return defaultConfigFromJson(jsonEncode(config));
}
