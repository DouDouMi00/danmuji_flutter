import 'dart:async';
import 'dart:convert';

import '/services/filter.dart';
import '/services/logger.dart';
import '/services/stats.dart';
import 'live.dart' show liveEvent;

List<Map<String, dynamic>> messagesQueue = [];
List<Map<String, dynamic>> haveReadMessages = [];
StreamSubscription? liveEventSubscription;

Map<String, dynamic>? popMessagesQueue() {
  if (messagesQueue.isEmpty) {
    return null;
  }
  var data = messagesQueue.removeAt(0);
  setOutputMessagesLength(messagesQueue.length);
  haveReadMessages.add(data);
  return data;
}

List<Map<String, dynamic>> getHaveReadMessages() {
  return haveReadMessages;
}

void messagesQueueAppend(dynamic data) {
  messagesQueue.add(data);
  setOutputMessagesLength(messagesQueue.length);
}

void messagesQueueAppendAtStart(dynamic data) {
  messagesQueue.insert(0, data);
  setOutputMessagesLength(messagesQueue.length);
}

void setupLiveEventListeners() {
  liveEventSubscription = liveEvent.onEvent.listen((eventData) async {
    Map<String, dynamic> eventDataMap;

    try {
      eventDataMap = jsonDecode(eventData);
    } on FormatException catch (_) {
      logger.info('Error decoding event data: $eventData');
      return;
    }

    String eventType = eventDataMap['eventType'] ?? '';
    dynamic data = eventDataMap['data'];

    switch (eventType) {
      case 'danmu':
        onDanmu(data);
        break;
      case 'gift':
        onGift(data);
        break;
      case 'guardBuy':
        onGuardBuy(data);
        break;
      case 'like':
        onLike(data);
        break;
      case 'welcome':
        onWelcome(data);
        break;
      case 'subscribe':
        onSubscribe(data);
        break;
      case 'superChat':
        onSuperChat(data);
        break;
      case 'warning':
        onWarning(data);
        break;
      case 'interactionEnd':
        onInteractionEnd(data);
        break;

      default:
        logger.info('Unhandled event type: $eventType');
        break;
    }
  });
}

void cancelLiveEventListeners() {
  liveEventSubscription?.cancel();
}

void onDanmu(dynamic command) {
  if (filterDanmu(
      command['uid'],
      openId: command['openId'],
      command['uname'],
      command['isFansMedalBelongToLive'],
      command['fansMedalLevel'],
      command['fansMedalGuardLevel'],
      command['msg'],
      command['isEmoji'])) {
    appendDanmuFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      'openId': command['openId'],
      "uname": command['uname'],
      "msg": command['msg'],
      "richContent": command['richContent'],
      "isEmoji": command['isEmoji'],
      "fansMedalName": command['fansMedalName'],
      "fansMedalLevel": command['fansMedalLevel'],
      "fansMedalGuardLevelName": command['fansMedalGuardLevelName'],
      "fansMedalGuardLevel": command['fansMedalGuardLevel'],
      "liveRoomGuardLevelName": command['liveRoomGuardLevelName'],
      "liveRoomGuardLevel": command['liveRoomGuardLevel'],
      "faceImg": command['faceImg'],
      "authorType": command['authorType'],
      "authorTypeText": command['authorTypeText'],
    });
    messagesQueueAppend({
      "type": "danmu",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      'openId': command['openId'],
      "uname": command['uname'],
      "msg": command['msg'],
      "richContent": command['richContent'],
      "isEmoji": command['isEmoji'],
      "fansMedalName": command['fansMedalName'],
      "fansMedalLevel": command['fansMedalLevel'],
      "fansMedalGuardLevelName": command['fansMedalGuardLevelName'],
      "fansMedalGuardLevel": command['fansMedalGuardLevel'],
      "liveRoomGuardLevelName": command['liveRoomGuardLevelName'],
      "liveRoomGuardLevel": command['liveRoomGuardLevel'],
      "faceImg": command['faceImg'],
      "authorType": command['authorType'],
      "authorTypeText": command['authorTypeText'],
    });
  } else {
    appendDanmuFilteredStats(true, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      'openId': command['openId'],
      "uname": command['uname'],
      "msg": command['msg'],
      "richContent": command['richContent'],
      "isEmoji": command['isEmoji'],
      "fansMedalName": command['fansMedalName'],
      "fansMedalLevel": command['fansMedalLevel'],
      "fansMedalGuardLevelName": command['fansMedalGuardLevelName'],
      "fansMedalGuardLevel": command['fansMedalGuardLevel'],
      "liveRoomGuardLevelName": command['liveRoomGuardLevelName'],
      "liveRoomGuardLevel": command['liveRoomGuardLevel'],
      "faceImg": command['faceImg'],
      "authorType": command['authorType'],
      "authorTypeText": command['authorTypeText'],
    });
  }
}

