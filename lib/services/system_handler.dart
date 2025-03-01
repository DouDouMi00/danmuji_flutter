import 'dart:async';
import 'dart:convert';

import 'package:danmuji_flutter/pages/ControlPage/control_page.dart'
    show messageController;
import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/services/logger.dart';
import 'package:danmuji_flutter/services/messages_handler.dart';
import 'package:get/get.dart';

import 'stats.dart';

// 保存 StreamSubscription 对象
StreamSubscription? statsEventSubscription;

void setupStatsEventListeners() {
  // 创建并保存 StreamSubscription 对象
  statsEventSubscription = statsEvent.onEvent.listen((eventData) async {
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
      case 'stats':
        statsHandler(data);
        break;

      default:
        logger.info('Unhandled event type: $eventType');
        break;
    }
  });
}

DateTime lastAlertTime = DateTime.fromMillisecondsSinceEpoch(0);

void statsHandler(stats) {
  messageController.sendMessage({'type': 'stats', 'data': stats});
  final config = Get.find<ConfigService>()
      .configRx
      .value
      .dynamicConfig
      .dynamicSystem
      .alertWhenMessagesQueueLonger;
  if (config.enable) {
    if (DateTime.now().difference(lastAlertTime).inSeconds > config.interval &&
        getMessagesLength() > config.threshold) {
      final delayStr = stats["stats"]["delay"].toString();
      final messagesQueueLengthStr =
          stats["stats"]["messagesQueueLength"].toString();
      messagesQueueAppendAtStart({
        "type": "system",
        "time": DateTime.now()
            .subtract(Duration(seconds: stats["stats"]["delay"]))
            .millisecondsSinceEpoch,
        "msg": "当前延迟较高为$delayStr秒 积压弹幕数为$messagesQueueLengthStr"
      });
      lastAlertTime = DateTime.now();
    }
  } else {
    lastAlertTime = DateTime.fromMillisecondsSinceEpoch(0);
  }
}

// 新增方法用于取消监听
void cancelStatsEventListeners() {
  statsEventSubscription?.cancel();
}
