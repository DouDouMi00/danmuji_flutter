import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/services/logger.dart';
import 'package:danmuji_flutter/services/messages_handler.dart';
import 'package:danmuji_flutter/services/open_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initConfig(test: true);

  final handler = OpenMessageHandler();
  final capturedLogs = <String>[];
  void handleLogRecord(LogRecord record) {
    capturedLogs.add(record.message);
  }

  logger.onRecord.listen(handleLogRecord);

  group('open live ...', () {
    test('OpenDanma ', () {
      setupLiveEventListeners();
      Map danmuData = {
        "cmd": "LIVE_OPEN_PLATFORM_DM",
        "data": {
          "room_id": 1, //弹幕接收的直播间
          "uid": 0, //用户UID(已废弃，固定为0)
          "open_id": "39b8fedb-60a5-4e29-ac75-b16955f7e632", //用户唯一标识
          "uname": "测试用户", //用户昵称
          "msg": "测试弹幕", //弹幕内容
          "msg_id": "", //消息唯一id
          "fans_medal_level": 0, //对应房间勋章信息
          "fans_medal_name": "粉丝勋章名",
          "fans_medal_wearing_status": true, //该房间粉丝勋章佩戴情况
          "guard_level": 0, //对应房间大航海 1总督 2提督 3舰长
          "timestamp": 0, //弹幕发送时间秒级时间戳
          "uface": "", //用户头像
          "emoji_img_url": "", //表情包图片地址
          "dm_type": 0, //弹幕类型 0：普通弹幕 1：表情包弹幕
        }
      };

      handler.handleOpenDanma(danmuData);
      expect(capturedLogs, contains('[Danmu] [] [粉丝勋章名:0] 测试用户: 测试弹幕'));
      capturedLogs.clear();
    });
    test('OpenGift ', () {
      setupLiveEventListeners();
      Map giftData = {
        "cmd": "LIVE_OPEN_PLATFORM_SEND_GIFT",
        "data": {
          "room_id": 1, //直播间(演播厅模式则为演播厅直播间,非演播厅模式则为收礼直播间)
          "uid": 0, //用户UID(已废弃，固定为0)
          "open_id": "39b8fedb-60a5-4e29-ac75-b16955f7e632", //用户唯一标识
          "uname": "", //送礼用户昵称
          "uface": "", //送礼用户头像
          "gift_id": 0, //道具id(盲盒:爆出道具id)
          "gift_name": "", //道具名(盲盒:爆出道具名)
          "gift_num": 0, //赠送道具数量
          "price": 0, //礼物单价(1000 = 1元 = 10电池),盲盒:爆出道具的价值
          "paid": false, //是否是付费道具
          "fans_medal_level": 0, //实际收礼人的勋章信息
          "fans_medal_name": "粉丝勋章名", //粉丝勋章名
          "fans_medal_wearing_status": true, //该房间粉丝勋章佩戴情况
          "guard_level": 0, //room_id对应的大航海等级
          "timestamp": 0, //收礼时间秒级时间戳
          "msg_id": "", //消息唯一id
          "anchor_info": {
            "uid": 0,
            //收礼主播UID(即将废弃)
            "open_id": "39b8fedb-60a5-4e29-ac75-b16955f7e632",
            //主播唯一标识(2024-03-11后上线)
            "uname": "",
            //收礼主播昵称
            "uface":
                "http://i0.hdslb.com/bfs/face/4add3acfc930fcd07d06ea5e10a3a377314141c2.jpg"
            //收礼主播头像
          },
          "gift_icon": "http://i1.hdslb.com/dksldksldksld.jpg", //道具icon  （新增）
          "combo_gift": true, //是否是combo道具
          "combo_info": {
            //ex：连击次数100，每个连击是批量送5个 既  5 * 100
            "combo_base_num": 5, //每次连击赠送的道具数量
            "combo_count": 100, //连击次数
            "combo_id": "xxxxxx", //连击id
            "combo_timeout": 3, //连击有效期秒
          }
        }
      };

      handler.handleOpenGift(giftData);
      expect(capturedLogs, contains('[Gift]   bought 0.00元的 x 0.'));
      capturedLogs.clear();
    });

    test('OpenSC ', () {
      setupLiveEventListeners();
      Map scData = {
        "cmd": "LIVE_OPEN_PLATFORM_SUPER_CHAT",
        "data": {
          "room_id": 1, //直播间id
          "uid": 0, //购买用户UID(已废弃，固定为0)
          "open_id": "39b8fedb-60a5-4e29-ac75-b16955f7e632", //购买用户唯一标识
          "uname": "", //购买的用户昵称
          "uface": "", //购买用户头像
          "message_id": 0, //留言id(风控场景下撤回留言需要)
          "message": "", //留言内容
          "msg_id": "", //消息唯一id
          "rmb": 0, //支付金额(元)
          "timestamp": 0, //赠送时间秒级
          "start_time": 0, //生效开始时间
          "end_time": 0, //生效结束时间
          "guard_level": 2, //对应房间大航海登记    (新增)
          "fans_medal_level": 26, //对应房间勋章信息  (新增)
          "fans_medal_name": "aw4ifC", //对应房间勋章名字  (新增)
          "fans_medal_wearing_status": true //该房间粉丝勋章佩戴情况   (新增)
        }
      };

      handler.handleOpenSC(scData);
      expect(capturedLogs, contains('[SC]  bought 0.00元SC: '));
      capturedLogs.clear();
    });
    test('OpenGuardBuy ', () {
      setupLiveEventListeners();
      Map guardBuyData = {
        "cmd": "LIVE_OPEN_PLATFORM_GUARD",
        "data": {
          "user_info": {
            "uid": 0,
            //用户UID(已废弃，固定为0)
            "open_id": "39b8fedb-60a5-4e29-ac75-b16955f7e632",
            //用户唯一标识
            "uname": "",
            //用户昵称
            "uface":
                "http://i0.hdslb.com/bfs/face/4add3acfc930fcd07d06ea5e10a3a377314141c2.jpg"
            //用户头像
          },
          "guard_level": 3, //对应的大航海等级 1总督 2提督 3舰长
          "guard_num": 1,
          "guard_unit": "月", // (个月)
          "price": 198000,
          "fans_medal_level": 24, //粉丝勋章等级
          "fans_medal_name": "aw4ifC", //粉丝勋章名
          "fans_medal_wearing_status": false, //该房间粉丝勋章佩戴情况
          "timestamp": 1653555128,
          "room_id": 460695,
          "msg_id": "" //消息唯一id
        }
      };

      handler.handleOpenGuardBuy(guardBuyData);
      expect(capturedLogs, contains('[GuardBuy]  购买 1 月 的 舰长 '));
      capturedLogs.clear();
    });
    test('OpenLike ', () {
      setupLiveEventListeners();
      Map likeData = {
        "data": {
          "uname": "哔哩哔哩直播",
          "uid": 0,
          "open_id": "39b8fedb-60a5-4e29-ac75-b16955f7e632",
          "uface":
              "https://i0.hdslb.com/bfs/face/8f6a614a48a3813d90da7a11894ae56a59396fcd.jpg",
          "timestamp": 1685946262,
          "like_text": "为主播点赞了",
          "like_count": 114,
          "fans_medal_wearing_status": false,
          "fans_medal_name": "",
          "fans_medal_level": 0,
          "msg_id": "57a7c676-ff00-4967-bb09-03e800ab0f4d",
          "room_id": 1
        },
        "cmd": "LIVE_OPEN_PLATFORM_LIKE"
      };

      handler.handleOpenLike(likeData);
      expect(capturedLogs, contains('[Like] 哔哩哔哩直播 liked the stream.'));
      capturedLogs.clear();
    });
    test('OpenInteractionEnd ', () {
      setupLiveEventListeners();
      Map interactionEndData = {
        "cmd": "LIVE_OPEN_PLATFORM_INTERACTION_END",
        "data": {
          "game_id": "f0423922-60e9-4f8c-b5f3-6ad2cb888a22",
          "timestamp": 1714113037
        }
      };

      handler.handleOpenInteractionEnd(interactionEndData);
      expect(capturedLogs,
          contains('[InteractionEnd] interaction end at 1714113037'));
      capturedLogs.clear();
    });
  });
}
