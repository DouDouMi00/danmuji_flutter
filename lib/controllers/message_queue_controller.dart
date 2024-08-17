import 'package:get/get.dart';

import '/services/tts.dart';

class MessageQueueController extends GetxController {
  // 创建一个RxList作为消息队列
  final messagesAll = <Map<String, dynamic>>[].obs;

  final messagesDanmu = <Map<String, dynamic>>[].obs;
  final messagesGift = <Map<String, dynamic>>[].obs;
  final messagesGuardBuy = <Map<String, dynamic>>[].obs;
  final messagesSuperChat = <Map<String, dynamic>>[].obs;

  // 'like' 'subscribe'  'welcome' 'warning'
  final messagesOther = <Map<String, dynamic>>[].obs;

  final messagesQueueLength = 0.obs;
  final delay = 0.obs;
  final filtrationEfficiencyDanmu = 0.0.obs;
  final filtrationEfficiencyGift = 0.0.obs;
  final filtrationEfficiencyWelcome = 0.0.obs;
  final filtrationEfficiencyLike = 0.0.obs;
  final filtrationEfficiencyGuardBuy = 0.0.obs;
  final filtrationEfficiencySubscribe = 0.0.obs;
  final filtrationEfficiencySuperChat = 0.0.obs;
  final filtrationEfficiencyWarning = 0.0.obs;

  late Function _sendMessageAll;
  late Function _sendMessageDanmu;
  late Function _sendMessageGift;
  late Function _sendMessageGuardBuy;
  late Function _sendMessageSuperChat;
  late Function _sendMessageOther;

  // 发送消息的方法
  void sendMessage(Map messages) async {
    Map<String, dynamic> lastDuration = messages["data"]["stats"];
    delay.value = lastDuration['delay'];
    messagesQueueLength.value = lastDuration['messagesQueueLength'];

    calculateFiltrationEfficiency(lastDuration, 'filteredDanmu', 'rawDanmu',
        (value) => filtrationEfficiencyDanmu.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredGift', 'rawGift',
        (value) => filtrationEfficiencyGift.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredWelcome', 'rawWelcome',
        (value) => filtrationEfficiencyWelcome.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredLike', 'rawLike',
        (value) => filtrationEfficiencyLike.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredGuardBuy',
        'rawGuardBuy', (value) => filtrationEfficiencyGuardBuy.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredSubscribe',
        'rawSubscribe', (value) => filtrationEfficiencySubscribe.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredSuperChat',
        'rawSuperChat', (value) => filtrationEfficiencySuperChat.value = value);
    calculateFiltrationEfficiency(lastDuration, 'filteredWarning', 'rawWarning',
        (value) => filtrationEfficiencyWarning.value = value);

    for (Map<String, dynamic> msg in messages["data"]["events"]) {
      messagesAll.add({'msg': messagesToText(msg), 'filterd': msg["filterd"]});
      _sendMessageAll();
      switch (msg['type']) {
        case 'danmu':
          messagesDanmu
              .add({'msg': messagesToText(msg), 'filterd': msg["filterd"]});
          _sendMessageDanmu();
        case 'gift':
          messagesGift
              .add({'msg': messagesToText(msg), 'filterd': msg["filterd"]});
          _sendMessageGift();
        case 'guardBuy':
          messagesGuardBuy
              .add({'msg': messagesToText(msg), 'filterd': msg["filterd"]});
          _sendMessageGuardBuy();
        case 'superChat':
          messagesSuperChat
              .add({'msg': messagesToText(msg), 'filterd': msg["filterd"]});
          _sendMessageSuperChat();
        default:
          messagesOther
              .add({'msg': messagesToText(msg), 'filterd': msg["filterd"]});
          _sendMessageOther();
      }
    }
  }

  void calculateFiltrationEfficiency(Map<String, dynamic> lastDuration,
      String filteredKey, String rawKey, double Function(double) setValue) {
    double filtered = (lastDuration[filteredKey] ?? 0).toDouble();
    double raw = (lastDuration[rawKey] ?? 0).toDouble();

    if (raw == 0) {
      setValue(0.0);
    } else {
      setValue(filtered / raw * 100);
    }
  }

  // 新增的回调方法
  void onMessageAllAdded(Function handler) {
    _sendMessageAll = handler;
  }

  void onMessageDanmuAdded(Function handler) {
    _sendMessageDanmu = handler;
  }

  void onMessageGiftAdded(Function handler) {
    _sendMessageGift = handler;
  }

  void onMessageGuardBuyAdded(Function handler) {
    _sendMessageGuardBuy = handler;
  }

  void onMessageSuperChatAdded(Function handler) {
    _sendMessageSuperChat = handler;
  }

  void onMessageOtherAdded(Function handler) {
    _sendMessageOther = handler;
  }

  void clearMessages() {
    messagesAll.clear();
    messagesQueueLength.value = 0;
    delay.value = 0;
    filtrationEfficiencyDanmu.value = 0.0;
    filtrationEfficiencyGift.value = 0.0;
    filtrationEfficiencyWelcome.value = 0.0;
    filtrationEfficiencyLike.value = 0.0;
    filtrationEfficiencyGuardBuy.value = 0.0;
    filtrationEfficiencySubscribe.value = 0.0;
    filtrationEfficiencySuperChat.value = 0.0;
    filtrationEfficiencyWarning.value = 0.0;
  }
}
