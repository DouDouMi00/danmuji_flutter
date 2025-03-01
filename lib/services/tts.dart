import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/services/logger.dart';
import 'package:danmuji_flutter/services/messages_handler.dart'
    show popMessagesQueue, getHaveReadMessages;
import 'package:danmuji_flutter/services/stats.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

late FlutterTts flutterTts;
late Tts ttsConfig;
bool prepareDisableTTSTask = false;
bool disableTTSTask = false;
int? readHistoryIndex;
bool initalized = false;
bool _shouldExitTtsTask = true;

Future<void> _setAwaitOptions() async {
  await flutterTts.awaitSpeakCompletion(true);
}

void stopTtsTask() {
  _shouldExitTtsTask = false;
}

String messagesToText(Map<String, dynamic> msg) {
  final filterConfig =
      Get.find<ConfigService>().configRx.value.dynamicConfig.filter.danmu;
  switch (msg['type']) {
    case 'danmu':
      String liveRoomGuardLeveltxt =
          filterConfig.readfansMedalGuardLevel && msg['liveRoomGuardLevel'] != 0
              ? '头衔${msg['liveRoomGuardLevelName']}'
              : '';
      String fansMedalNametxt =
          filterConfig.readfansMedalName && msg['fansMedalName'] != 0
              ? '勋章${msg['fansMedalName']}'
              : '';
      String fansMedalLeveltxt =
          filterConfig.readfansMedalName && msg['fansMedalLevel'] != 0
              ? '${msg['fansMedalLevel']}级'
              : '';
      return '$liveRoomGuardLeveltxt$fansMedalNametxt$fansMedalLeveltxt${msg['uname']}说 : ${msg['msg']}';
    case 'gift':
      return '感谢${msg['uname']}送出的${msg['num']}个${msg['giftName']}';
    case 'guardBuy':
      return '感谢${msg['uname']}购买${msg['num']}个月的${msg['giftName']}';
    case 'guardBuyOpen':
      return '感谢${msg['uname']}购买${msg['num']}${msg['unit']}的${msg['giftName']}';
    case 'like':
      return '感谢${msg['uname']}点赞';
    case 'superChat':
      return '感谢${msg['uname']}的${msg['price']}元的醒目留言${msg['msg']}';
    case 'subscribe':
      return '感谢${msg['uname']}关注';
    case 'welcome':
      return '欢迎${msg['uname']}进入直播间';
    case 'warning':
      final cutOffText = msg['isCutOff'] ? '，直播间已切断' : '';
      return '超管警告直播间${msg['msg']}$cutOffText';
    case 'system':
      return '系统提示${msg['msg']}';
    default:
      return '未知类型的消息';
  }
}

Future<void> syncWithConfig() async {
  Tts newTtsConfig = Get.find<ConfigService>().configRx.value.dynamicConfig.tts;
  if (ttsConfig.volume != newTtsConfig.volume) {
    await flutterTts.setVolume(newTtsConfig.volume);
    logger.info('音量配置更新为${newTtsConfig.volume}');
  }
  if (ttsConfig.pitch != newTtsConfig.pitch) {
    await flutterTts.setPitch(newTtsConfig.pitch);
    logger.info('音高配置更新为${newTtsConfig.pitch}');
  }
  if (ttsConfig.rate != newTtsConfig.rate) {
    await flutterTts.setSpeechRate(newTtsConfig.rate);
    logger.info('语速配置更新为${newTtsConfig.rate}');
  }
}

Future<void> tts(String text, [channel = 0, config]) async {
  await syncWithConfig();
  await flutterTts.stop();
  await flutterTts.speak(text);
}

Future<void> init() async {
  _shouldExitTtsTask = true;
  flutterTts = FlutterTts();
  ttsConfig = Get.find<ConfigService>().configRx.value.dynamicConfig.tts;
  // 设置引擎和语言 音量 语速 音高
  await flutterTts.setEngine(ttsConfig.engine);
  await flutterTts.setLanguage(ttsConfig.language);
  await flutterTts.setVolume(ttsConfig.volume);
  await flutterTts.setPitch(ttsConfig.pitch);
  await flutterTts.setSpeechRate(ttsConfig.rate);
  await _setAwaitOptions();
  initalized = true;
}

