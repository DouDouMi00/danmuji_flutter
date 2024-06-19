// live.dart

import 'dart:convert';
import '../services/blivedm.dart';
import '../services/config.dart';
import '../services/tool.dart';
import 'package:pinyin/pinyin.dart';
import 'event_emitter.dart';

EventEmitter emitter = EventEmitter();

class MessageHandler {
  final DanmakuReceiver receiver;

  MessageHandler(this.receiver);

  void setupEventHandlers() {
    // **BaseHandler._CMD_CALLBACK_DICT, (基础处理器的命令回调字典)
    // "DANMU_MSG": onDanmuCallback,    // 弹幕消息：弹幕回调函数
    // "SEND_GIFT": onGiftCallback,     // 赠送礼物：礼物回调函数
    // "USER_TOAST_MSG": onGuardBuyCallback, // 用户提示消息：购买守护回调函数
    // "SUPER_CHAT_MESSAGE": onSCCallback,   // 醒目留言：醒目留言回调函数
    // "INTERACT_WORD": onInteractWordCallback, // 互动词：互动词回调函数
    // "LIKE_INFO_V3_CLICK": onLikeCallback,  // 点赞信息V3点击：点赞回调函数
    // "WARNING": onWarning,                // 警告：警告回调函数
    // "CUT_OFF": onCutOff,                 // 切断连接：切断回调函数

    receiver.onDanmuCallback(_handleDanmaku);
    receiver.onGiftCallback(_handleGift);
    receiver.onGuardBuyCallback(_handleGuardBuy);
    receiver.onSCCallback(_handleSC);
    receiver.onInteractWordCallback(_handleInteractWord);
    receiver.onLikeCallback(_handleLike);
    receiver.onWarning(_handleWarning);
    receiver.onCutOff(_handleCutOff);
  }

  Map guardLevelMap = {0: 0, 1: 3, 2: 2, 3: 1};

  Map guardLevelMap_name = {0: "", 3: "总督", 2: "提督", 1: "舰长"};
  Map guardLevelMap_name_raw = {0: "", 1: "总督", 2: "提督", 3: "舰长"};
  Map author_type_map = {
    0: "",
    1: "member", //舰队
    2: "moderator", // 房管
    3: "owner", //主播
  };

  void _handleDanmaku(command) {
    // 处理弹幕逻辑
    var uid = command['info'][2][0];
    var faceImg = command['info'][0][15]['user']['base']['face'];
    var msg = command['info'][1];
    var uname = command['info'][2][1];
    var isadmin = command['info'][2][2] == 1;
    var liveRoomGuardLevel = command['info'][7];
    var liveRoomGuardLevelName = guardLevelMap_name_raw[liveRoomGuardLevel];

    bool isFansMedalBelongToLive;
    var fansMedalLevel;
    var fansMedalName;
    var fansMedalGuardLevel;
    var fansMedalGuardLevelName;
    int authorType;
    var authorTypeText;
    bool isEmoji;

    if (command['info'][3].length != 0) {
      isFansMedalBelongToLive =
          command['info'][3][3] == getConfigMap()['engine']['bili']['liveID'];
      fansMedalLevel = command['info'][3][0];
      fansMedalName = command['info'][3][1];
      fansMedalGuardLevel = guardLevelMap[command['info'][3][10]];
      fansMedalGuardLevelName = guardLevelMap_name[fansMedalGuardLevel];

      if (uid == receiver.anchorUid) {
        authorType = 3; // 主播
      } else if (isadmin) {
        authorType = 2; // 房管
      } else if (liveRoomGuardLevel != 0) {
        // 3总督，2提督，1舰长
        authorType = 1; // 舰队
      } else {
        authorType = 0;
      }
      authorTypeText = author_type_map[authorType];
    } else {
      isFansMedalBelongToLive = false;
      fansMedalLevel = 0;
      fansMedalName = "";
      fansMedalGuardLevel = 0;
      fansMedalGuardLevelName = "";
      authorType = 0;
      authorTypeText = "";
    }
    isEmoji = command['info'][0][12] == 1 || isStringAllEmojis(msg);
    print(
        '[Danmu] [$authorTypeText] [$liveRoomGuardLevelName] [[$fansMedalGuardLevelName]$fansMedalName:$fansMedalLevel] $uname: $msg');
    emitter.emitEvent(jsonEncode({
      'eventType': 'danmu',
      'data': {
        'uid': uid,
        'uname': uname,
        'isFansMedalBelongToLive': isFansMedalBelongToLive,
        'authorType': authorType,
        'authorTypeText': authorTypeText,
        'fansMedalName': fansMedalName,
        'fansMedalLevel': fansMedalLevel,
        'fansMedalGuardLevelName': fansMedalGuardLevelName,
        'fansMedalGuardLevel': fansMedalGuardLevel,
        'liveRoomGuardLevelName': liveRoomGuardLevelName,
        'liveRoomGuardLevel': liveRoomGuardLevel,
        'msg': msg,
        'faceImg': faceImg,
        'isEmoji': isEmoji,
      }
    }));
  }

