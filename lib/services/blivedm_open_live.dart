import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

// import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '/services/config.dart';
import '/services/logger.dart';
import '/services/tts.dart' show ttsSystem;

class Proto {
  late int packetLen;
  late int headerLen;
  late int ver;
  late int op;
  late int seq;
  late String body;
  late int maxBody;
  late Uint8List bodyUint8;
  final buffer = Uint8List(16);

  Proto() {
    packetLen = 0;
    headerLen = 16;
    ver = 0;
    op = 0;
    seq = 0;
    body = '';
    maxBody = 2048;
    bodyUint8 = Uint8List(maxBody);
  }

  Uint8List pack() {
    final ByteData byteData = ByteData.view(buffer.buffer);
    packetLen = body.length + headerLen;
    byteData.setUint32(0, packetLen, Endian.big);
    byteData.setUint16(4, headerLen, Endian.big);
    byteData.setUint16(6, ver, Endian.big);
    byteData.setUint32(8, op, Endian.big);
    byteData.setUint32(12, seq, Endian.big);
    Uint8List bodyUint8 = utf8.encode(body);
    return Uint8List.fromList(buffer + bodyUint8);
  }

  Uint8List? unpack(Uint8List buf) {
    if (buf.length < headerLen) {
      logger.info("包头不够");
      return null;
    }
    final Uint8List data = Uint8List.fromList(buf);
    final ByteData bufBytes = ByteData.view(data.buffer);
    packetLen = bufBytes.getInt32(0);
    headerLen = bufBytes.getInt16(4);
    ver = bufBytes.getInt16(6);
    op = bufBytes.getInt32(8);
    seq = bufBytes.getInt32(12);
    if (packetLen < 0 || packetLen > maxBody) {
      logger.info('包体长不对 self.packetLen:$packetLen self.maxBody:$maxBody');
      return null;
    }
    if (headerLen != headerLen) {
      logger.info('包头长度不对');
      return null;
    }
    int bodyLen = packetLen - headerLen;
    Uint8List bodyUint8 = buf.sublist(16, packetLen);
    body = utf8.decode(bodyUint8);
    if (bodyLen <= 0) {
      return null;
    }
    if (ver == 0) {
      // 收到消息
      logger.info('收到消息$body');
      return buf;
    } else {
      return null;
    }
  }
}

class OpenDanmakuType {
  static const int heartbeat = 2;
  static const int heartbeatReply = 3;
  static const int data = 5;
  static const int auth = 7;
  static const int authReply = 8;
}

class OpenDanmakuProtocol {
  static const json = 0;
  static const zlib = 2;
}
// 获取弹幕信息 LIVE_OPEN_PLATFORM_DM
// 获取礼物信息 LIVE_OPEN_PLATFORM_SEND_GIFT
// 获取付费留言 LIVE_OPEN_PLATFORM_SUPER_CHAT
// 付费留言下线  LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL
// 付费大航海 LIVE_OPEN_PLATFORM_GUARD
// 点赞信息 LIVE_OPEN_PLATFORM_LIKE 对单一用户最近2秒聚合发送一次点赞次数
// 消息推送结束通知 LIVE_OPEN_PLATFORM_INTERACTION_END

class OpenLiveDanmakuReceiver {
  final List<Function> _openLiveDanmu = []; // 弹幕信息
  final List<Function> _openLiveGift = []; // 礼物信息
  final List<Function> _openLiveSuperChat = []; // 付费留言
  final List<Function> _openLiveSuperChatDel = []; // 付费留言下线
  final List<Function> _openLiveGuard = []; // 付费大航海
  final List<Function> _openLiveLike = []; // 点赞信息
  final List<Function> _openLiveInteractionEnd = []; // 消息推送结束通知
  bool isclose = false;

  WebSocketChannel? websocket;
  Timer? _gameHeartBeatTimer;
  Timer? _heartBeatTimer;
  int? roomId;
  String? uname;
  String? uface;

  // ZLibDecoder zlibDecoder = const ZLibDecoder();

  late String idCode; //主播身份码
  late int appId; // 应用id
  late String key; // access_key
  late String secret; // access_key_secret
  String host = "https://live-open.biliapi.com"; // 开放平台
  String gameId = "";

  OpenLiveDanmakuReceiver() {
    OpenLiveBili openLiveBiliConfig = getConfigMap().kvdb.openLiveBili;
    idCode = openLiveBiliConfig.idCode;
    appId = openLiveBiliConfig.appId;
    key = openLiveBiliConfig.accessKey;
    secret = openLiveBiliConfig.accessKeySecret;
  }

