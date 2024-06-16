// await flutterTts.awaitSpeakCompletion(true);
// while (isRunning) {
//   // 添加对isRunning的检查
//   if (ttsState == TtsState.stopped) {
//     ttsState = TtsState.playing;
//     flutterTts.setEngine(engine!);
//     flutterTts.setLanguage(language!);
//     flutterTts.setVolume(volume);
//     flutterTts.setSpeechRate(rate);
//     flutterTts.setPitch(pitch);
//     await flutterTts
//         .speak("${data["info"][2][1]}说:${data["info"][1]}");
//     flutterTts.setCompletionHandler(() {
//       ttsState = TtsState.stopped;
//     });
//     print("${data["info"][2][1]}说：${data["info"][1]}");
//     break;
//   } else {
//     // 需要延迟
//     await Future.delayed(const Duration(seconds: 1));
//   }
// }
import 'package:flutter_tts/flutter_tts.dart';
import '../services/config.dart' show config;
import '../services/messages_handler.dart' show popMessagesQueue;

late FlutterTts flutterTts;
TtsState ttsState = TtsState.stopped;

enum TtsState { playing, stopped, paused, continued }

Future<void> _setAwaitOptions() async {
  await flutterTts.awaitSpeakCompletion(true);
}

String messagesToText(Map<String, dynamic> msg) {
  final filterConfig = config.getConfigMap()['dynamic']['filter'];
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

Future<void> tts(String text) async {
  while (true) {
    if (ttsState == TtsState.stopped) {
      ttsState = TtsState.playing;
      await flutterTts.speak(text);
      flutterTts.setCompletionHandler(() {
        ttsState = TtsState.stopped;
      });
      break;
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

void init() async {
  flutterTts = FlutterTts();
  // 设置引擎和语言 音量 语速 音高
  flutterTts.setEngine(config.getConfigMap()["dynamic"]["tts"]["engine"]);
  flutterTts.setLanguage(config.getConfigMap()["dynamic"]["tts"]["language"]);
  flutterTts.setVolume(config.getConfigMap()["dynamic"]["tts"]["volume"]);
  flutterTts.setSpeechRate(config.getConfigMap()["dynamic"]["tts"]["rate"]);
  flutterTts.setPitch(config.getConfigMap()["dynamic"]["tts"]["pitch"]);
  _setAwaitOptions();
  await tts("tts 初始化完成");
}

Future<void> ttsTask() async {
  init();
  while (true) {
    Map<String, dynamic> msg = popMessagesQueue();
    if (msg == {'': ''}) {
      await Future.delayed(const Duration(milliseconds: 100));
      continue;
    }
    String text = messagesToText(msg);
    await tts(text);
  }
}
