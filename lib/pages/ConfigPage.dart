import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/config.dart';
import '../services/blivedm.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConfigEditPage extends StatefulWidget {
  const ConfigEditPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConfigEditPageState createState() => _ConfigEditPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _ConfigEditPageState extends State<ConfigEditPage> {
  late Future<Map<String, dynamic>> _configFuture;
  Config config = Config();
  String dmtext = '';

  FlutterTts flutterTts = FlutterTts();
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 2.0;
  bool isCurrentLanguageInstalled = false;
  TtsState ttsState = TtsState.stopped;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  String? engine;
  String? language;

  bool isRunning = false;
  String buttonText = '开始';
  late DanmakuReceiver receiver;

  @override
  void initState() {
    super.initState();
    _configFuture = loadConfig();
    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  Future<Map<String, dynamic>> loadConfig() async {
    await config.initConfig();
    return config.getConfigMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置编辑')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _configFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final configMap = snapshot.data as Map<String, dynamic>;
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    _buildConfig(configMap),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;
  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    engine = await flutterTts.getDefaultEngine;
  }

  Future<void> _getDefaultVoice() async {
    Map? voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      language = voice["locale"];
    }
  }

  Widget _enginesDropDownSection(List<dynamic> engines) => Container(
        padding: const EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );
  Widget _languageDropDownSection(List<dynamic> languages) => Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data as List<dynamic>);
        } else if (snapshot.hasError) {
          return const Text('Error loading languages...');
        } else
          return const Text('Loading Languages...');
      });
  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data as List<dynamic>);
            } else if (snapshot.hasError) {
              return const Text('Error loading engines...');
            } else
              return const Text('Loading engines...');
          });
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }

  Widget _buildSliders() {
    return Column(
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 4.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }

  Widget _buildConfig(Map<String, dynamic> configMap) {
    final uidController = TextEditingController(
        text: configMap['kvdb']['bili']['uid'].toString());
    final buvid3Controller =
        TextEditingController(text: configMap['kvdb']['bili']['buvid3']);
    final sessdataController =
        TextEditingController(text: configMap['kvdb']['bili']['sessdata']);
    final jctController =
        TextEditingController(text: configMap['kvdb']['bili']['jct']);
    final liveRoomIDController = TextEditingController(
        text: configMap['engine']['bili']['liveID'].toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BiliBili Account Settings'),
        TextFormField(
          controller: uidController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'UID'),
        ),
        TextFormField(
          controller: buvid3Controller,
          decoration: const InputDecoration(labelText: 'Buvid3'),
        ),
        TextFormField(
          controller: sessdataController,
          decoration: const InputDecoration(labelText: 'Sessdata'),
        ),
        TextFormField(
          controller: jctController,
          decoration: const InputDecoration(labelText: 'JCT'),
        ),
        TextFormField(
          controller: liveRoomIDController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '直播间ID'),
        ),
        _engineSection(),
        _futureBuilder(),
        _buildSliders(),
        ElevatedButton(
          onPressed: () {
            // 用户点击按钮时获取输入
            Map<String, dynamic> newInputConfig = {
              'kvdb': {
                'bili': {
                  'uid': int.parse(uidController.text),
                  'buvid3': buvid3Controller.text,
                  'sessdata': sessdataController.text,
                  'jct': jctController.text,
                }
              },
              'engine': {
                'bili': {
                  'liveID': int.parse(liveRoomIDController.text),
                }
              }
            };
            configMap = newInputConfig;
            config.updateConfigMap(newInputConfig);
          },
          child: const Text('保存'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // 切换运行状态
              isRunning = !isRunning;
              // 根据状态决定按钮文本
              buttonText = isRunning ? '停止' : '开始';
            });

            if (isRunning) {
              // 启动程序
              receiver = DanmakuReceiver(configMap['engine']['bili']['liveID']);
              receiver.onDanmaku((data) async {
                await flutterTts.awaitSpeakCompletion(true);
                while (isRunning) {
                  // 添加对isRunning的检查
                  if (ttsState == TtsState.stopped) {
                    ttsState = TtsState.playing;
                    flutterTts.setEngine(engine!);
                    flutterTts.setLanguage(language!);
                    flutterTts.setVolume(volume);
                    flutterTts.setSpeechRate(rate);
                    flutterTts.setPitch(pitch);
                    await flutterTts
                        .speak("${data["info"][2][1]}说:${data["info"][1]}");
                    flutterTts.setCompletionHandler(() {
                      ttsState = TtsState.stopped;
                    });
                    print("${data["info"][2][1]}说：${data["info"][1]}");
                    break;
                  } else {
                    // 需要延迟
                    await Future.delayed(const Duration(seconds: 1));
                  }
                }
              });
            } else {
              receiver.dispose();
            }
          },
          child: Text(buttonText), // 使用buttonText动态显示按钮文本
        ),
        // 文本框展示配置
        Text('当前配置: $configMap'),
      ],
    );
  }
}