Future<void> ttsTask() async {
  await init();
  while (_shouldExitTtsTask) {
    if (prepareDisableTTSTask) {
      disableTTSTask = true;
      await Future.delayed(const Duration(milliseconds: 10));
      continue;
    } else {
      disableTTSTask = false;
    }
    Map<String, dynamic>? msg = popMessagesQueue();
    if (msg == null) {
      await Future.delayed(const Duration(milliseconds: 10));
      continue;
    }
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int storedTime = msg['time'].toInt(); // 显式转换为int类型
    int difference = currentTime - storedTime;
    appendDelay(difference ~/ 1000);
    logger.info("取出消息$msg");
    String text = messagesToText(msg);
    await tts(text);
  }
  await flutterTts.stop();
}

Future<void> setDisableTTSTask(bool mode, {bool waiting = true}) async {
  if (prepareDisableTTSTask == false && mode == true) {
    prepareDisableTTSTask = mode;
    while (!disableTTSTask && waiting) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  } else if (prepareDisableTTSTask == true && mode == false) {
    prepareDisableTTSTask = mode;
    while (disableTTSTask && waiting) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}

int ttsSystemCallerID = 0;

Future<void> ttsSystem(msg) async {
  while (!initalized) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  ttsSystemCallerID += 1;
  final myCallerID = ttsSystemCallerID;
  await setDisableTTSTask(true, waiting: false);
  appendSystemFilteredStats(false, args: {
    'type': 'system',
    'msg': msg,
  });
  await tts(messagesToText({'type': 'system', 'msg': msg}));
  if (ttsSystemCallerID != myCallerID) {
    return;
  }
  await setDisableTTSTask(false, waiting: false);
}

Iterable<int> dartRange([int start = 0, int? end, int step = 1]) sync* {
  if (end == null) {
    // 如果 end 没有提供，那么 start 就是 end，而 start 则默认从 0 开始
    end = start;
    start = 0;
  }

  // 检查步长是否为零，如果是，则抛出异常
  if (step == 0) throw ArgumentError('Step cannot be zero.');

  if (step > 0) {
    // 正向遍历
    for (var i = start; i < end; i += step) {
      yield i;
    }
  } else {
    // 反向遍历
    for (var i = start; i > end; i += step) {
      yield i;
    }
  }
}

Future<void> readHistoryByType(List<String> types,
    [bool revert = false]) async {
  readHistoryIndex ??= getHaveReadMessages().length;

  readHistoryIndex = !revert ? readHistoryIndex! - 1 : readHistoryIndex! + 1;

  List<dynamic> messages = getHaveReadMessages();
  bool found = false;

  for (var i in dartRange(readHistoryIndex!,
      !revert ? -1 : getHaveReadMessages().length, !revert ? -1 : 1)) {
    for (String type in types) {
      if (messages[i]["type"] == type) {
        readHistoryIndex = i;
        found = true;
        break;
      }
    }
    if (found) {
      break;
    }
  }

  if ((!revert && readHistoryIndex == -1) ||
      (revert && readHistoryIndex! > getHaveReadMessages().length) ||
      !found) {
    if (!revert) {
      readHistoryIndex = getHaveReadMessages().length;
      await tts(
        messagesToText({"type": "system", "msg": "已到达最后一条,继续翻页将从第一条开始"}),
        1,
        Get.find<ConfigService>().configRx.value.dynamicConfig.tts.history,
      );
    } else {
      readHistoryIndex = 0;
      await tts(
        messagesToText({"type": "system", "msg": "已到达第一条,继续翻页将从最后一条开始"}),
        1,
        Get.find<ConfigService>().configRx.value.dynamicConfig.tts.history,
      );
    }
    return;
  }
  await tts(
    messagesToText(messages[readHistoryIndex!]),
    1,
    Get.find<ConfigService>().configRx.value.dynamicConfig.tts.history,
  );
}

Future<void> resetHistoryIndex() async {
  readHistoryIndex = getHaveReadMessages().length;
  await tts(messagesToText({"type": "system", "msg": "焦点已回到最新"}), 1,
      Get.find<ConfigService>().configRx.value.dynamicConfig.tts.history);
}
