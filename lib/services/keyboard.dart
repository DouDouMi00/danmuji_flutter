import '/services/messages_handler.dart' show markAllMessagesInvalid;
import '/services/config.dart';
import 'dart:math';
import '/services/tts.dart';

Future<void> handleFlush() async {
  await markAllMessagesInvalid();
}

Future<void> handleTTSRatePlus() async {
  DefaultConfig nowJsonConfig = getConfigMap();
  double rate = nowJsonConfig.dynamicConfig.tts.rate;

  rate += 0.1;
  rate = max(rate, 0.0);
  rate = min(rate, 5.0);

  rate = double.parse(rate.toStringAsFixed(1));
  nowJsonConfig.dynamicConfig.tts.rate = rate;
  String rateFormatted = rate.toStringAsFixed(1);

  await updateConfigMap(nowJsonConfig);
  await ttsSystem('TTS语速增加到$rateFormatted');
}

Future<void> handleTTSVolumeMinus() async {
  DefaultConfig nowJsonConfig = getConfigMap();
  double rate = nowJsonConfig.dynamicConfig.tts.rate;

  rate -= 0.1;
  rate = max(rate, 0.0);
  rate = min(rate, 5.0);

  rate = double.parse(rate.toStringAsFixed(1));
  nowJsonConfig.dynamicConfig.tts.rate = rate;
  String rateFormatted = rate.toStringAsFixed(1);

  await updateConfigMap(nowJsonConfig);
  await ttsSystem('TTS语速减少到$rateFormatted');
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
