import '/services/config.dart';
import 'dart:async';

List<String> lastDanmuMessages = [];
bool filterDanmu(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel, String msg, bool isEmoji) {
  var dynamicConfig = getConfigMap().dynamicConfig.filter.danmu;
  if (!dynamicConfig.enable) return false;
  if (dynamicConfig.whitelistUsers.contains(uid)) {
    return true;
  }
  if (dynamicConfig.whitelistKeywords.isNotEmpty) {
    for (var keyword in dynamicConfig.whitelistKeywords) {
      if (msg.contains(keyword)) return true;
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
      RegExp(r'^[^\p{L}\p{N}]+$', unicode: true).hasMatch(msg)) return false;
  if (!dynamicConfig.emojiEnable && isEmoji) return false;
  if (dynamicConfig.blacklistUsers.contains(uid)) {
    return false;
  }
  for (var keyword in dynamicConfig.blacklistKeywords) {
    if (msg.contains(keyword)) return false;
  }
  if (dynamicConfig.deduplicate) {
    if (lastDanmuMessages.contains(msg)) {
      lastDanmuMessages.add('');
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
Future<bool?> filterGift(String uid, String uname, int price, String giftName,
    int num, Function(Map<String, dynamic>, String) deduplicateCallback) async {
  var dynamicConfig = getConfigMap().dynamicConfig.filter.gift;
  if (!dynamicConfig.enable) {
    return false;
  }
  if (price == 0) {
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
  if (dynamicConfig.deduplicateTime != 0) {
    if (!giftUids.containsKey(uid)) {
      giftUids[uid] = {'uid': uid, 'uname': uname, 'gifts': {}};
    }
    if (giftUids[uid]['gifts'].containsKey(giftName)) {
      giftUids[uid]['gifts'][giftName]['task'].cancel();
    }
    Timer timer = Timer(Duration(seconds: dynamicConfig.deduplicateTime), () {
      deduplicateCallback(giftUids[uid], giftName);
      giftUids[uid]['gifts'].remove(giftName);
    });
    giftUids[uid]['gifts'][giftName] = {
      'count': giftUids[uid]['gifts'][giftName]['count'] + num ?? num,
      'task': timer,
    };
    return null;
  }
  return true;
}

bool filterWelcome(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel) {
  final dynamicConfig = getConfigMap().dynamicConfig.filter.welcome;
  if (!dynamicConfig.enable) return false;
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
  final dynamicConfig = getConfigMap().dynamicConfig.filter.guardBuy;
  if (!dynamicConfig.enable) return false;
  return true;
}

Map<String, bool> likedUids = {};
bool filterLike(int uid, String uname) {
  final dynamicConfig = getConfigMap().dynamicConfig.filter.like;
  if (!dynamicConfig.enable) {
    return false;
  }
  if (dynamicConfig.deduplicate) {
    if (likedUids.containsKey(uid.toString())) {
      return false;
    }
    likedUids[uid.toString()] = true;
  }
  return true;
}

bool filterSubscribe(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel) {
  var dynamicConfig = getConfigMap().dynamicConfig.filter.subscribe;
  if (!dynamicConfig.enable) return false;
  return true;
}

bool filterSuperChat(int uid, String uname, int price, String msg) {
  var dynamicConfig = getConfigMap().dynamicConfig.filter.superChat;
  if (!dynamicConfig.enable) return false;
  return true;
}

bool filterWarning(String msg, bool isCutOff) {
  var dynamicConfig = getConfigMap().dynamicConfig.filter.warning;
  if (!dynamicConfig.enable) return false;
  return true;
}
