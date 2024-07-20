import 'package:flutter_tts/flutter_tts.dart';
import '/services/config.dart';
import 'dart:math';
import '/services/messages_handler.dart'
    show popMessagesQueue, getHaveReadMessages;
import '/services/logger.dart';

late FlutterTts flutterTts;
TtsState ttsState = TtsState.stopped;
bool prepareDisableTTSTask = false;
bool disableTTSTask = false;
int? readHistoryIndex;
bool initalized = false;
bool _shouldExitTtsTask = true;

enum TtsState { playing, stopped, paused, continued }

Future<void> _setAwaitOptions() async {
  await flutterTts.awaitSpeakCompletion(true);
}

void stopTtsTask() async {
  _shouldExitTtsTask = false;
}

String messagesToText(Map<String, dynamic> msg) {
  final filterConfig = getConfigMap()['dynamic']['filter'];
  if (msg['type'] == 'danmu') {
    String liveRoomGuardLeveltxt = filterConfig['danmu']
                ['readfansMedalGuardLevel'] &&
            msg['liveRoomGuardLevel'] != 0
        ? '头衔${msg['liveRoomGuardLevelName']}'
        : '';
    String fansMedalNametxt =
        filterConfig['danmu']['readfansMedalName'] && msg['fansMedalName'] != 0
            ? '勋章${msg['fansMedalName']}'
            : '';
    String fansMedalLeveltxt =
        filterConfig['danmu']['readfansMedalName'] && msg['fansMedalLevel'] != 0
            ? '${msg['fansMedalLevel']}级'
            : '';
    return '$liveRoomGuardLeveltxt $fansMedalNametxt $fansMedalLeveltxt ${msg['uname']}说${msg['msg']}';
  } else if (msg['type'] == 'gift') {
    return '感谢${msg['uname']}送出的${msg['num']}个${msg['giftName']}';
  } else if (msg['type'] == 'guardBuy') {
    return '感谢${msg['uname']}购买${msg['num']}个月的${msg['giftName']}';
  } else if (msg['type'] == 'like') {
    return '感谢${msg['uname']}点赞';
  } else if (msg['type'] == 'superChat') {
    return '感谢${msg['uname']}的${msg['price']}元的醒目留言${msg['msg']}';
  } else if (msg['type'] == 'subscribe') {
    return '感谢${msg['uname']}关注';
  } else if (msg['type'] == 'welcome') {
    return '欢迎${msg['uname']}进入直播间';
  } else if (msg['type'] == 'warning') {
    final cutOffText = msg['isCutOff'] ? '，直播间已切断' : '';
    return '超管警告直播间${msg['msg']}$cutOffText';
  } else if (msg['type'] == 'system') {
    return '系统提示${msg['msg']}';
  } else {
    return '未知类型的消息';
  }
}

Future<void> tts(String text, [channel = 0, config]) async {
  while (ttsState == TtsState.playing) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  ttsState = TtsState.playing;
  await flutterTts.speak(text);
}

Future<void> init() async {
  _shouldExitTtsTask = true;
  flutterTts = FlutterTts();
  final ttsConfig = getConfigMap()["dynamic"]["tts"];
  // 设置引擎和语言 音量 语速 音高
  flutterTts.setEngine(ttsConfig["engine"]);
  flutterTts.setLanguage(ttsConfig["language"]);
  flutterTts.setVolume(ttsConfig["volume"]);
  flutterTts.setSpeechRate(ttsConfig["rate"]);
  flutterTts.setPitch(ttsConfig["pitch"]);
  _setAwaitOptions();
  flutterTts.setCompletionHandler(() {
    ttsState = TtsState.stopped;
  });
  await tts("tts 初始化完成");
  initalized = true;
}

Future<void> ttsTask() async {
  await init();
  while (_shouldExitTtsTask) {
    if (prepareDisableTTSTask) {
      disableTTSTask = true;
      await Future.delayed(const Duration(milliseconds: 100));
      continue;
    } else {
      disableTTSTask = false;
    }
    Map<String, dynamic>? msg = popMessagesQueue();
    if (msg == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      continue;
    }
    logger.info("取出消息$msg");
    String text = messagesToText(msg);
    await tts(text);
  }
}

Future<void> setDisableTTSTask(bool mode, {bool waiting = true}) async {
  if (prepareDisableTTSTask == false && mode == true) {
    prepareDisableTTSTask = mode;
    while (!disableTTSTask && waiting) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  } else if (prepareDisableTTSTask == true && mode == false) {
    prepareDisableTTSTask = mode;
    while (disableTTSTask && waiting) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

int ttsSystemCallerID = 0;

Future<void> ttsSystem(msg) async {
  while (!initalized) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  ttsSystemCallerID += 1;
  final myCallerID = ttsSystemCallerID;
  await setDisableTTSTask(true, waiting: false);
  await tts(messagesToText({'type': 'system', 'msg': msg}));
  if (ttsSystemCallerID != myCallerID) {
    return;
  }
  await setDisableTTSTask(false, waiting: false);
}

Future<void> readHistoryByType(List<String> types,
    [bool revert = false]) async {
  int readHistoryIndex = getHaveReadMessages().length;

  readHistoryIndex = revert
      ? (readHistoryIndex + 1) % (getHaveReadMessages().length + 1)
      : max(0, readHistoryIndex - 1);

  List<dynamic> messages = getHaveReadMessages();
  bool found = false;

  // Determine the iteration direction
  int step = revert ? 1 : -1;
  int start = revert ? 0 : readHistoryIndex;
  int end = revert ? messages.length : -1;

  for (int i = start; i != end; i += step) {
    for (String type in types) {
      if (messages[(i + messages.length) % messages.length]["type"] == type) {
        readHistoryIndex = (i + messages.length) % messages.length;
        found = true;
        break;
      }
    }
    if (found) break;
  }

  // Handle boundary conditions and provide feedback
  if ((!revert && readHistoryIndex == -1) ||
      (revert && readHistoryIndex == messages.length) ||
      !found) {
    readHistoryIndex = revert ? 0 : messages.length - 1;
    String msg = revert ? "已到达第一条,继续翻页将从最后一条开始" : "已到达最后一条,继续翻页将从第一条开始";
    await tts(messagesToText({"type": "system", "msg": msg}), 1,
        getConfigMap()["dynamic"]["tts"]["history"]);
    return;
  }

  await tts(messagesToText(messages[readHistoryIndex]), 1,
      getConfigMap()["dynamic"]["tts"]["history"]);
}

Future<void> resetHistoryIndex() async {
  readHistoryIndex = getHaveReadMessages().length;
  await tts(messagesToText({"type": "system", "msg": "焦点已回到最新"}), 1,
      getConfigMap()['dynamic']['tts']['history']);
}
