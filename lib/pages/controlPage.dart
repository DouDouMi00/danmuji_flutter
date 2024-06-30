// controlPage.dart
import 'package:flutter/material.dart';
import '../../services/keyboard.dart';
import '../../services/blivedm.dart';
import '../../services/live.dart';
import '../../services/tts.dart';
import 'package:vibration/vibration.dart';

// 控制面板页面，用于管理直播中的各种控制功能，如弹幕阅读、礼物阅读及TTS控制。
class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  _ControlPageState createState() => _ControlPageState();
}

// ControlPage的状态类，管理页面的动态更新和事件处理。
class _ControlPageState extends State<ControlPage> {
  // 是否处于运行状态的标志。
  bool isRunning = false;
  // 操作按钮的文本内容，根据运行状态动态改变。
  String buttonText = '开始';
  // 弹幕接收器，用于接收和处理弹幕信息。
  late DanmakuReceiver receiver;
  // 消息处理程序，用于处理各种消息，如弹幕、礼物等。
  late MessageHandler messageHandler;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 32;
    double buttonWidth = screenWidth / 2; // 假设每行最多两个按钮

    return Scaffold(
      appBar: AppBar(title: const Text('控制面板')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 启动/停止按钮和清空按钮。
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  _toggleRunningStatus();
                  _vibrateAndUpdateButtonText();
                },
                child: Text(buttonText),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: isRunning ? handleFlush : null,
                child: const Text('清空'),
              ),
            ),

            // TTS语速控制按钮。
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isRunning ? handleTTSRatePlus : null,
                    child: const Text('语速+1'),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isRunning ? handleTTSVolumeMinus : null,
                    child: const Text('语速-1'),
                  ),
                ),
              ],
            ),
            // 弹幕和礼物控制按钮，用于浏览历史弹幕和礼物。
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: isRunning ? handleReadNewestMessages : null,
                child: const Text('回到最新弹幕'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isRunning ? handleReadNextHistoryDanmu : null,
                    child: const Text('查看上一条弹幕'),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isRunning ? handleReadLastHistoryDanmu : null,
                    child: const Text('查看下一条弹幕'),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isRunning ? handleReadNextGiftMessages : null,
                    child: const Text('查看上一条礼物'),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isRunning ? handleReadLastGiftMessages : null,
                    child: const Text('查看下一条礼物'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 切换运行状态，启动或停止弹幕接收和处理。
  void _toggleRunningStatus() {
    setState(() {
      isRunning = !isRunning;
    });
    if (isRunning) {
      receiver = DanmakuReceiver();
      messageHandler = MessageHandler(receiver);
      messageHandler.setupEventHandlers();
      ttsTask();
    } else {
      receiver.dispose();
      stopTtsTask();
    }
  }

  // 振动设备并更新按钮文本，用于反馈用户操作。
  void _vibrateAndUpdateButtonText() {
    Vibration.vibrate(
        pattern: [0, 10, 1000, 50], intensities: [25, 50, 100, 200]);
    setState(() {
      buttonText = isRunning ? '停止' : '开始';
    });
  }
}
