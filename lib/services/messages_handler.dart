import 'dart:convert';
import 'live.dart' show emitter;
import '../services/filter.dart';
import 'dart:async';

void setupEventListeners() {
  emitter.onEvent.listen((eventData) async {
    Map<String, dynamic> eventDataMap;

    try {
      eventDataMap = jsonDecode(eventData);
    } on FormatException catch (_) {
      print('Error decoding event data: $eventData');
      return;
    }

    String eventType = eventDataMap['eventType'] ?? '';
    dynamic data = eventDataMap['data'];

    switch (eventType) {
      case 'danmu':
        onDanmu(data);
        break;
      default:
        print('Unhandled event type: $eventType');
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
  // setOutputMessagesLength(messagesQueue.length);
  haveReadMessages.add(data);
  return data;
}

List<dynamic> getHaveReadMessages() {
  return haveReadMessages;
}

void messagesQueueAppend(dynamic data) {
  messagesQueue.add(data);
  // setOutputMessagesLength(messagesQueue.length);
}

void messagesQueueAppendAtStart(dynamic data) {
  messagesQueue.insert(0, data);
  // setOutputMessagesLength(messagesQueue.length);
}

void onDanmu(dynamic command) {
  //   'data': {
  //   'uid': uid,
  //   'uname': uname,
  //   'isFansMedalBelongToLive': isFansMedalBelongToLive,
  //   'authorType': authorType,
  //   'authorTypeText': authorTypeText,
  //   'fansMedalName': fansMedalName,
  //   'fansMedalLevel': fansMedalLevel,
  //   'fansMedalGuardLevelName': fansMedalGuardLevelName,
  //   'fansMedalGuardLevel': fansMedalGuardLevel,
  //   'liveRoomGuardLevelName': liveRoomGuardLevelName,
  //   'liveRoomGuardLevel': liveRoomGuardLevel,
  //   'msg': msg,
  //   'faceImg': faceImg,
  //   'isEmoji': isEmoji,
  // }
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
      "time": DateTime.now().millisecondsSinceEpoch,
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


Future<void> markAllMessagesInvalid() async {
  messagesQueue = [
    {"type": "system", "time": DateTime.now().millisecondsSinceEpoch ~/ 1000, "msg": "已清空弹幕列表"}
  ];
  // setOutputMessagesLength(messagesQueue.length);
}