  Future<bool> run() async {
    isclose = false;
    if (await connect()) {
      recvLoop();
      heartBeat();
      appheartBeat();
    } else {
      return false;
    }
    return true;
  }

  // 关闭应用时调取
  void stop() async {
    isclose = true;
    websocket?.sink.close();
    _heartBeatTimer?.cancel();
    _gameHeartBeatTimer?.cancel();
    final String postUrl = "$host/v2/app/end";
    final String params = '{"game_id":"$gameId", "app_id":$appId}';
    Map<String, String> headerMap = sign(params);
    var dioInstance = Dio();
    final response = await dioInstance.post(postUrl,
        options: Options(headers: headerMap), data: params);
    logger.info('关闭应用 ${response.data}');

    // 清空所有回调列表
    _openLiveDanmu.clear();
    _openLiveGift.clear();
    _openLiveSuperChat.clear();
    _openLiveSuperChatDel.clear();
    _openLiveGuard.clear();
    _openLiveLike.clear();
    _openLiveInteractionEnd.clear();
  }

  Map<String, String> sign(String params) {
    String md5data =
        md5.convert(const Utf8Encoder().convert(params)).toString();
    int ts = DateTime.now().millisecondsSinceEpoch;
    int nonce =
        Random().nextInt(100000) + DateTime.now().millisecondsSinceEpoch;
    Map<String, String> headerMap = {
      "x-bili-timestamp": ts.toString(),
      "x-bili-signature-method": "HMAC-SHA256",
      "x-bili-signature-nonce": nonce.toString(),
      "x-bili-accesskeyid": key,
      "x-bili-signature-version": "1.0",
      "x-bili-content-md5": md5data,
    };
    List<dynamic> headerList = headerMap.keys.toList()..sort();
    String headerStr =
        headerList.map((key) => '$key:${headerMap[key]}\n').join();

    Uint8List appSecret = utf8.encode(secret);
    Uint8List data = utf8.encode(headerStr.trimRight());
    String signature = Hmac(sha256, appSecret).convert(data).toString();

    headerMap["Authorization"] = signature;
    headerMap["Content-Type"] = "application/json";
    headerMap["Accept"] = "application/json";

    return headerMap;
  }

  Future<List?> getWebsocketInfo() async {
    final String postUrl = "$host/v2/app/start";
    final String params = '{"code":"$idCode","app_id":$appId}';
    Map<String, String> headerMap = sign(params);

    var dioInstance = Dio();
    // dioInstance.options.contentType = 'application/json';
    final response = await dioInstance.post(postUrl,
        options: Options(headers: headerMap), data: params);

    final data = response.data;
    if (data['code'] != 0) {
      logger.warning('获取websocket信息失败 ${data["message"]}');
      await ttsSystem(
          '获取websocket信息失败,返回的错误码为${data['code']}，描述“${data["message"]}”,请检查配置文件');
      return null;
    }
    gameId = data['data']['game_info']['game_id'].toString();
    roomId = data['data']['anchor_info']['room_id'];
    uname = data['data']['anchor_info']['uname'];
    uface = data['data']['anchor_info']['uface'];

    return [
      data["data"]["websocket_info"]["wss_link"][0].toString(),
      data["data"]["websocket_info"]["auth_body"].toString()
    ];
  }

  // 发送游戏心跳
  Future<void> appheartBeat() async {
    final String postUrl = "$host/v2/app/heartbeat";
    _gameHeartBeatTimer =
        Timer.periodic(const Duration(seconds: 14), (timer) async {
      if (!isclose) {
        try {
          var dioInstance = Dio();
          final String params = '{"game_id":"$gameId"}';
          Map<String, String> headerMap = sign(params);
          final response = await dioInstance.post(postUrl,
              options: Options(headers: headerMap), data: params);
          final data = response.data;
          if ([7000, 7003].contains(data['code'])) {
            logger.info('项目已经关闭了');
            timer.cancel();
            _gameHeartBeatTimer?.cancel();
            stop();
          }
          logger.info('收到游戏心跳回复$data');
        } catch (e) {
          logger.warning('发送游戏心跳时发生错误: $e');
          stop();
        }
      } else {
        logger.info('发送游戏心跳失败');
        timer.cancel();
        _gameHeartBeatTimer?.cancel();
        stop();
      }
    });
  }

