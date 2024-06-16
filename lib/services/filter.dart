import '../services/config.dart' show config;

List<String> lastDanmuMessages = [];

bool filterDanmu(int uid, String uname, bool isFansMedalBelongToLive,
    int fansMedalLevel, int fansMedalGuardLevel, String msg, bool isEmoji) {
  var dynamicConfig = config.getConfigMap()['dynamic'];
  if (!dynamicConfig['filter']['danmu']['enable']) return false;
  if (dynamicConfig['filter']['danmu']['whitelistUsers'].contains(uid)) return true;
  if (dynamicConfig['filter']['danmu']['whitelistKeywords'].isNotEmpty) {
    for (var keyword in dynamicConfig['filter']['danmu']['whitelistKeywords']) {
      if (msg.contains(keyword)) return true;
    }
  }
  if (dynamicConfig['filter']['danmu']['isFansMedalBelongToLive'] && !isFansMedalBelongToLive) return false;
  if (dynamicConfig['filter']['danmu']['fansMedalLevelBigger'] != 0 && fansMedalLevel < dynamicConfig['filter']['danmu']['fansMedalLevelBigger']) return false;
  if (dynamicConfig['filter']['danmu']['fansMedalGuardLevelBigger'] != 0 && fansMedalGuardLevel < dynamicConfig['filter']['danmu']['fansMedalGuardLevelBigger']) return false;
  if (dynamicConfig['filter']['danmu']['lengthShorter'] != 0 && msg.length > dynamicConfig['filter']['danmu']['lengthShorter']) return false;
  if (!dynamicConfig['filter']['danmu']['symbolEnable'] && RegExp(r'^[^\p{L}\p{N}]+$', unicode: true).hasMatch(msg)) return false;
  if (!dynamicConfig['filter']['danmu']['emojiEnable'] && isEmoji) return false;
  if (dynamicConfig['filter']['danmu']['blacklistUsers'].contains(uid)) return false;
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
