// services/config.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'default_config_entity.dart';

export '/services/default_config_entity.dart';

class ConfigService extends GetxService {
  // late AppConfig config;
  late Rx<AppConfig> configRx;
  Map<String, dynamic> _configMap = {};

  // 定义配置的键名
  final String _configKey = 'app_config';
  late GetStorage _storage;

  // 定义配置的默认值
  final Map<String, dynamic> _defaultConfig = {
    "system": {
      "theme": 0,
      "language": "zh-CN",
    },
    "kvdb": {
      "kvdbBili": {
        "uid": 0,
        "buvid3": "",
        "sessdata": "",
        "jct": "",
      },
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

  // 初始化配置
  Future<ConfigService> initConfig({bool test = false}) async {
    await GetStorage.init();
    _storage = GetStorage();
    if (test) {
      _configMap = _defaultConfig;
      return this;
    }
    final jsonString = _storage.read(_configKey);
    if (jsonString != null) {
      _configMap = jsonDecode(jsonString);
      // 合并默认配置和已存在的配置
      //TODO：合并配置文件，这里有问题，需要优化
      mergeConfigRecursively(_defaultConfig, _configMap);
      configRx = AppConfig.fromJson(_configMap).obs;
      await _storage.write(_configKey, appConfigToJson(configRx.value));
    } else {
      _configMap = _defaultConfig;
      configRx = AppConfig.fromJson(_configMap).obs;
      await _storage.write(_configKey, appConfigToJson(configRx.value));
    }
    ever(configRx, (_) async {
      await updateConfigMap();
    });
    return this;
  }

  // 更新配置
  Future<void> updateConfigMap({bool test = false}) async {
    if (test) return;
    await _storage.write(_configKey, appConfigToJson(configRx.value));
  }
}
