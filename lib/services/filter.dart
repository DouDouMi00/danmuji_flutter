import 'dart:async';

import 'package:danmuji_flutter/services/config.dart';
import 'package:get/get.dart';

List<String?> lastDanmuMessages = [];

bool filterDanmu(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel, String msg, bool isEmoji,
    {String? openId}) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.danmu;
  if (!dynamicConfig.enable) {
    return false;
  }
  if (dynamicConfig.whitelistUsers.contains(uid)) {
    return true;
  }
  if (dynamicConfig.whitelistOpenUsers.contains(openId)) {
    return true;
  }
  if (dynamicConfig.whitelistKeywords.isNotEmpty) {
    for (String keyword in dynamicConfig.whitelistKeywords) {
      if (msg.contains(keyword)) {
        return true;
      }
    }
  }
  if (dynamicConfig.isFansMedalBelongToLive && !isFansMedalBelongToLive) {
    return false;
  }
  if (dynamicConfig.fansMedalLevelBigger != 0 &&
      fansMedalLevel < dynamicConfig.fansMedalLevelBigger) {
    return false;
  }
  if (dynamicConfig.fansMedalGuardLevelBigger != 0 &&
      fansMedalGuardLevel < dynamicConfig.fansMedalGuardLevelBigger) {
    return false;
  }
  if (dynamicConfig.lengthShorter != 0 &&
      msg.length > dynamicConfig.lengthShorter) {
    return false;
  }
  if (!dynamicConfig.symbolEnable &&
      RegExp(r'^[^\p{L}\p{N}]+$', unicode: true).hasMatch(msg)) {
    return false;
  }
  if (!dynamicConfig.emojiEnable && isEmoji) {
    return false;
  }
  if (dynamicConfig.blacklistUsers.contains(uid)) {
    return false;
  }
  if (dynamicConfig.blacklistOpenUsers.contains(openId)) {
    return false;
  }
  for (var keyword in dynamicConfig.blacklistKeywords) {
    if (msg.contains(keyword)) {
      return false;
    }
  }
  if (dynamicConfig.deduplicate) {
    if (lastDanmuMessages.contains(msg)) {
      lastDanmuMessages.add(null);
      return false;
    }
    lastDanmuMessages.add(msg);
    if (lastDanmuMessages.length > 10) {
      lastDanmuMessages.removeAt(0);
    }
  }
  return true;
}

Map<String, dynamic> giftUids = {};
Map<String, dynamic> giftOpenIds = {};

Future<bool?> filterGift(int uid, String uname, double price, String giftName,
    int num, Function(Map<String, dynamic>, String) deduplicateCallback,
    {String? openId}) async {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.gift;
  if (!dynamicConfig.enable) {
    return false;
  }
  if (price == 0.00) {
    if (!dynamicConfig.freeGiftEnable) {
      return false;
    }
    if (dynamicConfig.freeGiftCountBigger != 0 &&
        num < dynamicConfig.freeGiftCountBigger) {
      return false;
    }
  } else {
    if (dynamicConfig.moneyGiftPriceBigger != 0 &&
        price < dynamicConfig.moneyGiftPriceBigger) {
      return false;
    }
  }
  // 开启了礼物聚合后，所有的礼物都不读除非超时和变化了礼物名称
  if (dynamicConfig.deduplicateTime != 0) {
    String uidstr = uid.toString();
    if (!giftUids.containsKey(uidstr)) {
      giftUids[uidstr] = {'uid': uidstr, 'uname': uname, 'gifts': {}};
    }
    if (giftUids[uidstr]['gifts'].containsKey(giftName)) {
      giftUids[uidstr]['gifts'][giftName]['task'].cancel();
    }
    Timer timer = Timer(Duration(seconds: dynamicConfig.deduplicateTime), () {
      deduplicateCallback(giftUids[uidstr], giftName);
      giftUids[uidstr]['gifts'].remove(giftName);
    });
    giftUids[uidstr]['gifts'][giftName] = {
      'count': giftUids[uidstr]["gifts"].containsKey(giftName)
          ? giftUids[uidstr]["gifts"][giftName]["count"] + num
          : num,
      'task': timer,
    };
    return null;
  }
  if (openId != null) {
    if (dynamicConfig.deduplicateTime != 0) {
      if (!giftOpenIds.containsKey(openId)) {
        giftOpenIds[openId] = {'openId': openId, 'uname': uname, 'gifts': {}};
      }
      if (giftOpenIds[openId]['gifts'].containsKey(giftName)) {
        giftOpenIds[openId]['gifts'][giftName]['task'].cancel();
      }
      Timer timer = Timer(Duration(seconds: dynamicConfig.deduplicateTime), () {
        deduplicateCallback(giftOpenIds[openId], giftName);
        giftOpenIds[openId]['gifts'].remove(giftName);
      });
      giftOpenIds[openId]['gifts'][giftName] = {
        'count': giftOpenIds[openId]["gifts"].containsKey(giftName)
            ? giftOpenIds[openId]["gifts"][giftName]["count"] + num
            : num,
        'task': timer,
      };
      return null;
    }
  }

  return true;
}

bool filterWelcome(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.welcome;
  if (!dynamicConfig.enable) {
    return false;
  }
  if (dynamicConfig.isFansMedalBelongToLive && !isFansMedalBelongToLive) {
    return false;
  }
  if (dynamicConfig.fansMedalLevelBigger != 0 &&
      fansMedalLevel < dynamicConfig.fansMedalLevelBigger) {
    return false;
  }
  if (dynamicConfig.fansMedalGuardLevelBigger != 0 &&
      fansMedalGuardLevel < dynamicConfig.fansMedalGuardLevelBigger) {
    return false;
  }
  return true;
}

bool filterGuardBuy(
    int uid, String uname, bool newGuard, String giftName, int num) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.guardBuy;
  if (!dynamicConfig.enable) {
    return false;
  }
  return true;
}

Map<String, bool> likedUids = {};
Map<String, bool> likedOpenIds = {};

bool filterLike(int uid, String uname, {String? openId}) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.like;
  if (!dynamicConfig.enable) {
    return false;
  }
  if (dynamicConfig.deduplicate) {
    if (likedUids.containsKey(uid.toString())) {
      return false;
    }
    likedUids[uid.toString()] = true;
  }
  if (openId != null) {
    if (dynamicConfig.deduplicate) {
      if (likedOpenIds.containsKey(openId)) {
        return false;
      }
      likedOpenIds[openId] = true;
    }
  }
  return true;
}

bool filterSubscribe(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.subscribe;
  if (!dynamicConfig.enable) {
    return false;
  }
  return true;
}

bool filterSuperChat(int uid, String uname, double price, String msg) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.superChat;
  if (!dynamicConfig.enable) {
    return false;
  }
  return true;
}

bool filterWarning(String msg, bool isCutOff) {
  var dynamicConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.warning;
  if (!dynamicConfig.enable) {
    return false;
  }
  return true;
}
