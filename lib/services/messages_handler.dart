import 'dart:convert';
import 'live.dart' show emitter;
import '/services/filter.dart';
import 'dart:async';
import '/services/logger.dart';

void setupEventListeners() {
  emitter.onEvent.listen((eventData) async {
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

      default:
        logger.info('Unhandled event type: $eventType');
        break;
    }
  });
}

List<dynamic> messagesQueue = [];
List<dynamic> haveReadMessages = [];

dynamic popMessagesQueue() {
  if (messagesQueue.isEmpty) {
    return null;
  }
  var data = messagesQueue.removeAt(0);
  haveReadMessages.add(data);
  return data;
}

List<dynamic> getHaveReadMessages() {
  return haveReadMessages;
}

void messagesQueueAppend(dynamic data) {
  messagesQueue.add(data);
}

void messagesQueueAppendAtStart(dynamic data) {
  messagesQueue.insert(0, data);
}

void onDanmu(dynamic command) {
  if (filterDanmu(
      command['uid'],
      command['uname'],
      command['isFansMedalBelongToLive'],
      command['fansMedalLevel'],
      command['fansMedalGuardLevel'],
      command['msg'],
      command['isEmoji'])) {
    messagesQueueAppend({
      "type": "danmu",
      "time": DateTime.now(),
      "uid": command['uid'],
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
      "time": DateTime.now().millisecondsSinceEpoch.toDouble(),
      "uid": userInfo["uid"],
      "uname": userInfo["uname"],
      "giftName": giftName,
      "num": giftInfo["count"],
    });
  }

  bool? result = await filterGift(
      command['uid'],
      command['uname'],
      command['price'],
      command['giftName'],
      command['num'],
      deduplicateCallback);
  if (result == true) {
    messagesQueueAppend({
      "type": "gift",
      "time": DateTime.now(),
      "uid": command['uid'],
      "uname": command['uname'],
      "giftName": command['giftName'],
      "num": command['num'],
    });
  }
}

void onGuardBuy(dynamic command) {
  if (filterGuardBuy(command['uid'], command['uname'], command['newGuard'],
      command['giftName'], command['num'])) {
    messagesQueueAppend({
      "type": "guardBuy",
      "time": DateTime.now(),
      "uid": command['uid'],
      "uname": command['uname'],
      "newGuard": command['newGuard'],
      "giftName": command['giftName'],
      "num": command['num'],
    });
  }
}

void onLike(dynamic command) {
  if (filterLike(command['uid'], command['uname'])) {
    messagesQueueAppend({
      "type": "like",
      "time": DateTime.now(),
      "uid": command['uid'],
      "uname": command['uname'],
    });
  }
}

void onSuperChat(dynamic command) {
  if (filterSuperChat(
      command['uid'], command['uname'], command['price'], command['msg'])) {
    messagesQueueAppend({
      "type": "superChat",
      "time": DateTime.now(),
      "uid": command['uid'],
      "uname": command['uname'],
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
    messagesQueueAppend({
      "type": "subscribe",
      "time": DateTime.now(),
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
    messagesQueueAppend({
      "type": "welcome",
      "time": DateTime.now(),
      "uid": command['uid'],
      "uname": command['uname'],
    });
  }
}

void onWarning(dynamic command) {
  if (filterWarning(command['msg'], command['isCutOff'])) {
    messagesQueueAppend({
      "type": "warning",
      "time": DateTime.now(),
      "msg": command['msg'],
      "isCutOff": command['isCutOff'],
    });
  }
}

Future<void> markAllMessagesInvalid() async {
  messagesQueue = [
    {"type": "system", "time": DateTime.now(), "msg": "已清空弹幕列表"}
  ];
}
