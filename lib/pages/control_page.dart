// control_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import '/controllers/message_queue_controller.dart';
import '/services/keyboard.dart';
import '/services/live.dart';
import '/services/messages_handler.dart';
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
  bool _isButtonEnabled = true;

  // 操作按钮的文本内容，根据运行状态动态改变。
  String buttonText = '开始';

  // 消息处理程序，用于处理各种消息，如弹幕、礼物等。
  final MessageHandler messageHandler = MessageHandler();

  bool isExpanded1 = false;
  double _dividerPosition = 0.7;

  List<Tab> tabs = [
    const Tab(text: '全部'),
    const Tab(text: '弹幕'),
    const Tab(text: '礼物'),
    const Tab(text: '上舰'),
    const Tab(text: '醒目留言'),
    const Tab(text: '其他'),
  ];
  late TabController _tabController;
  final scrollAllController = ScrollController();
  final scrollDanmuController = ScrollController();
  final scrollGiftController = ScrollController();
  final scrollGuardBuyController = ScrollController();
  final scrollSuperChatController = ScrollController();
  final scrollOtherController = ScrollController();
  RxBool showAllBackToBottomButton = false.obs;
  RxBool showDanmuBackToBottomButton = false.obs;
  RxBool showGiftBackToBottomButton = false.obs;
  RxBool showGuardBuyBackToBottomButton = false.obs;
  RxBool showSuperChatBackToBottomButton = false.obs;
  RxBool showOtherBackToBottomButton = false.obs;
  RxInt autoAllScroll = 0.obs;
  RxInt autoDanmuScroll = 0.obs;
  RxInt autoGiftScroll = 0.obs;
  RxInt autoGuardBuyScroll = 0.obs;
  RxInt autoSuperChatScroll = 0.obs;
  RxInt autoOtherScroll = 0.obs;
  RxInt newAllMessages = 0.obs;
  RxInt newDanmuMessages = 0.obs;
  RxInt newGiftMessages = 0.obs;
  RxInt newGuardBuyMessages = 0.obs;
  RxInt newSuperChatMessages = 0.obs;
  RxInt newOtherMessages = 0.obs;

  void Function() onMessageAdd(RxBool showBackToBottomButton,
      ScrollController scrollController, RxInt autoScroll, RxInt newMessages) {
    return () {
      if (showBackToBottomButton.value == false &&
          scrollController.hasClients) {
        autoScroll.value += 1;
        scrollController
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

  void Function() addList(
    RxBool showBackToBottomButton,
    ScrollController scrollController,
    RxInt autoScroll,
    RxInt newMessages,
  ) {
    return () {
      if (scrollController.offset < scrollController.position.maxScrollExtent &&
          autoScroll.value <= 0) {
        showBackToBottomButton.value = true;
      } else if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        newMessages.value = 0;
        showBackToBottomButton.value = false;
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    messageController.onMessageAllAdded(onMessageAdd(
      showAllBackToBottomButton,
      scrollAllController,
      autoAllScroll,
      newAllMessages,
    ));
    messageController.onMessageDanmuAdded(onMessageAdd(
      showDanmuBackToBottomButton,
      scrollDanmuController,
      autoDanmuScroll,
      newDanmuMessages,
    ));
    messageController.onMessageGiftAdded(onMessageAdd(
      showGiftBackToBottomButton,
      scrollGiftController,
      autoGiftScroll,
      newGiftMessages,
    ));
    messageController.onMessageGuardBuyAdded(onMessageAdd(
      showGuardBuyBackToBottomButton,
      scrollGuardBuyController,
      autoGuardBuyScroll,
      newGuardBuyMessages,
    ));
    messageController.onMessageSuperChatAdded(onMessageAdd(
      showSuperChatBackToBottomButton,
      scrollSuperChatController,
      autoSuperChatScroll,
      newSuperChatMessages,
    ));
    messageController.onMessageOtherAdded(onMessageAdd(
      showOtherBackToBottomButton,
      scrollOtherController,
      autoOtherScroll,
      newOtherMessages,
    ));
    // 检测当前滑动距离是不是在底部
    scrollAllController.addListener(addList(showAllBackToBottomButton,
        scrollAllController, autoAllScroll, newAllMessages));
    scrollDanmuController.addListener(addList(showDanmuBackToBottomButton,
        scrollDanmuController, autoDanmuScroll, newDanmuMessages));
    scrollGiftController.addListener(addList(showGiftBackToBottomButton,
        scrollGiftController, autoGiftScroll, newGiftMessages));
    scrollGuardBuyController.addListener(addList(showGuardBuyBackToBottomButton,
        scrollGuardBuyController, autoGuardBuyScroll, newGuardBuyMessages));
    scrollSuperChatController.addListener(addList(
        showSuperChatBackToBottomButton,
        scrollSuperChatController,
        autoSuperChatScroll,
        newSuperChatMessages));
    scrollOtherController.addListener(addList(showOtherBackToBottomButton,
        scrollOtherController, autoOtherScroll, newOtherMessages));
    ttsTask();
    setupLiveEventListeners();
    setupStatsEventListeners();
    statsTask();
    messageHandler.setupEventHandlers();
  }

  @override
  void dispose() {
    messageHandler.stop();
    cancelLiveEventListeners();
    cancelStatsEventListeners();
    stopStatsTask();
    messageController.clearMessages();
    clearMessagesQueue();
    stopTtsTask();
    super.dispose();
  }

  void _updateDividerPosition(DragUpdateDetails details) {
    setState(() {
      _dividerPosition += details.delta.dy / context.size!.height;
      _dividerPosition = _dividerPosition.clamp(0.2, 0.8);
    });
  }

  // 定义一个用于显示统计信息的小部件
  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  // 新建一个方法来根据 filterd 状态构建消息小部件
  Widget _buildMessageWidget(RxList messages, int index) {
    return Text(
      messages[index]['msg'],
      style: messages[index]['filterd']
          ? const TextStyle(color: Colors.grey) // 当 filterd 为 true 时，文本颜色为灰色
          : null,
    );
  }

  Widget _buildBackToBottomButton(RxBool showBackToBottomButton,
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

  Widget _buildMessageList(RxList messages, RxBool showBackToBottomButton,
      ScrollController scrollController, RxInt newMessages) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 0),
          controller: scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageWidget(messages, index);
          },
        ),
        if (showBackToBottomButton.value)
          _buildBackToBottomButton(
              showBackToBottomButton, scrollController, newMessages),
      ],
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
            Obx(
              () => ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    isExpanded1 = !isExpanded1;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (_, __) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                              '输出队列 ${messageController.messagesQueueLength.value} 条'),
                          Text('当前延迟 ${messageController.delay.value} 秒'),
                        ],
                      );
                    },
                    isExpanded: isExpanded1,
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                ],
              ),
            ),
            Expanded(
              flex: (_dividerPosition * 100).round(),
              child: Obx(
                () => Scaffold(
                  appBar: TabBar(
                    controller: _tabController,
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    tabs: tabs,
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMessageList(
                          messageController.messagesAll,
                          showAllBackToBottomButton,
                          scrollAllController,
                          newAllMessages),
                      _buildMessageList(
                          messageController.messagesDanmu,
                          showDanmuBackToBottomButton,
                          scrollDanmuController,
                          newDanmuMessages),
                      _buildMessageList(
                          messageController.messagesGift,
                          showGiftBackToBottomButton,
                          scrollGiftController,
                          newGiftMessages),
                      _buildMessageList(
                          messageController.messagesGuardBuy,
                          showGuardBuyBackToBottomButton,
                          scrollGuardBuyController,
                          newGuardBuyMessages),
                      _buildMessageList(
                          messageController.messagesSuperChat,
                          showSuperChatBackToBottomButton,
                          scrollSuperChatController,
                          newSuperChatMessages),
                      _buildMessageList(
                          messageController.messagesOther,
                          showOtherBackToBottomButton,
                          scrollOtherController,
                          newOtherMessages),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onVerticalDragUpdate: _updateDividerPosition,
              child: Container(
                height: 20,
                color: Colors.grey[400]?.withOpacity(0.2),
                child: const Center(
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              flex: ((1 - _dividerPosition) * 100).round(),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double buttonWidth = constraints.maxWidth / 2;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 启动/停止按钮和清空按钮。
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled
                              ? () async {
                                  _isButtonEnabled = false; // 禁用按钮
                                  _toggleRunningStatus();
                                  _vibrateAndUpdateButtonText();
                                  // 两秒后重新启用按钮
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  _isButtonEnabled = true;
                                  setState(() {});
                                }
                              : null, // 如果按钮不可用，则禁用点击事件
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(
                              Size(buttonWidth, double.infinity),
                            ),
                          ),
                          child: Text(buttonText),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isRunning ? handleFlush : null,
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(
                              Size(buttonWidth, double.infinity),
                            ),
                          ),
                          child: const Text('清空'),
                        ),
                      ),
                      // TTS语速控制按钮。
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 调整按钮顺序
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isRunning ? handleTTSVolumeMinus : null,
                                child: const Text('语速-1'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isRunning ? handleTTSRatePlus : null,
                                child: const Text('语速+1'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 弹幕和礼物控制按钮，用于浏览历史弹幕和礼物。
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              isRunning ? handleReadNewestMessages : null,
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(
                              Size(buttonWidth, double.infinity),
                            ),
                          ),
                          child: const Text('回到最新弹幕'),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isRunning
                                    ? handleReadNextHistoryDanmu
                                    : null,
                                child: const Text('查看上一条弹幕'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isRunning
                                    ? handleReadLastHistoryDanmu
                                    : null,
                                child: const Text('查看下一条弹幕'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isRunning
                                    ? handleReadNextGiftMessages
                                    : null,
                                child: const Text('查看上一条礼物'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isRunning
                                    ? handleReadLastGiftMessages
                                    : null,
                                child: const Text('查看下一条礼物'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 切换运行状态，启动或停止弹幕接收和处理。
  void _toggleRunningStatus() async {
    if (!isRunning) {
      messageHandler.run();
    } else {
      messageHandler.stop();
    }
    isRunning = !isRunning;
    setState(() {});
  }

  // 振动设备并更新按钮文本，用于反馈用户操作。
  void _vibrateAndUpdateButtonText() {
    Vibration.vibrate(pattern: [30, 30, 30, 30], intensities: [255, 0, 255, 0]);
    setState(() {
      buttonText = isRunning ? '停止' : '开始';
    });
  }
}
