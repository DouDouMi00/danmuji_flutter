// control_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import '/controllers/message_queue_controller.dart';
import '/services/keyboard.dart';
import '/services/live.dart';
import '/services/messages_handler.dart';
import '/services/open_live.dart';
import '/services/stats.dart';
import '/services/system_handler.dart';
import '/services/tts.dart';

final messageController = Get.put(MessageQueueController());

// 控制面板页面，用于管理直播中的各种控制功能，如弹幕阅读、礼物阅读及TTS控制。
class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  ControlPageState createState() => ControlPageState();
}

// ControlPage的状态类，管理页面的动态更新和事件处理。
class ControlPageState extends State<ControlPage>
    with TickerProviderStateMixin {
  // 是否处于运行状态的标志。
  bool isRunning = false;
  bool _isOpenButton = true;
  bool _isWebButton = true;

  // 操作按钮的文本内容，根据运行状态动态改变。
  String buttonText = '开始';

  // 消息处理程序，用于处理各种消息，如弹幕、礼物等。
  final MessageHandler messageHandler = MessageHandler();
  final OpenMessageHandler openmessageHandler = OpenMessageHandler();

  bool isExpanded1 = false;
  double _dividerPosition = 0.7;
  bool _isFullScreenMode = false;
  final backgroundColor = Colors.grey[400]?.withOpacity(0.2);

  Map<int, String> messageTypes = {
    0: 'all',
    1: 'danmu',
    2: 'gift',
    3: 'guardBuy',
    4: 'superChat',
    5: 'other',
  };

  final List<Tab> tabs = [
    const Tab(text: '全部'),
    const Tab(text: '弹幕'),
    const Tab(text: '礼物'),
    const Tab(text: '上舰'),
    const Tab(text: '醒目留言'),
    const Tab(text: '其他'),
  ];

  late TabController _tabController;

  final List<ScrollController> scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  final List<RxBool> showBackToBottomButton = [
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
  ];

  final List<RxInt> autoScroll = [
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
  ];

  final List<RxInt> newMessages = [
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
  ];

  void Function() onMessageAdd(RxBool showBackToBottomButton,
      ScrollController scrollController, RxInt autoScroll, RxInt newMessages) {
    return () async {
      if (showBackToBottomButton.value == false &&
          scrollController.hasClients) {
        autoScroll.value += 1;
        await Future.delayed(Duration(milliseconds: Random().nextInt(11) + 20));
        await scrollController
            .animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
            .whenComplete(() {
          autoScroll.value -= 1;
        });
      } else {
        newMessages.value += 1;
      }
    };
  }

  void Function() addList(int index) {
    return () {
      if (scrollControllers[index].offset <
              scrollControllers[index].position.maxScrollExtent &&
          autoScroll[index].value <= 0) {
        showBackToBottomButton[index].value = true;
      } else if (scrollControllers[index].offset ==
          scrollControllers[index].position.maxScrollExtent) {
        newMessages[index].value = 0;
        showBackToBottomButton[index].value = false;
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    for (int i = 0; i < scrollControllers.length; i++) {
      messageController.onMessageAdded(
          messageTypes[i]!,
          onMessageAdd(showBackToBottomButton[i], scrollControllers[i],
              autoScroll[i], newMessages[i]));
      scrollControllers[i].addListener(addList(i));
    }

    ttsTask();
    setupLiveEventListeners();
    setupStatsEventListeners();
    statsTask();
  }

  @override
  void dispose() {
    messageHandler.stop();
    openmessageHandler.stop();
    cancelLiveEventListeners();
    cancelStatsEventListeners();
    stopStatsTask();
    messageController.clearMessages();
    clearMessagesQueue();
    stopTtsTask();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Text('$label\n$value', textAlign: TextAlign.center),
    );
  }

// 主要的 UI 构建部分
  Widget buildMainUI() {
    return Obx(
      () => ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('输出队列 ${messageController.messagesQueueLength.value} 条'),
            Text('当前延迟 ${messageController.delay.value} 秒'),
          ],
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('弹幕',
                  '${messageController.filtrationEfficiencyDanmu.value.toStringAsFixed(2)}%'),
              _buildStatItem('礼物',
                  '${messageController.filtrationEfficiencyGift.value.toStringAsFixed(2)}%'),
              _buildStatItem('欢迎',
                  '${messageController.filtrationEfficiencyWelcome.value.toStringAsFixed(2)}%'),
              _buildStatItem('点赞',
                  '${messageController.filtrationEfficiencyLike.value.toStringAsFixed(2)}%'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('舰长',
                  '${messageController.filtrationEfficiencyGuardBuy.value.toStringAsFixed(2)}%'),
              _buildStatItem('关注',
                  '${messageController.filtrationEfficiencySubscribe.value.toStringAsFixed(2)}%'),
              _buildStatItem('醒目留言',
                  '${messageController.filtrationEfficiencySuperChat.value.toStringAsFixed(2)}%'),
              _buildStatItem('警告',
                  '${messageController.filtrationEfficiencyWarning.value.toStringAsFixed(2)}%'),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleFullScreenMode() {
    setState(() {
      _isFullScreenMode = !_isFullScreenMode;
    });
  }

  List<Widget> generateMessageListWrappers() {
    List<Widget> wrappers = [];

    List<Map<String, dynamic>> wrapperMessageTypes = [
      {'messages': messageController.messagesAll, 'index': 0},
      {'messages': messageController.messagesDanmu, 'index': 1},
      {'messages': messageController.messagesGift, 'index': 2},
      {'messages': messageController.messagesGuardBuy, 'index': 3},
      {'messages': messageController.messagesSuperChat, 'index': 4},
      {'messages': messageController.messagesOther, 'index': 5},
    ];

    for (var messageType in wrapperMessageTypes) {
      int index = messageType['index'];
      wrappers.add(
        MessageListWrapper(
          messages: messageType['messages'],
          showBackToBottomButton: showBackToBottomButton[index],
          scrollController: scrollControllers[index],
          newMessages: newMessages[index],
        ),
      );
    }
    return wrappers;
  }

  void _updateDividerPosition(DragUpdateDetails details) {
    setState(() {
      _dividerPosition += details.delta.dy / context.size!.height;
      _dividerPosition = _dividerPosition.clamp(0.2, 0.85);
    });
  }

  Widget _buildTextButtonColumn(Widget firstButton, [Widget? secondButton]) {
    return Expanded(
      child: Row(
        children: [
          firstButton,
          if (secondButton != null) secondButton,
        ],
      ),
    );
  }

  Widget _buildTextIconButton(String text, VoidCallback? onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all<Size>(
            const Size(double.infinity, double.infinity),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Future<void> _showConfirmDialog() async {
    return Get.dialog(
      AlertDialog(
        title: const Text('确认清空？'),
        content: const Text('这将清除未朗读的消息记录。'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('取消'),
            onPressed: () {
              Get.back();
            },
          ),
          ElevatedButton(
            child: const Text('确定'),
            onPressed: () async {
              await handleFlush();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBigButtons() {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 启动/停止按钮和清空按钮。
            _buildTextButtonColumn(
              _buildTextIconButton('Web平台$buttonText',
                  _isWebButton ? _toggleRunningStatus : null),
              _buildTextIconButton('开放平台$buttonText',
                  _isOpenButton ? _toggleRunningStatusOpen : null),
            ),
            _buildTextButtonColumn(
              _buildTextIconButton('清空', isRunning ? _showConfirmDialog : null),
            ),
            // TTS语速控制按钮。
            _buildTextButtonColumn(
              _buildTextIconButton(
                  '语速-1', isRunning ? handleTTSVolumeMinus : null),
              _buildTextIconButton(
                  '语速+1', isRunning ? handleTTSRatePlus : null),
            ),
            // 弹幕和礼物控制按钮，用于浏览历史弹幕和礼物。
            _buildTextButtonColumn(
              _buildTextIconButton(
                  '回到最新弹幕', isRunning ? handleReadNewestMessages : null),
            ),
            _buildTextButtonColumn(
              _buildTextIconButton(
                  '查看上一条弹幕', isRunning ? handleReadNextHistoryDanmu : null),
              _buildTextIconButton(
                  '查看下一条弹幕', isRunning ? handleReadLastHistoryDanmu : null),
            ),
            _buildTextButtonColumn(
              _buildTextIconButton(
                  '查看上一条礼物', isRunning ? handleReadNextGiftMessages : null),
              _buildTextIconButton(
                  '查看下一条礼物', isRunning ? handleReadLastGiftMessages : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButtonColumn(Widget firstButton, [Widget? secondButton]) {
    return Expanded(
      child: Column(
        children: [
          firstButton,
          if (secondButton != null) secondButton,
        ],
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, VoidCallback? onPressed, String semanticsLabel) {
    return Expanded(
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon, semanticLabel: semanticsLabel),
        constraints: const BoxConstraints(
          // 设置按钮大小
          minWidth: double.infinity,
          minHeight: double.infinity,
        ),
      ),
    );
  }

  Widget _buildVerticalTwoRowButtons() {
    return Container(
      color: backgroundColor,
      child: Row(
        children: [
          _buildIconButtonColumn(
            _buildIconButton(Icons.web,
                _isWebButton ? _toggleRunningStatus : null, 'Web平台$buttonText'),
            _buildIconButton(
                Icons.lock_open_outlined,
                _isOpenButton ? _toggleRunningStatusOpen : null,
                '开放平台$buttonText'),
          ),
          _buildIconButtonColumn(
            _buildIconButton(
                Icons.clear_all, isRunning ? _showConfirmDialog : null, '清空消息'),
          ),
          _buildIconButtonColumn(
            _buildIconButton(Icons.volume_up,
                isRunning ? handleTTSRatePlus : null, '提高语音播报语速'),
            _buildIconButton(Icons.volume_down,
                isRunning ? handleTTSVolumeMinus : null, '降低语音播报语速'),
          ),
          _buildIconButtonColumn(
            _buildIconButton(Icons.refresh,
                isRunning ? handleReadNewestMessages : null, '回到最新弹幕'),
          ),
          _buildIconButtonColumn(
            _buildIconButton(Icons.keyboard_arrow_up,
                isRunning ? handleReadNextHistoryDanmu : null, '查看上一条弹幕'),
            _buildIconButton(Icons.keyboard_arrow_down,
                isRunning ? handleReadLastHistoryDanmu : null, '查看下一条弹幕'),
          ),
          _buildIconButtonColumn(
            _buildIconButton(Icons.keyboard_arrow_up,
                isRunning ? handleReadNextGiftMessages : null, '查看上一条礼物'),
            _buildIconButton(Icons.keyboard_arrow_down,
                isRunning ? handleReadLastGiftMessages : null, '查看下一条礼物'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, statusBarHeight, 16.0, 0),
        child: Column(
          children: [
            if (!_isFullScreenMode) buildMainUI(),
            Expanded(
              flex: (_dividerPosition * 100).round(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          tabs: tabs,
                          // 在这里添加全屏模式切换按钮
                        ),
                      ),
                      IconButton(
                        icon: _isFullScreenMode
                            ? const Icon(Icons.fullscreen_exit,
                                semanticLabel: '退出全屏模式')
                            : const Icon(Icons.fullscreen,
                                semanticLabel: '全屏模式'),
                        onPressed: _toggleFullScreenMode,
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: generateMessageListWrappers(),
                    ),
                  ),
                ],
              ),
            ),
            if (!_isFullScreenMode)
              GestureDetector(
                onVerticalDragUpdate: _updateDividerPosition,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10), // 设置上边缘圆角半径
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
              ),
            if (!_isFullScreenMode)
              Expanded(
                flex: ((1 - _dividerPosition) * 100).round(),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (_dividerPosition < 0.85) {
                      return _buildBigButtons();
                    } else {
                      return _buildVerticalTwoRowButtons();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showStartStopConfirmDialog(
      String platform, String action) async {
    return await Get.dialog(
      AlertDialog(
        title: Text('$platform $action确认'),
        content: Text('您确定要$platform $action吗？'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('取消'),
            onPressed: () {
              Get.back(result: false);
            },
          ),
          ElevatedButton(
            child: const Text('确定'),
            onPressed: () {
              Get.back(result: true);
            },
          ),
        ],
      ),
    );
  }

  void _toggleRunningStatus() async {
    // 首先禁用按钮，防止多次点击
    _isWebButton = false;
    _isOpenButton = false;
    setState(() {});

    // 显示确认对话框
    final shouldProceed =
        await _showStartStopConfirmDialog('Web平台', isRunning ? '停止' : '启动');
    if (!shouldProceed) {
      if (!isRunning) {
        // 如果用户取消，则恢复按钮状态
        _isWebButton = true;
        _isOpenButton = true;
      } else {
        _isWebButton = true;
      }
      setState(() {});
      return;
    }
    if (!isRunning) {
      await Future.delayed(const Duration(seconds: 2));
      _isWebButton = true;
      if (!await messageHandler.run()) {
        _isWebButton = true;
        _isOpenButton = true;
        setState(() {});
        return;
      }
    } else {
      messageHandler.stop();
      await markAllMessagesInvalid();
      _isWebButton = true;
      _isOpenButton = true;
    }
    _vibrateAndUpdateButtonText();
    setState(() {});
  }

  void _toggleRunningStatusOpen() async {
    // 首先禁用按钮，防止多次点击
    _isWebButton = false;
    _isOpenButton = false;
    setState(() {});
    // 显示确认对话框
    final shouldProceed =
        await _showStartStopConfirmDialog('开放平台', isRunning ? '停止' : '启动');
    if (!shouldProceed) {
      if (!isRunning) {
        // 如果用户取消，则恢复按钮状态
        _isWebButton = true;
        _isOpenButton = true;
      } else {
        _isOpenButton = true;
      }
      setState(() {});
      return;
    }
    if (!isRunning) {
      await Future.delayed(const Duration(seconds: 2));
      _isOpenButton = true;
      if (!await openmessageHandler.run()) {
        _isWebButton = true;
        _isOpenButton = true;
        setState(() {});
        return;
      }
    } else {
      openmessageHandler.stop();
      await markAllMessagesInvalid();
      _isWebButton = true;
      _isOpenButton = true;
    }
    _vibrateAndUpdateButtonText();
    setState(() {});
  }

  // 振动设备并更新按钮文本，用于反馈用户操作。
  void _vibrateAndUpdateButtonText() {
    Vibration.vibrate(pattern: [30, 30, 30, 30], intensities: [255, 0, 255, 0]);
    setState(() {
      isRunning = !isRunning;
      buttonText = isRunning ? '停止' : '开始';
    });
  }
}

// 新增的 MessageListWrapper 类
class MessageListWrapper extends StatefulWidget {
  final RxList messages;
  final RxBool showBackToBottomButton;
  final ScrollController scrollController;
  final RxInt newMessages;

  const MessageListWrapper({
    super.key,
    required this.messages,
    required this.showBackToBottomButton,
    required this.scrollController,
    required this.newMessages,
  });

  @override
  MessageListWrapperState createState() => MessageListWrapperState();
}

class MessageListWrapperState extends State<MessageListWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 设置为true以保持状态
  // 辅助方法，根据等级返回对应的颜色
  Color? _getGuardLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.amber; // 等级 1 为金色
      case 2:
        return Colors.purple; // 等级 2 为紫色
      case 3:
        return Colors.blue; // 等级 3 为蓝色
      default:
        return null; // 默认颜色为黑色
    }
  }

  // 定义一个方法来创建基本的消息容器
  Widget _buildBaseMessageContainer(Widget child) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: child,
      ).paddingOnly(top: 4, bottom: 4),
    );
  }

  // 创建文本样式
  TextStyle? _getTextStyle(bool filtered, int guardLevel) {
    return filtered
        ? const TextStyle(color: Colors.grey)
        : TextStyle(color: _getGuardLevelColor(guardLevel));
  }

  // 封装获取字体大小的函数
  double getFontSize(Text text) {
    final textSpan = TextSpan(
      text: text.data,
      style: text.style,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr, // 根据实际情况选择 ltr 或 rtl
    );

    textPainter.layout();
    return textPainter.height;
  }

  // 处理富文本内容
  List<Widget> _buildRichContent(
      List richContent, bool filtered, int guardLevel) {
    double textHeight = getFontSize(Text("测试文本",
        style: _getTextStyle(
          filtered,
          guardLevel,
        )));
    double imageHeight = textHeight * 2;
    return richContent.map((content) {
      if (content['type'] == 0) {
        return Text(content['text'],
            style: _getTextStyle(filtered, guardLevel),
            overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
            softWrap: true, // 允许换行
            textAlign: TextAlign.left // 左对齐
            );
      } else if (content['type'] == 1) {
        return Image.network(
          content['url'],
          semanticLabel: content['text'],
          height: imageHeight,
          width: content['width'] / content['height'] * imageHeight,
          fit: BoxFit.cover,
        );
      }
      return Container(); // 默认返回空容器
    }).toList();
  }

  // 根据消息类型构建消息小部件
  Widget _buildMessageWidget(RxList messages, int index) {
    final message = messages[index];
    final filtered = message['filterd'];
    final guardLevel = message['liveRoomGuardLevel'];

    switch (message['type']) {
      case 'danmu':
        return _buildBaseMessageContainer(
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${message['uname']}: ',
                style: _getTextStyle(filtered, guardLevel),
                overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
                softWrap: true, // 允许换行
                textAlign: TextAlign.left, // 左对齐
              ),
              ..._buildRichContent(
                message['richContent'],
                filtered,
                guardLevel,
              ).map((widget) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: widget,
                  ))
            ],
          ),
        );
      case 'gift':
        return _buildBaseMessageContainer(
          Text(
            '${message['uname']} (${message['unamePronunciation']}) '
            '[${message['price']}元]'
            '\n送出${message['num']}个${message['giftName']}',
            style: _getTextStyle(filtered, 0),
            overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
            softWrap: true, // 允许换行
            textAlign: TextAlign.left, // 左对齐
          ),
        );
      case 'guardBuy':
        return _buildBaseMessageContainer(
          Text(
            '${message['uname']} (${message['unamePronunciation']}) '
            '\n购买${message['num']}个${message['giftName']}',
            style: _getTextStyle(filtered, guardLevel),
            overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
            softWrap: true, // 允许换行
            textAlign: TextAlign.left, // 左对齐
          ),
        );
      case 'superChat':
        return _buildBaseMessageContainer(
          Text(
            '${message['uname']} (${message['unamePronunciation']}) '
            '[${message['price']}元]\n醒目留言  ${message['msg']}',
            style: _getTextStyle(filtered, 0),
            overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
            softWrap: true, // 允许换行
            textAlign: TextAlign.left, // 左对齐
          ),
        );
      case 'system':
        return _buildBaseMessageContainer(
          Text(
            '系统提示\n${message['msg']}',
            style: _getTextStyle(filtered, 0),
            overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
            softWrap: true, // 允许换行
            textAlign: TextAlign.center, // 居中对齐
          ),
        );
      default:
        return _buildBaseMessageContainer(
          Text(messagesToText(message),
              style: _getTextStyle(filtered, 0),
              overflow: TextOverflow.clip, // 确保文本溢出时被裁剪
              softWrap: true, // 允许换行
              textAlign: TextAlign.left // 左对齐
              ),
        );
    }
  }

  Widget buildBackToBottomButton(RxBool showBackToBottomButton,
      ScrollController scrollController, RxInt newMessages) {
    // 回到底部的按钮，只有当不在底部时才显示
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            while (scrollController.offset <
                scrollController.position.maxScrollExtent) {
              await scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            newMessages.value = 0;
            showBackToBottomButton.value = false;
          },
          child: newMessages.value != 0
              ? Text('新消息 ${newMessages.value} 条')
              : const Text('回到底部'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(top: 0),
            controller: widget.scrollController,
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              return _buildMessageWidget(widget.messages, index);
            },
          ),
          if (widget.showBackToBottomButton.value)
            buildBackToBottomButton(widget.showBackToBottomButton,
                widget.scrollController, widget.newMessages)
        ],
      ),
    );
  }
}
