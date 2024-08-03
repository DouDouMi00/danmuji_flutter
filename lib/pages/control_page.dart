// control_page.dart
import 'package:flutter/material.dart';
import '/services/keyboard.dart';
import '/services/blivedm.dart';
import '/services/live.dart';
import '/services/tts.dart';
import 'package:vibration/vibration.dart';
import '/services/logger.dart';
import 'package:get/get.dart';

late MessageQueueController messageController;
late ScrollController scrollController;
bool showBackToBottomButton = false;
int autoScroll = 0;
int newMessages = 0;

class MessageQueueController extends GetxController {
  // 创建一个RxList作为消息队列
  final messages = <String>[].obs;

  // 发送消息的方法
  void sendMessage(String message) async {
    messages.add(message);
    if (showBackToBottomButton == false) {
      autoScroll += 1;
      await scrollController
          .animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )
          .whenComplete(() {
        autoScroll -= 1;
      });
    } else {
      newMessages += 1;
    }
  }

  // 清空消息队列的方法
  void clearMessages() {
    messages.clear();
  }
}

// 控制面板页面，用于管理直播中的各种控制功能，如弹幕阅读、礼物阅读及TTS控制。
class ControlPage extends StatefulWidget {
  const ControlPage({super.key});
  @override
  ControlPageState createState() => ControlPageState();
}

// ControlPage的状态类，管理页面的动态更新和事件处理。
class ControlPageState extends State<ControlPage> {
  // 是否处于运行状态的标志。
  bool isRunning = false;
  // 操作按钮的文本内容，根据运行状态动态改变。
  String buttonText = '开始';
  // 弹幕接收器，用于接收和处理弹幕信息。
  late DanmakuReceiver receiver;
  // 消息处理程序，用于处理各种消息，如弹幕、礼物等。
  late MessageHandler messageHandler;
  double _dividerPosition = 0.6;

  @override
  void initState() {
    super.initState();
    messageController = Get.put(MessageQueueController());
    scrollController = ScrollController();
    // 检测当前滑动距离是不是在底部
    scrollController.addListener(() {
      if (scrollController.offset < scrollController.position.maxScrollExtent &&
          autoScroll <= 0) {
        setState(() {
          showBackToBottomButton = true;
        });
      } else if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          showBackToBottomButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    try {
      receiver.dispose();
    } catch (e) {
      logger.info(e);
    } finally {
      stopTtsTask();
      messageController.clearMessages();
      scrollController.dispose();
    }
  }

  void _updateDividerPosition(DragUpdateDetails details) {
    setState(() {
      _dividerPosition += details.delta.dy / context.size!.height;
      _dividerPosition = _dividerPosition.clamp(0.1, 0.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('控制面板')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: (_dividerPosition * 100).round(),
              child: Obx(
                () => Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      itemCount: messageController.messages.length,
                      itemBuilder: (context, index) {
                        return Text(messageController.messages[index]);
                      },
                    ),
                    // 回到底部的按钮，只有当不在底部时才显示
                    if (showBackToBottomButton)
                      Align(
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
                              setState(() {
                                newMessages = 0;
                                showBackToBottomButton = false;
                              });
                            },
                            child: newMessages != 0
                                ? Text('新消息 $newMessages 条')
                                : const Text('回到底部'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onVerticalDragUpdate: _updateDividerPosition,
              child: Container(
                height: 20,
                color: Colors.grey[100],
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
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       Vibration.vibrate(
                    //           pattern: [30, 30, 30, 30],
                    //           intensities: [255, 0, 255, 0]);
                    //     },
                    //     style: ButtonStyle(
                    //       minimumSize: WidgetStateProperty.all<Size>(
                    //         Size(buttonWidth,
                    //             double.infinity),
                    //       ),
                    //     ),
                    //     child: const Text("振动测试按钮"),
                    //   ),
                    // ),
                    // 启动/停止按钮和清空按钮。
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _toggleRunningStatus();
                          _vibrateAndUpdateButtonText();
                        },
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
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isRunning ? handleTTSRatePlus : null,
                              child: const Text('语速+1'),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  isRunning ? handleTTSVolumeMinus : null,
                              child: const Text('语速-1'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 弹幕和礼物控制按钮，用于浏览历史弹幕和礼物。
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isRunning ? handleReadNewestMessages : null,
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
                              onPressed:
                                  isRunning ? handleReadNextHistoryDanmu : null,
                              child: const Text('查看上一条弹幕'),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  isRunning ? handleReadLastHistoryDanmu : null,
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
                              onPressed:
                                  isRunning ? handleReadNextGiftMessages : null,
                              child: const Text('查看上一条礼物'),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  isRunning ? handleReadLastGiftMessages : null,
                              child: const Text('查看下一条礼物'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 切换运行状态，启动或停止弹幕接收和处理。
  void _toggleRunningStatus() async {
    setState(() {
      isRunning = !isRunning;
    });

    if (isRunning) {
      receiver = DanmakuReceiver();
      messageHandler = MessageHandler(receiver);
      messageHandler.setupEventHandlers();
      await ttsTask();
    } else {
      stopTtsTask();
      receiver.dispose();
    }
  }

  // 振动设备并更新按钮文本，用于反馈用户操作。
  void _vibrateAndUpdateButtonText() {
    Vibration.vibrate(pattern: [30, 30, 30, 30], intensities: [255, 0, 255, 0]);
    setState(() {
      buttonText = isRunning ? '停止' : '开始';
    });
  }
}
