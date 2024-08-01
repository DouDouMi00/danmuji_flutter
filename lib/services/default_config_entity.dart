//default_config_entity.dart
// https://app.quicktype.io/

// To parse this JSON data, do
//
//     final defaultConfig = defaultConfigFromJson(jsonString);

import 'dart:convert';

DefaultConfig defaultConfigFromJson(String str) =>
    DefaultConfig.fromJson(json.decode(str));

String defaultConfigToJson(DefaultConfig data) => json.encode(data.toJson());

class DefaultConfig {
  Kvdb kvdb;
  Engine engine;
  DynamicConfig dynamicConfig;

  DefaultConfig({
    required this.kvdb,
    required this.engine,
    required this.dynamicConfig,
  });

  factory DefaultConfig.fromJson(Map<String, dynamic> json) => DefaultConfig(
        kvdb: Kvdb.fromJson(json["kvdb"]),
        engine: Engine.fromJson(json["engine"]),
        dynamicConfig: DynamicConfig.fromJson(json["dynamicConfig"]),
      );

  Map<String, dynamic> toJson() => {
        "kvdb": kvdb.toJson(),
        "engine": engine.toJson(),
        "dynamicConfig": dynamicConfig.toJson(),
      };
}

class DynamicConfig {
  Tts tts;
  Filter filter;

  DynamicConfig({
    required this.tts,
    required this.filter,
  });

  factory DynamicConfig.fromJson(Map<String, dynamic> json) => DynamicConfig(
        tts: Tts.fromJson(json["tts"]),
        filter: Filter.fromJson(json["filter"]),
      );

  Map<String, dynamic> toJson() => {
        "tts": tts.toJson(),
        "filter": filter.toJson(),
      };
}

class Filter {
  Danmu danmu;
  Gift gift;
  GuardBuy guardBuy;
  Like like;
  Welcome welcome;
  GuardBuy subscribe;
  GuardBuy superChat;
  GuardBuy warning;

  Filter({
    required this.danmu,
    required this.gift,
    required this.guardBuy,
    required this.like,
    required this.welcome,
    required this.subscribe,
    required this.superChat,
    required this.warning,
  });

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        danmu: Danmu.fromJson(json["danmu"]),
        gift: Gift.fromJson(json["gift"]),
        guardBuy: GuardBuy.fromJson(json["guardBuy"]),
        like: Like.fromJson(json["like"]),
        welcome: Welcome.fromJson(json["welcome"]),
        subscribe: GuardBuy.fromJson(json["subscribe"]),
        superChat: GuardBuy.fromJson(json["superChat"]),
        warning: GuardBuy.fromJson(json["warning"]),
      );

  Map<String, dynamic> toJson() => {
        "danmu": danmu.toJson(),
        "gift": gift.toJson(),
        "guardBuy": guardBuy.toJson(),
        "like": like.toJson(),
        "welcome": welcome.toJson(),
        "subscribe": subscribe.toJson(),
        "superChat": superChat.toJson(),
        "warning": warning.toJson(),
      };
}

class Danmu {
  bool enable;
  bool symbolEnable;
  bool emojiEnable;
  bool deduplicate;
  bool readfansMedalName;
  bool readfansMedalGuardLevel;
  bool isFansMedalBelongToLive;
  int fansMedalGuardLevelBigger;
  int fansMedalLevelBigger;
  int lengthShorter;
  List<int> blacklistUsers;
  List<String> blacklistKeywords;
  List<int> whitelistUsers;
  List<String> whitelistKeywords;

  Danmu({
    required this.enable,
    required this.symbolEnable,
    required this.emojiEnable,
    required this.deduplicate,
    required this.readfansMedalName,
    required this.readfansMedalGuardLevel,
    required this.isFansMedalBelongToLive,
    required this.fansMedalGuardLevelBigger,
    required this.fansMedalLevelBigger,
    required this.lengthShorter,
    required this.blacklistUsers,
    required this.blacklistKeywords,
    required this.whitelistUsers,
    required this.whitelistKeywords,
  });

