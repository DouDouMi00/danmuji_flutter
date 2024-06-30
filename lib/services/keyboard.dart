import '../services/messages_handler.dart' show markAllMessagesInvalid;
import '../services/config.dart';
import 'dart:math';
import '../services/tts.dart';

Future<void> handleFlush() async {
  await markAllMessagesInvalid();
}

Future<void> handleTTSRatePlus() async {
  var nowJsonConfig = getConfigMap();
  nowJsonConfig['dynamic']['tts']['rate'] += 0.2;
  nowJsonConfig['dynamic']['tts']['rate'] =
      max(nowJsonConfig['dynamic']['tts']['rate'] as double, 0.0);
  nowJsonConfig['dynamic']['tts']['rate'] =
      min(nowJsonConfig['dynamic']['tts']['rate'] as double, 5.0);
  await updateConfigMap(nowJsonConfig);
  await ttsSystem(
      'TTS语速增加到${nowJsonConfig['dynamic']['tts']['rate']}');
}

Future<void> handleTTSVolumeMinus() async {
  var nowJsonConfig = getConfigMap();
  nowJsonConfig['dynamic']['tts']['rate'] -= 1;
  nowJsonConfig['dynamic']['tts']['rate'] =
      max(nowJsonConfig['dynamic']['tts']['rate'] as double, 0.0);
  nowJsonConfig['dynamic']['tts']['rate'] =
      min(nowJsonConfig['dynamic']['tts']['rate'] as double, 5.0);
  await updateConfigMap(nowJsonConfig);
  await ttsSystem(
      'TTS语速减少到${nowJsonConfig['dynamic']['tts']['rate']}');
}

// 历史模式回到最新弹幕
Future<void> handleReadNewestMessages() async {
  await resetHistoryIndex();
}

// 历史模式查看上一条弹幕
Future<void> handleReadNextHistoryDanmu() async {
  await readHistoryByType(['danmu']);
}

// 历史模式查看下一条弹幕
Future<void> handleReadLastHistoryDanmu() async {
  await readHistoryByType(['danmu'], true);
}

// 历史模式查看上一条礼物
Future<void> handleReadNextGiftMessages() async {
  await readHistoryByType(['gift', 'guardBuy', 'superChat']);
}

// 历史模式查看下一条礼物
Future<void> handleReadLastGiftMessages() async {
  await readHistoryByType(['gift', 'guardBuy', 'superChat'], true);
}