  void _handleGift(command) {
    // 处理礼物逻辑
    var uid = command['data']['uid'];
    var uname = command['data']['uname'];
    var unamePronunciation =
        PinyinHelper.getShortPinyin(uname); // 假设实现了pinyinConvert函数来处理拼音转换
    var giftName = command['data']['giftName'];
    var num = command['data']['num'];
    var price = command['data']['price'] / 1000.0;
    price = command['data']['coin_type'] == 'gold' ? price : 0.0;
    var faceImg = command['data']['face'];

    print(
        "[Gift] $uname $unamePronunciation bought ${price.toStringAsFixed(2)}元的$giftName x $num.");

    // liveEvent.emit(
    // "gift", uid, uname, unamePronunciation, price, faceImg, giftName, num);
    emitter.emitEvent(jsonEncode({
      'eventType': 'gift',
      'data': {
        'uid': uid,
        'uname': uname,
        'unamePronunciation': unamePronunciation,
        'price': price,
        'faceImg': faceImg,
        'giftName': giftName,
        'num': num,
      }
    }));
  }

  void _handleGuardBuy(command) {
    // 处理购买守护逻辑
    if (!command['data'].containsKey('role_name') ||
        !['总督', '提督', '舰长'].contains(command['data']['role_name'])) {
      return;
    }

    var uid = command['data']['uid'];
    var num = command['data']['num'];
    var uname = command['data']['username'];
    var unamePronunciation = PinyinHelper.getShortPinyin(uname);
    var giftName = command['data']['role_name'];
    var liveRoomGuardLevel = command['data']['guard_level'];
    var newGuard = command['data']['toast_msg'].endsWith('第1天');

    var title = '$uname 购买 $num 个月的 $giftName ';

    var faceImg = 'static.hdslb.com/images/member/noface.gif';

    print(
        '[GuardBuy] $uname bought ${newGuard ? 'New ' : ''}$giftName x $num.');

    // liveEvent.emit(
    //   'guardBuy',
    //   uid,
    //   uname,
    //   unamePronunciation,
    //   liveRoomGuardLevel,
    //   newGuard,
    //   faceImg,
    //   giftName,
    //   num,
    //   title,
    // );
    emitter.emitEvent(jsonEncode({
      'eventType': 'guardBuy',
      'data': {
        'uid': uid,
        'uname': uname,
        'unamePronunciation': unamePronunciation,
        'liveRoomGuardLevel': liveRoomGuardLevel,
        'newGuard': newGuard,
        'faceImg': faceImg,
        'giftName': giftName,
        'num': num,
        'title': title,
      }
    }));
  }

