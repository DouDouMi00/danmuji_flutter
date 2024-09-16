import 'dart:convert';

import '/services/logger.dart';
import 'event_emitter.dart';

EventEmitter statsEvent = EventEmitter();

List registeredStatsCount = [];
Map<String, dynamic> lastDurationStats = {};
List<Map<String, dynamic>> messagesQueue = [];
List delaysQueue = [];
bool statsTaskRunning = true;

// rawDanmu
// rawGift
// rawWelcome
// rawLike
// rawGuardBuy
// rawSubscribe
// rawSuperChat
// rawWarning

void resetDuration() {
  messagesQueue = [];
  delaysQueue = [];
  lastDurationStats = {
    'messagesQueueLength': lastDurationStats.isNotEmpty
        ? lastDurationStats['messagesQueueLength']
        : 0,
    'delay': 0
  };
  for (String type in registeredStatsCount) {
    lastDurationStats["raw${type[0].toUpperCase()}${type.substring(1)}"] = 0;
    lastDurationStats["filtered${type[0].toUpperCase()}${type.substring(1)}"] =
        0;
  }
}

Function(bool filterd, {dynamic args}) statsFunctionGenerator(String type) {
  registeredStatsCount.add(type);
  void statsFunction(bool filterd, {dynamic args}) {
    lastDurationStats.update(
      "raw${type[0].toUpperCase()}${type.substring(1)}",
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    if (filterd) {
      lastDurationStats.update(
        "filtered${type[0].toUpperCase()}${type.substring(1)}",
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    messagesQueue.add({
      'type': type,
      'filterd': filterd,
      ...args,
    });
  }

  return statsFunction;
}

Function(bool filterd, {dynamic args}) appendDanmuFilteredStats =
    statsFunctionGenerator('danmu');
Function(bool filterd, {dynamic args}) appendGiftFilteredStats =
    statsFunctionGenerator('gift');
Function(bool filterd, {dynamic args}) appendWelcomeFilteredStats =
    statsFunctionGenerator('welcome');
Function(bool filterd, {dynamic args}) appendLikeFilteredStats =
    statsFunctionGenerator('like');
Function(bool filterd, {dynamic args}) appendGuardBuyFilteredStats =
    statsFunctionGenerator('guardBuy');
Function(bool filterd, {dynamic args}) appendSubscribeFilteredStats =
    statsFunctionGenerator('subscribe');
Function(bool filterd, {dynamic args}) appendSuperChatFilteredStats =
    statsFunctionGenerator('superChat');
Function(bool filterd, {dynamic args}) appendWarningFilteredStats =
    statsFunctionGenerator('warning');
Function(bool filterd, {dynamic args}) appendSystemFilteredStats =
    statsFunctionGenerator('system');

int getDelay() {
  if (delaysQueue.isEmpty) {
    return 0;
  }
  return (delaysQueue.reduce((a, b) => a + b) / delaysQueue.length).toInt();
}

int getMessagesLength() {
  return lastDurationStats['messagesQueueLength'];
}

void appendDelay(int delay) {
  delaysQueue.add(delay);
}

void setOutputMessagesLength(int messagesQueueLength) {
  lastDurationStats['messagesQueueLength'] = messagesQueueLength;
}

Future<void> statsTask() async {
  resetDuration();
  statsTaskRunning = true;
  while (statsTaskRunning) {
    await Future.delayed(const Duration(seconds: 5));
    lastDurationStats['delay'] = getDelay();
    statsEvent.emitEvent(jsonEncode({
      'eventType': 'stats',
      'data': {'events': messagesQueue, 'stats': lastDurationStats}
    }));
    logger.info('[Stats] $lastDurationStats');
    resetDuration();
  }
}

void stopStatsTask() {
  statsTaskRunning = false;
}