  factory Danmu.fromJson(Map<String, dynamic> json) => Danmu(
        enable: json["enable"],
        symbolEnable: json["symbolEnable"],
        emojiEnable: json["emojiEnable"],
        deduplicate: json["deduplicate"],
        readfansMedalName: json["readfansMedalName"],
        readfansMedalGuardLevel: json["readfansMedalGuardLevel"],
        isFansMedalBelongToLive: json["isFansMedalBelongToLive"],
        fansMedalGuardLevelBigger: json["fansMedalGuardLevelBigger"],
        fansMedalLevelBigger: json["fansMedalLevelBigger"],
        lengthShorter: json["lengthShorter"],
        blacklistUsers: List<int>.from(json["blacklistUsers"].map((x) => x)),
        blacklistKeywords:
            List<String>.from(json["blacklistKeywords"].map((x) => x)),
        whitelistUsers: List<int>.from(json["whitelistUsers"].map((x) => x)),
        whitelistKeywords:
            List<String>.from(json["whitelistKeywords"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
        "symbolEnable": symbolEnable,
        "emojiEnable": emojiEnable,
        "deduplicate": deduplicate,
        "readfansMedalName": readfansMedalName,
        "readfansMedalGuardLevel": readfansMedalGuardLevel,
        "isFansMedalBelongToLive": isFansMedalBelongToLive,
        "fansMedalGuardLevelBigger": fansMedalGuardLevelBigger,
        "fansMedalLevelBigger": fansMedalLevelBigger,
        "lengthShorter": lengthShorter,
        "blacklistUsers": List<dynamic>.from(blacklistUsers.map((x) => x)),
        "blacklistKeywords":
            List<dynamic>.from(blacklistKeywords.map((x) => x)),
        "whitelistUsers": List<dynamic>.from(whitelistUsers.map((x) => x)),
        "whitelistKeywords":
            List<dynamic>.from(whitelistKeywords.map((x) => x)),
      };
}

class Gift {
  bool enable;
  bool freeGiftEnable;
  int deduplicateTime;
  int freeGiftCountBigger;
  double moneyGiftPriceBigger;

  Gift({
    required this.enable,
    required this.freeGiftEnable,
    required this.deduplicateTime,
    required this.freeGiftCountBigger,
    required this.moneyGiftPriceBigger,
  });

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
        enable: json["enable"],
        freeGiftEnable: json["freeGiftEnable"],
        deduplicateTime: json["deduplicateTime"],
        freeGiftCountBigger: json["freeGiftCountBigger"],
        moneyGiftPriceBigger: json["moneyGiftPriceBigger"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
        "freeGiftEnable": freeGiftEnable,
        "deduplicateTime": deduplicateTime,
        "freeGiftCountBigger": freeGiftCountBigger,
        "moneyGiftPriceBigger": moneyGiftPriceBigger,
      };
}

class GuardBuy {
  bool enable;

  GuardBuy({
    required this.enable,
  });

  factory GuardBuy.fromJson(Map<String, dynamic> json) => GuardBuy(
        enable: json["enable"],
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
      };
}

class Like {
  bool enable;
  bool deduplicate;

  Like({
    required this.enable,
    required this.deduplicate,
  });

  factory Like.fromJson(Map<String, dynamic> json) => Like(
        enable: json["enable"],
        deduplicate: json["deduplicate"],
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
        "deduplicate": deduplicate,
      };
}

class Welcome {
  bool enable;
  bool isFansMedalBelongToLive;
  int fansMedalGuardLevelBigger;
  int fansMedalLevelBigger;

  Welcome({
    required this.enable,
    required this.isFansMedalBelongToLive,
    required this.fansMedalGuardLevelBigger,
    required this.fansMedalLevelBigger,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        enable: json["enable"],
        isFansMedalBelongToLive: json["isFansMedalBelongToLive"],
        fansMedalGuardLevelBigger: json["fansMedalGuardLevelBigger"],
        fansMedalLevelBigger: json["fansMedalLevelBigger"],
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
        "isFansMedalBelongToLive": isFansMedalBelongToLive,
        "fansMedalGuardLevelBigger": fansMedalGuardLevelBigger,
        "fansMedalLevelBigger": fansMedalLevelBigger,
      };
}

class Tts {
  String engine;
  String language;
  double volume;
  double rate;
  double pitch;
  Tts? history;

  Tts({
    required this.engine,
    required this.language,
    required this.volume,
    required this.rate,
    required this.pitch,
    this.history,
  });

  factory Tts.fromJson(Map<String, dynamic> json) => Tts(
        engine: json["engine"],
        language: json["language"],
        volume: json["volume"]?.toDouble(),
        rate: json["rate"]?.toDouble(),
        pitch: json["pitch"]?.toDouble(),
        history: json["history"] == null ? null : Tts.fromJson(json["history"]),
      );

  Map<String, dynamic> toJson() => {
        "engine": engine,
        "language": language,
        "volume": volume,
        "rate": rate,
        "pitch": pitch,
        "history": history?.toJson(),
      };
}

class Engine {
  EngineBili engineBili;

  Engine({
    required this.engineBili,
  });

  factory Engine.fromJson(Map<String, dynamic> json) => Engine(
        engineBili: EngineBili.fromJson(json["engineBili"]),
      );

  Map<String, dynamic> toJson() => {
        "engineBili": engineBili.toJson(),
      };
}

class EngineBili {
  int liveId;

  EngineBili({
    required this.liveId,
  });

  factory EngineBili.fromJson(Map<String, dynamic> json) => EngineBili(
        liveId: json["liveID"],
      );

  Map<String, dynamic> toJson() => {
        "liveID": liveId,
      };
}

class Kvdb {
  KvdbBili kvdbBili;
  bool isFirstTimeToLogin;

  Kvdb({
    required this.kvdbBili,
    required this.isFirstTimeToLogin,
  });

  factory Kvdb.fromJson(Map<String, dynamic> json) => Kvdb(
        kvdbBili: KvdbBili.fromJson(json["kvdbBili"]),
        isFirstTimeToLogin: json["isFirstTimeToLogin"],
      );

  Map<String, dynamic> toJson() => {
        "kvdbBili": kvdbBili.toJson(),
        "isFirstTimeToLogin": isFirstTimeToLogin,
      };
}

class KvdbBili {
  int uid;
  String buvid3;
  String sessdata;
  String jct;

  KvdbBili({
    required this.uid,
    required this.buvid3,
    required this.sessdata,
    required this.jct,
  });

  factory KvdbBili.fromJson(Map<String, dynamic> json) => KvdbBili(
        uid: json["uid"],
        buvid3: json["buvid3"],
        sessdata: json["sessdata"],
        jct: json["jct"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "buvid3": buvid3,
        "sessdata": sessdata,
        "jct": jct,
      };
}

// // 模板
// Map<String, Map<String, Object>> template = {
//   "kvdb": {
//     "kvdbBili": {"uid": 0, "buvid3": "", "sessdata": "", "jct": ""},
//     "isFirstTimeToLogin": true
//   },
//   "engine": {
//     "engineBili": {"liveID": 0}
//   },
//   "dynamicConfig": {
//     "tts": {
//       "engine": "",
//       "language": "",
//       "volume": 1.1,
//       "rate": 1.1,
//       "pitch": 1.1,
//       "history": {
//         "engine": "",
//         "language": "",
//         "volume": 1.1,
//         "rate": 1.1,
//         "pitch": 1.1
//       }
//     },
//     "filter": {
//       "danmu": {
//         "enable": true,
//         "symbolEnable": true,
//         "emojiEnable": true,
//         "deduplicate": false,
//         "readfansMedalName": false,
//         "readfansMedalGuardLevel": true,
//         "isFansMedalBelongToLive": false,
//         "fansMedalGuardLevelBigger": 0,
//         "fansMedalLevelBigger": 0,
//         "lengthShorter": 0,
//         "blacklistUsers": [0, 0],
//         "blacklistKeywords": ["", ""],
//         "whitelistUsers": [0, 0],
//         "whitelistKeywords": ["", ""]
//       },
//       "gift": {
//         "enable": true,
//         "freeGiftEnable": true,
//         "deduplicateTime": 10,
//         "freeGiftCountBigger": 0,
//         "moneyGiftPriceBigger": 1.1
//       },
//       "guardBuy": {"enable": true},
//       "like": {"enable": true, "deduplicate": true},
//       "welcome": {
//         "enable": true,
//         "isFansMedalBelongToLive": false,
//         "fansMedalGuardLevelBigger": 0,
//         "fansMedalLevelBigger": 0
//       },
//       "subscribe": {"enable": true},
//       "superChat": {"enable": true},
//       "warning": {"enable": true}
//     }
//   }
// };
