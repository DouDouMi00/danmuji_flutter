import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'package:brotli/brotli.dart';

final buffer = Uint8List(16);

Uint8List packHeader(
    int packLen, int rawHeaderSize, int ver, int operation, int seqId) {
  final byteData = ByteData.view(buffer.buffer);
  // 使用大端模式设置值
  byteData.setUint32(0, packLen, Endian.big);
  byteData.setUint16(4, rawHeaderSize, Endian.big);
  byteData.setUint16(6, ver, Endian.big);
  byteData.setUint32(8, operation, Endian.big);
  byteData.setUint32(12, seqId, Endian.big);

  return buffer;
}

Uint8List prepareRequestBody(dynamic data, int operation) {
  final bytesBuilder = BytesBuilder();
  Uint8List body = bytesBuilder.toBytes();
  if (data is Map<String, dynamic>) {
    // 将Map转换为JSON字符串，然后编码为UTF-8字节
    String jsonString = json.encode(data);
    body = utf8.encode(jsonString);
  } else if (data is String) {
    // 如果是字符串，直接编码为UTF-8字节
    body = utf8.encode(data);
  } else {
    // 其他类型，假设数据已经是字节列表
    body = data as Uint8List;
  }

  final packLen = buffer.length + body.length; // 示例中的数据长度
  final rawHeaderSize = buffer.length;
  const ver = 1;
  const seqId = 1;
  final header = packHeader(packLen, rawHeaderSize, ver, operation, seqId);

  return Uint8List.fromList(header + body);
}

class DanmakuProtocol {
  static const json = 0;
  static const heartbeat = 1;
  static const zip = 2;
  static const brotli = 3;
}

class DanmakuType {
  static const int heartbeat = 2;
  static const int heartbeatReply = 3;
  static const int data = 5;
  static const int auth = 7;
  static const int authReply = 8;
}

// **BaseHandler._CMD_CALLBACK_DICT, (基础处理器的命令回调字典)
// "DANMU_MSG": onDanmuCallback,    // 弹幕消息：弹幕回调函数
// "SEND_GIFT": onGiftCallback,     // 赠送礼物：礼物回调函数
// "USER_TOAST_MSG": onGuardBuyCallback, // 用户提示消息：购买守护回调函数
// "SUPER_CHAT_MESSAGE": onSCCallback,   // 醒目留言：醒目留言回调函数
// "INTERACT_WORD": onInteractWordCallback, // 互动词：互动词回调函数
// "LIKE_INFO_V3_CLICK": onLikeCallback,  // 点赞信息V3点击：点赞回调函数
// "WARNING": onWarning,                // 警告：警告回调函数
// "CUT_OFF": onCutOff,                 // 切断连接：切断回调函数

class DanmakuReceiver {
  final List<Function> _DANMU_MSG = [];
  final List<Function> _SEND_GIFT = [];
  final List<Function> _USER_TOAST_MSG = [];
  final List<Function> _SUPER_CHAT_MESSAGE = [];
  final List<Function> _INTERACT_WORD = [];
  final List<Function> _LIKE_INFO_V3_CLICK = [];
  final List<Function> _WARNING = [];
  final List<Function> _CUT_OFF = [];

  WebSocketChannel? ws;
  int roomId = 0;