  Future<void> auth(String authBody) async {
    Proto req = Proto();
    req.body = authBody;
    req.op = OpenDanmakuType.auth;
    websocket!.sink.add(req.pack());
  }

  // 发送心跳
  Future<void> heartBeat() async {
    _heartBeatTimer =
        Timer.periodic(const Duration(seconds: 24), (timer) async {
      if (!isclose) {
        Proto req = Proto();
        req.op = OpenDanmakuType.heartbeat;
        websocket!.sink.add(req.pack());
        logger.info('发送心跳');
      } else {
        logger.info('发送心跳失败');
        timer.cancel();
        _heartBeatTimer?.cancel();
        stop();
      }
    });
  }

  Future<bool> connect() async {
    List<dynamic>? info = await getWebsocketInfo();
    if (info != null) {
      String addr = info[0];
      String authBody = info[1];
      websocket = WebSocketChannel.connect(Uri.parse(addr));
      await auth(authBody);
      return true;
    } else {
      return false;
    }
  }

  // 读取消息
  Future<void> recvLoop() async {
    websocket!.stream.listen((buf) async {
      Proto resp = Proto();
      if (resp.unpack(buf) != null) {
        switch (resp.op) {
          case OpenDanmakuType.authReply:
            logger.info('认证通过，已连接到弹幕服务器 $roomId');
            await ttsSystem('认证通过，进入直播间 $roomId , 主播昵称 $uname');
          case OpenDanmakuType.heartbeatReply:
            final data = Uint8List.fromList(buf);
            final bufBytes = ByteData.view(data.buffer);
            logger.info(bufBytes.getInt32(16)); // 可能为人气值
          case OpenDanmakuType.data:
            switch (resp.ver) {
              case OpenDanmakuProtocol.json:
                Map<String, dynamic> respJSON = jsonDecode(resp.body);
                cmdSwitch(respJSON);
                break;
              // case OpenDanmakuProtocol.zlib:
              //   var offset = 0;
              //   final data = Uint8List.fromList(
              //       zlibDecoder.decodeBytes(resp.bodyUint8.toList()));
              //   final dataBytes = ByteData.view(data.buffer);
              //   while (offset < data.length) {
              //     final length = dataBytes.getUint32(offset);
              //     final dataJSONString = utf8.decode(
              //         data.getRange(offset + 16, offset + length).toList());
              //     final dataJSON = jsonDecode(dataJSONString);
              //     cmdSwitch(dataJSON);
              //     offset += length;
              //   }
              //   break;
            }
            break;
        }
      }
    });
  }

  void cmdSwitch(dataJSON) {
    final cmd = dataJSON['cmd'];
    switch (cmd) {
      case 'LIVE_OPEN_PLATFORM_DM':
        for (final handler in _openLiveDanmu) {
          handler(dataJSON);
        }
      case 'LIVE_OPEN_PLATFORM_SEND_GIFT':
        for (final handler in _openLiveGift) {
          handler(dataJSON);
        }
      case 'LIVE_OPEN_PLATFORM_SUPER_CHAT':
        for (final handler in _openLiveSuperChat) {
          handler(dataJSON);
        }
      case 'LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL':
        for (final handler in _openLiveSuperChatDel) {
          handler(dataJSON);
        }
      case 'LIVE_OPEN_PLATFORM_GUARD':
        for (final handler in _openLiveGuard) {
          handler(dataJSON);
        }
      case 'LIVE_OPEN_PLATFORM_LIKE':
        for (final handler in _openLiveLike) {
          handler(dataJSON);
        }
      case 'LIVE_OPEN_PLATFORM_INTERACTION_END':
        for (final handler in _openLiveInteractionEnd) {
          handler(dataJSON);
        }
      default:
        // 处理未知的命令
        logger.info('未知命令 $dataJSON');
    }
  }

  void onDanmuCallback(Function handler) {
    _openLiveDanmu.add(handler);
  }

  void onGiftCallback(Function handler) {
    _openLiveGift.add(handler);
  }

  void onSuperChatCallback(Function handler) {
    _openLiveSuperChat.add(handler);
  }

  void onSuperChatDelCallback(Function handler) {
    _openLiveSuperChatDel.add(handler);
  }

  void onGuardBuyCallback(Function handler) {
    _openLiveGuard.add(handler);
  }

  void onLikeCallback(Function handler) {
    _openLiveLike.add(handler);
  }

  void onInteractionEndCallback(Function handler) {
    _openLiveInteractionEnd.add(handler);
  }
}
