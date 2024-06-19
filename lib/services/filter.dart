import '../services/config.dart';
import 'dart:async';

List<String> lastDanmuMessages = [];

bool filterDanmu(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel, String msg, bool isEmoji) {
  var dynamicConfig = getConfigMap()['dynamic'];
  if (!dynamicConfig['filter']['danmu']['enable']) return false;
  if (dynamicConfig['filter']['danmu']['whitelistUsers'].contains(uid)) {
    return true;
  }
  if (dynamicConfig['filter']['danmu']['whitelistKeywords'].isNotEmpty) {
    for (var keyword in dynamicConfig['filter']['danmu']['whitelistKeywords']) {
      if (msg.contains(keyword)) return true;
    }
  }
  if (dynamicConfig['filter']['danmu']['isFansMedalBelongToLive'] &&
      !isFansMedalBelongToLive) return false;
  if (dynamicConfig['filter']['danmu']['fansMedalLevelBigger'] != 0 &&
      fansMedalLevel < dynamicConfig['filter']['danmu']['fansMedalLevelBigger']) {
    return false;
  }
  if (dynamicConfig['filter']['danmu']['fansMedalGuardLevelBigger'] != 0 &&
      fansMedalGuardLevel <
          dynamicConfig['filter']['danmu']['fansMedalGuardLevelBigger']) {
    return false;
  }
  if (dynamicConfig['filter']['danmu']['lengthShorter'] != 0 &&
      msg.length > dynamicConfig['filter']['danmu']['lengthShorter']) {
    return false;
  }
  if (!dynamicConfig['filter']['danmu']['symbolEnable'] &&
      RegExp(r'^[^\p{L}\p{N}]+$', unicode: true).hasMatch(msg)) return false;
  if (!dynamicConfig['filter']['danmu']['emojiEnable'] && isEmoji) return false;
  if (dynamicConfig['filter']['danmu']['blacklistUsers'].contains(uid)) {
    return false;
  }
  for (var keyword in dynamicConfig['filter']['danmu']['blacklistKeywords']) {
    if (msg.contains(keyword)) return false;
  }
  if (dynamicConfig['filter']['danmu']['deduplicate']) {
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

Future<bool?> filterGift(int uid, String uname, int price, String giftName,
    int num, Function(Map<String, dynamic>, String) deduplicateCallback) async {
  Map<String, dynamic> dynamicConfig = getConfigMap()['dynamic'];
  Map<String, dynamic> filterConfig =
      dynamicConfig['dynamic']['filter']['gift'];

  if (!filterConfig['enable']) {
    return false;
  }

  if (price == 0) {
    if (!filterConfig['freeGiftEnable']) {
      return false;
    }
    if (filterConfig['freeGiftCountBigger'] != 0 &&
        num < filterConfig['freeGiftCountBigger']) {
      return false;
    }
  } else {
    if (filterConfig['moneyGiftPriceBigger'] != 0 &&
        price < filterConfig['moneyGiftPriceBigger']) {
      return false;
    }
  }

  if (filterConfig['deduplicateTime'] != 0) {
    giftUids.putIfAbsent(uid.toString(), () => {'uid': uid, 'uname': uname, 'gifts': {}});

    if (giftUids[uid]['gifts'].containsKey(giftName)) {
      giftUids[uid]['gifts'][giftName]['task'].cancel();
    }

    Future<void> callback() async {
      await deduplicateCallback(giftUids[uid], giftName);
      giftUids[uid]['gifts'].remove(giftName);
    }

    giftUids[uid]['gifts'][giftName] = {
      'count': giftUids[uid]['gifts'][giftName]['count']?.toInt() ?? 0 + num,
      'task':
          Timer(Duration(seconds: filterConfig['deduplicateTime']), callback),
    };
    return null;
  }

  return true;
}

bool filterWelcome(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel) {
  final dynamicConfig = getConfigMap()['dynamic'];

  if (!dynamicConfig["filter"]["welcome"]["enable"]) return false;
  if (dynamicConfig["filter"]["welcome"]["isFansMedalBelongToLive"] &&
      !isFansMedalBelongToLive) return false;
  if (dynamicConfig["filter"]["welcome"]["fansMedalLevelBigger"] != 0 &&
      fansMedalLevel <
          dynamicConfig["filter"]["welcome"]["fansMedalLevelBigger"]) {
    return false;
  }
  if (dynamicConfig["filter"]["welcome"]["fansMedalGuardLevelBigger"] != 0 &&
      fansMedalGuardLevel <
          dynamicConfig["filter"]["welcome"]["fansMedalGuardLevelBigger"]) {
    return false;
  }
  return true;
}

bool filterGuardBuy(
    int uid, String uname, String newGuard, String giftName, int num) {
  final dynamicConfig = getConfigMap()['dynamic'];

  if (!dynamicConfig["filter"]["guardBuy"]["enable"]) return false;

  return true;
}

Map<String, bool> likedUids = {};

bool filterLike(int uid, String uname) {
  final dynamicConfig = getConfigMap()['dynamic']['filter']['like'];

  if (!dynamicConfig['enable']) {
    return false;
  }

  if (dynamicConfig['deduplicate']) {
    if (likedUids.containsKey(uid)) {
      return false;
    }
    likedUids[uid.toString()] = true;
  }

  return true;
}

bool filterSubscribe(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel) {
  var dynamicConfig = getConfigMap()['dynamic'];
  if (!dynamicConfig['filter']['subscribe']['enable']) return false;
  return true;
}

bool filterSuperChat(int uid, String uname, int price, String msg) {
  var dynamicConfig = getConfigMap()['dynamic'];
  if (!dynamicConfig['filter']['superChat']['enable']) return false;
  return true;
}

bool filterWarning(String msg, bool isCutOff) {
  var dynamicConfig = getConfigMap()['dynamic'];
  if (!dynamicConfig['filter']['warning']['enable']) return false;
  return true;
}