  DanmakuReceiver(roomId) {
    final headers = <String, String>{
      'Cookie': 'buvid3=' '; SESSDATA=' '; bili_jct=' ';',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36'
    };
    http
        .get(
            Uri.parse(
                'https://api.live.bilibili.com/room/v1/Room/room_init?id=$roomId'),
            headers: headers)
        .then((value) async {
      final dataJSON = jsonDecode(value.body);
      final roomInfoJSON = jsonDecode((await http.get(
              Uri.parse(
                  'https://api.live.bilibili.com/room/v1/Danmu/getConf?room_id=${dataJSON['data']['room_id']}&platform=pc&player=web'),
              headers: headers))
          .body);
      roomId = dataJSON['data']['room_id'];
      ws = WebSocketChannel.connect(Uri.parse(
          'wss://${roomInfoJSON['data']['host_server_list'][0]['host']}:${roomInfoJSON['data']['host_server_list'][0]['wss_port']}/sub'));
      final authJSONString = jsonEncode({
        'roomid': roomId,
        'protover': 3,
        'platform': 'web',
        'uid': 0,
        'key': roomInfoJSON['data']['token']
      });
      final authPacket = packetEncode(1, DanmakuType.auth, authJSONString);
      ws?.sink.add(authPacket);
      ws?.stream.listen(
        (event) {
          final data = Uint8List.fromList(event);
          final dataBytes = ByteData.view(data.buffer);
          final totalLength = dataBytes.getInt32(0);
          final protocol = dataBytes.getInt16(6);
          final type = dataBytes.getInt32(8);
          final payload = data.getRange(16, totalLength);
          switch (type) {
            case DanmakuType.authReply:
              print('认证通过，已连接到弹幕服务器 $roomId');
              Timer.periodic(const Duration(seconds: 30), (timer) {
                ws?.sink.add(packetEncode(1, 2, "[object Object]"));
              });
              break;
            case DanmakuType.data:
              // print('totalLength: $totalLength, protocol: $protocol, type: $type, payload: $payload');
              switch (protocol) {
                case DanmakuProtocol.json:
                  // 系统广播一类的，这些数据没啥用
                  break;
                case DanmakuProtocol.brotli:
                  var offset = 0;
                  final data =
                      Uint8List.fromList(brotli.decode(payload.toList()));
                  final dataBytes = ByteData.view(data.buffer);

                  while (offset < data.length) {
                    final length = dataBytes.getUint32(offset);
                    final dataJSONString = utf8.decode(
                        data.getRange(offset + 16, offset + length).toList());
                    final dataJSON = jsonDecode(dataJSONString);
                    final cmd = dataJSON['cmd'].toString().split(':')[0];
                    switch (cmd) {
                      case 'DANMU_MSG':
                        for (final handler in _DANMU_MSG) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'SEND_GIFT':
                        for (final handler in _SEND_GIFT) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'USER_TOAST_MSG':
                        for (final handler in _USER_TOAST_MSG) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'SUPER_CHAT_MESSAGE':
                        for (final handler in _SUPER_CHAT_MESSAGE) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'INTERACT_WORD':
                        for (final handler in _INTERACT_WORD) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'LIKE_INFO_V3_CLICK':
                        for (final handler in _LIKE_INFO_V3_CLICK) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'WARNING':
                        for (final handler in _WARNING) {
                          Future.microtask(() => handler(dataJSON));
                        }
                      case 'CUT_OFF':
                        for (final handler in _CUT_OFF) {
                          Future.microtask(() => handler(dataJSON));
                        }
                    }
                    offset += length;
                  }
                  break;
              }
              break;
          }
        },
      );
    });
  }
  Uint8List packetEncode(int protocol, int type, String payload) {
    final utf8Payload = utf8.encode(payload);
    final totalLength = 16 + utf8Payload.length;
    final packetHeader = ByteData(16);
    packetHeader.setInt32(0, totalLength);
    packetHeader.setInt16(4, 16);
    packetHeader.setUint16(6, protocol);
    packetHeader.setUint32(8, type);
    packetHeader.setUint32(12, 1);
    final packet = BytesBuilder();
    packet.add(packetHeader.buffer.asInt8List());
    packet.add(utf8Payload);
    return packet.toBytes();
  }

  void dispose() {
    ws?.sink.close();
    ws = null;
    _DANMU_MSG.clear();
    _SEND_GIFT.clear();
    _USER_TOAST_MSG.clear();
    _SUPER_CHAT_MESSAGE.clear();
    _INTERACT_WORD.clear();
    _LIKE_INFO_V3_CLICK.clear();
    _WARNING.clear();
    _CUT_OFF.clear();
    print('已断开弹幕服务器连接');
  }

  void onDanmaku(Function handler) {
    _DANMU_MSG.add(handler);
  }

  void onGift(Function handler) {
    _SEND_GIFT.add(handler);
  }

  void onGuard(Function handler) {
    _USER_TOAST_MSG.add(handler);
  }

  void onSuperChat(Function handler) {
    _SUPER_CHAT_MESSAGE.add(handler);
  }

  void onLiveStart(Function handler) {
    _INTERACT_WORD.add(handler);
  }

  void onLiveEnd(Function handler) {
    _LIKE_INFO_V3_CLICK.add(handler);
  }

  void onWarning(Function handler) {
    _WARNING.add(handler);
  }

  void onCutOff(Function handler) {
    _CUT_OFF.add(handler);
  }
}
