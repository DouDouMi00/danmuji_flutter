// live.dart
import 'dart:convert';

import 'package:pinyin/pinyin.dart';

import 'package:danmuji_flutter/services/logger.dart';
import 'blivedm_open_live.dart';
import 'live.dart' show liveEvent;

class OpenMessageHandler {
  final OpenLiveDanmakuReceiver receiver = OpenLiveDanmakuReceiver();

  void setupEventHandlers() {
    // 获取弹幕信息 LIVE_OPEN_PLATFORM_DM
    // 获取礼物信息 LIVE_OPEN_PLATFORM_SEND_GIFT
    // 获取付费留言 LIVE_OPEN_PLATFORM_SUPER_CHAT
    // 付费留言下线  LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL
    // 付费大航海 LIVE_OPEN_PLATFORM_GUARD
    // 点赞信息 LIVE_OPEN_PLATFORM_LIKE 对单一用户最近2秒聚合发送一次点赞次数
    // 消息推送结束通知 LIVE_OPEN_PLATFORM_INTERACTION_END

    receiver.onDanmuCallback(handleOpenDanma);
    receiver.onGiftCallback(handleOpenGift);
    receiver.onSuperChatCallback(handleOpenSC);
    // receiver.onSuperChatDelCallback();
    receiver.onGuardBuyCallback(handleOpenGuardBuy);
    receiver.onLikeCallback(handleOpenLike);
    receiver.onInteractionEndCallback(handleOpenInteractionEnd);
  }

  Future<bool> run() async {
    setupEventHandlers();
    return await receiver.run();
  }

  void stop() {
    receiver.stop();
  }

  Map<int, String> guardLevelMapNameRaw = {0: "", 1: "总督", 2: "提督", 3: "舰长"};

  void handleOpenDanma(Map command) {
    // 处理弹幕逻辑
    Map data = command['data'];
    String openId = data['open_id'];
    String uface = data['uface'];

    String msg = data['msg'];
    String uname = data['uname'];
    int liveRoomGuardLevel = data['guard_level'];
    String liveRoomGuardLevelName = guardLevelMapNameRaw[liveRoomGuardLevel]!;

    bool isFansMedalBelongToLive = data['fans_medal_wearing_status'];
    int fansMedalLevel = data['fans_medal_level'];
    String fansMedalName = data['fans_medal_name'];

    bool isEmoji = data['dm_type'] == 1;

    logger.info(
        '[Danmu] [$liveRoomGuardLevelName] [$fansMedalName:$fansMedalLevel] $uname: $msg');
    liveEvent.emitEvent(jsonEncode({
      'eventType': 'danmu',
      'data': {
        'openId': openId,
        'uname': uname,
        'isFansMedalBelongToLive': isFansMedalBelongToLive,
        'fansMedalName': fansMedalName,
        'fansMedalLevel': fansMedalLevel,
        'liveRoomGuardLevelName': liveRoomGuardLevelName,
        'liveRoomGuardLevel': liveRoomGuardLevel,
        'msg': msg,
        'faceImg': uface,
        'isEmoji': isEmoji,
        'uid': 0,
        'authorType': 0,
        'authorTypeText': "",
        'fansMedalGuardLevelName': "",
        'fansMedalGuardLevel': 0,
        'richContent': [],
      }
    }));
  }

  void handleOpenGift(command) {
    // 处理礼物逻辑
    Map data = command['data'];
    String openId = data['open_id'];
    String uname = data['uname'];
    String unamePronunciation = PinyinHelper.getPinyin(
      uname,
      format: PinyinFormat.WITH_TONE_MARK,
    ); // 假设实现了pinyinConvert函数来处理拼音转换
    String giftName = data['gift_name'];
    int num = data['gift_num'];
    double price = data['paid'] ? data['price'] / 1000.00 : 0.00;
    String faceImg = data['uface'];

    logger.info(
        "[Gift] $uname $unamePronunciation bought ${price.toStringAsFixed(2)}元的$giftName x $num.");

    liveEvent.emitEvent(jsonEncode({
      'eventType': 'gift',
      'data': {
        'openId': openId,
        'uname': uname,
        'unamePronunciation': unamePronunciation,
        'price': price,
        'faceImg': faceImg,
        'giftName': giftName,
        'num': num,
        'uid': 0,
      }
    }));
  }

  void handleOpenSC(Map command) {
    // 处理醒目留言逻辑
    Map data = command['data'];
    String openId = data['open_id'];
    String uname = data['uname'];
    String unamePronunciation = PinyinHelper.getPinyin(
      uname,
      format: PinyinFormat.WITH_TONE_MARK,
    );
    double price = data['rmb'] / 1.00;
    String msg = data['message'];
    String faceImg = data['uface'];
    logger.info("[SC] $uname bought ${price.toStringAsFixed(2)}元SC: $msg");
    liveEvent.emitEvent(jsonEncode({
      'eventType': 'superChat',
      'data': {
        'openId': openId,
        'uname': uname,
        'unamePronunciation': unamePronunciation,
        'price': price,
        'msg': msg,
        'faceImg': faceImg,
        'uid': 0,
      }
    }));
  }

  void handleOpenGuardBuy(Map command) {
    // 处理购买守护逻辑
    Map data = command['data'];
    String openId = data['user_info']['open_id'];
    String uname = data['user_info']['uname'];
    String faceImg = data['user_info']['uface'];

    int num = data['guard_num'];
    String unit = data['guard_unit'];
    String unamePronunciation = PinyinHelper.getPinyin(
      uname,
      format: PinyinFormat.WITH_TONE_MARK,
    );
    int liveRoomGuardLevel = data['guard_level'];
    String giftName = guardLevelMapNameRaw[liveRoomGuardLevel]!;

    var title = '$uname 购买 $num $unit 的 $giftName';

    logger.info('[GuardBuy] $uname 购买 $num $unit 的 $giftName ');
    liveEvent.emitEvent(jsonEncode({
      'eventType': 'guardBuy',
      'data': {
        'openId': openId,
        'uname': uname,
        'unamePronunciation': unamePronunciation,
        'liveRoomGuardLevel': liveRoomGuardLevel,
        'faceImg': faceImg,
        'giftName': giftName,
        'num': num,
        'uint': unit,
        'title': title,
        'uid': 0,
        'newGuard': true,
      }
    }));
  }

  void handleOpenLike(Map command) {
    // 处理点赞逻辑
    Map data = command['data'];
    String openId = data['open_id'];
    String uname = data['uname'];
    logger.info("[Like] $uname liked the stream.");
    liveEvent.emitEvent(jsonEncode({
      'eventType': 'like',
      'data': {
        'openId': openId,
        'uname': uname,
        'uid': 0,
      }
    }));
  }

  void handleOpenInteractionEnd(Map command) {
    // 消息推送结束通知
    Map data = command['data'];
    int time = data['timestamp'];
    logger.info("[InteractionEnd] interaction end at $time");
    liveEvent.emitEvent(jsonEncode({
      'eventType': 'interactionEnd',
      'data': {
        'time': time,
      }
    }));
  }
}