  void _handleSC(command) {
    // 处理醒目留言逻辑
    var uid = command["data"]["uid"];
    var uname = command["data"]["user_info"]["uname"];
    var unamePronunciation = PinyinHelper.getShortPinyin(uname);
    var price = command["data"]["price"];
    var msg = command["data"]["message"];
    var faceImg = command["data"]["user_info"]["face"];
    // timeLog(f"[SuperChat] {uname} bought {price}元的SC: {msg}");
    print("[SC] $uname bought ${price.toStringAsFixed(2)}元SC: $msg");
    // liveEvent.emit("superChat", uid, faceImg, uname, unamePronunciation, price, msg);
    emitter.emitEvent(jsonEncode({
      'eventType': 'superChat',
      'data': {
        'uid': uid,
        'uname': uname,
        'unamePronunciation': unamePronunciation,
        'price': price,
        'msg': msg,
        'faceImg': faceImg,
      }
    }));
  }

  void _handleInteractWord(command) {
    // 处理互动词逻辑
    if (command['data']['roomid'] !=
        getConfigMap()['engine']['bili']['liveID']) {
      return;
    }
    var uid = command['data']['uid'];
    var uname = command['data']['uname'];
    var fansMedalData = command['data']['fans_medal'];
    var isFansMedalBelongToLive = false;
    var fansMedalLevel = 0;
    var fansMedalGuardLevel = 0;

    if (fansMedalData != null) {
      isFansMedalBelongToLive = fansMedalData['anchor_roomid'] ==
          getConfigMap()['engine']['bili']['liveID'];
      fansMedalLevel = fansMedalData['medal_level'];
      fansMedalGuardLevel = guardLevelMap[fansMedalData['guard_level']];
    }

    var isSubscribe = command['data']['msg_type'] == 2;
// timeLog("[Interact] ${uname} ${isSubscribe ? 'subscribe' : 'enter'} the stream.");
    print(
        "[Interact] $uname ${isSubscribe ? 'subscribe' : 'enter'} the stream.");

// if (isSubscribe) {
//   liveEvent.emit(
//     "subscribe",
//     uid,
//     uname,
//     isFansMedalBelongToLive,
//     fansMedalLevel,
//     fansMedalGuardLevel,
//   );
// } else {
//   liveEvent.emit(
//     "welcome",
//     uid,
//     uname,
//     isFansMedalBelongToLive,
//     fansMedalLevel,
//     fansMedalGuardLevel,
//   );
// }
    if (isSubscribe) {
      emitter.emitEvent(jsonEncode({
        'eventType': 'subscribe',
        'data': {
          'uid': uid,
          'uname': uname,
          'isFansMedalBelongToLive': isFansMedalBelongToLive,
          'fansMedalLevel': fansMedalLevel,
          'fansMedalGuardLevel': fansMedalGuardLevel,
        }
      }));
    } else {
      emitter.emitEvent(jsonEncode({
        'eventType': 'welcome',
        'data': {
          'uid': uid,
          'uname': uname,
          'isFansMedalBelongToLive': isFansMedalBelongToLive,
          'fansMedalLevel': fansMedalLevel,
          'fansMedalGuardLevel': fansMedalGuardLevel,
        }
      }));
    }
  }

  void _handleLike(command) {
    // 处理点赞逻辑
    var uid = command["data"]["uid"];
    var uname = command["data"]["uname"];
    // timeLog(f"[Like] {uname} liked the stream.");
    print("[Like] $uname liked the stream.");
    // liveEvent.emit("like", uid, uname);
    emitter.emitEvent(jsonEncode({
      'eventType': 'like',
      'data': {
        'uid': uid,
        'uname': uname,
      }
    }));
  }

  void _handleWarning(command) {
    // 处理警告逻辑
    var msg = command['msg'];
    // timeLog(f"[Warning] {msg}");
    print("[Warning] $msg");
    // liveEvent.emit("warning", msg, False);
    emitter.emitEvent(jsonEncode({
      'eventType': 'warning',
      'data': {
        'msg': msg,
        'bool': false,
      }
    }));
  }

  void _handleCutOff(command) {
    // 处理切断连接逻辑
    print(command);
    var msg = command['msg'];
    //       timeLog(f"[Warning] Cut Off, {msg}");
    print("Cut Off, $msg");
    //       liveEvent.emit("warning", msg, True);
    // }
    emitter.emitEvent(jsonEncode({
      'eventType': 'warning',
      'data': {
        'msg': msg,
        'bool': true,
      }
    }));
  }
}
