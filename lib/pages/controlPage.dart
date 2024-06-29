// controlPage.dart
import 'package:flutter/material.dart';
import '../../services/keyboard.dart';
import '../../services/blivedm.dart';
import '../../services/live.dart';
import '../../services/tts.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool isRunning = false;
  String buttonText = '开始';
  late DanmakuReceiver receiver;
  late MessageHandler messageHandler;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('控制面板'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // 切换运行状态
                    isRunning = !isRunning;
                    // 根据状态决定按钮文本
                    buttonText = isRunning ? '停止' : '开始';
                  });
                  if (isRunning) {
                    // 启动程序
                    receiver = DanmakuReceiver();
                    messageHandler = MessageHandler(receiver);
                    messageHandler.setupEventHandlers();
                    ttsTask();
                  } else {
                    receiver.dispose();
                    stopTtsTask();
                  }
                },
                child: Text(buttonText), // 使用buttonText动态显示按钮文本
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleFlush : null,
                child: const Text('清空'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleTTSRatePlus : null,
                child: const Text('语速+1'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleTTSVolumeMinus : null,
                child: const Text('语速-1'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleReadNewestMessages : null,
                child: const Text('回到最新弹幕'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleReadNextHistoryDanmu : null,
                child: const Text('查看上一条弹幕'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleReadLastHistoryDanmu : null,
                child: const Text('查看下一条弹幕'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleReadNextGiftMessages : null,
                child: const Text('查看上一条礼物'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? handleReadLastGiftMessages : null,
                child: const Text('查看下一条礼物'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