void onGift(dynamic command) async {
  void deduplicateCallback(Map<String, dynamic> userInfo, String giftName) {
    Map<String, dynamic> giftInfo = userInfo['gifts'][giftName];
    messagesQueueAppend({
      "type": "gift",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": userInfo["uid"],
      "uname": userInfo["uname"],
      "giftName": giftName,
      "num": giftInfo["count"],
    });
  }

  bool? result = await filterGift(
      command['uid'],
      openId: command['openId'],
      command['uname'],
      command['price'],
      command['giftName'],
      command['num'],
      deduplicateCallback);
  if (result == true) {
    appendGiftFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
      "unamePronunciation": command['unamePronunciation'],
      "price": command['price'],
      "faceImg": command['faceImg'],
      "giftName": command['giftName'],
      "num": command['num'],
    });
    messagesQueueAppend({
      "type": "gift",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
      "giftName": command['giftName'],
      "num": command['num'],
    });
  } else {
    appendGiftFilteredStats((result != null), args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
      "unamePronunciation": command['unamePronunciation'],
      "price": command['price'],
      "faceImg": command['faceImg'],
      "giftName": command['giftName'],
      "num": command['num'],
    });
  }
}

void onGuardBuy(dynamic command) {
  if (filterGuardBuy(command['uid'], command['uname'], command['newGuard'],
      command['giftName'], command['num'])) {
    appendGuardBuyFilteredStats(false, args: {
      "uid": command['uid'],
      "uname": command['uname'],
      "unamePronunciation": command['unamePronunciation'],
      "time": DateTime.now().millisecondsSinceEpoch,
      "liveRoomGuardLevel": command['liveRoomGuardLevel'],
      "newGuard": command['newGuard'],
      "faceImg": command['faceImg'],
      "giftName": command['giftName'],
      "num": command['num'],
      "unit": command['unit'],
      "title": command['title'],
    });
    messagesQueueAppend({
      "type": "guardBuyOpen",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
      "newGuard": command['newGuard'],
      "giftName": command['giftName'],
      "num": command['num'],
      "unit": command['unit'],
    });
  } else {
    appendGuardBuyFilteredStats(true, args: {
      "uid": command['uid'],
      "uname": command['uname'],
      "unamePronunciation": command['unamePronunciation'],
      "time": DateTime.now().millisecondsSinceEpoch,
      "liveRoomGuardLevel": command['liveRoomGuardLevel'],
      "newGuard": command['newGuard'],
      "faceImg": command['faceImg'],
      "giftName": command['giftName'],
      "num": command['num'],
      "unit": command['unit'],
      "title": command['title'],
    });
  }
}

void onLike(dynamic command) {
  if (filterLike(command['uid'], openId: command['openId'], command['uname'])) {
    appendLikeFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
    messagesQueueAppend({
      "type": "like",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
  } else {
    appendLikeFilteredStats(true, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
  }
}

void onSuperChat(dynamic command) {
  if (filterSuperChat(
      command['uid'], command['uname'], command['price'], command['msg'])) {
    appendSuperChatFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "faceImg": command['faceImg'],
      "uname": command['uname'],
      "unamePronunciation": command['unamePronunciation'],
      "price": command['price'],
      "msg": command['msg'],
    });
    messagesQueueAppend({
      "type": "superChat",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
      "price": command['price'],
      "msg": command['msg'],
    });
  } else {
    appendSuperChatFilteredStats(true, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "faceImg": command['faceImg'],
      "uname": command['uname'],
      "unamePronunciation": command['unamePronunciation'],
      "price": command['price'],
      "msg": command['msg'],
    });
  }
}

void onSubscribe(dynamic command) {
  if (filterSubscribe(
      command['uid'],
      command['uname'],
      command['isFansMedalBelongToLive'],
      command['fansMedalLevel'],
      command['fansMedalGuardLevel'])) {
    appendSubscribeFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
    messagesQueueAppend({
      "type": "subscribe",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
  } else {
    appendSubscribeFilteredStats(true, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
  }
}

void onWelcome(dynamic command) {
  if (filterWelcome(
      command['uid'],
      command['uname'],
      command['isFansMedalBelongToLive'],
      command['fansMedalLevel'],
      command['fansMedalGuardLevel'])) {
    appendWelcomeFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
    messagesQueueAppend({
      "type": "welcome",
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
  } else {
    appendWelcomeFilteredStats(true, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "uid": command['uid'],
      "uname": command['uname'],
    });
  }
}

void onWarning(dynamic command) {
  if (filterWarning(command['msg'], command['isCutOff'])) {
    appendWarningFilteredStats(false, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "msg": command['msg'],
      "isCutOff": command['isCutOff'],
    });
    messagesQueueAppend({
      "type": "warning",
      "time": DateTime.now().millisecondsSinceEpoch,
      "msg": command['msg'],
      "isCutOff": command['isCutOff'],
    });
  } else {
    appendWarningFilteredStats(true, args: {
      "time": DateTime.now().millisecondsSinceEpoch,
      "msg": command['msg'],
      "isCutOff": command['isCutOff'],
    });
  }
}

void onInteractionEnd(dynamic command) {
  int timestampInSeconds = command['time'];
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(timestampInSeconds * 1000);
  messagesQueueAppend({
    "type": "system",
    "time": DateTime.now().millisecondsSinceEpoch,
    "msg": "消息推送结束通知，结束时间为：${dateTime.toString()}"
  });
}

Future<void> markAllMessagesInvalid() async {
  messagesQueue = [
    {
      "type": "system",
      "time": DateTime.now().millisecondsSinceEpoch,
      "msg": "已清空弹幕列表"
    }
  ];
  setOutputMessagesLength(messagesQueue.length);
}

void clearMessagesQueue() {
  messagesQueue.clear();
  haveReadMessages.clear();
  setOutputMessagesLength(messagesQueue.length);
}
