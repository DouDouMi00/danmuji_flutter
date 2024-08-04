// tts_engines_setting_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/services/config.dart';
import '/widgets/obscure_text_field.dart';

class TtsEnginesSettingPage extends StatefulWidget {
  final DefaultConfig configMap;

  const TtsEnginesSettingPage({super.key, required this.configMap});

  @override
  TtsEnginesSettingPageState createState() => TtsEnginesSettingPageState();
}

class TtsEnginesSettingPageState extends State<TtsEnginesSettingPage> {
  FlutterTts flutterTts = FlutterTts();
  late double volume;
  late double pitch;
  late double rate;
  bool isCurrentLanguageInstalled = false;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  String? engine;
  String? language;
  late DefaultConfig configMap;

  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as DefaultConfig;
    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  // 添加一个方法来重置滑块到默认值
  void resetSlidersToDefaults() async {
    // 更新configMap
    if (isAndroid) {
      await _getresetEngineVoice();
    }
    volume = 1.0; // 假设这是volume的默认值
    pitch = 1.0; // 假设这是pitch的默认值
    rate = 1.0; // 假设这是rate的默认值
    setState(() {
      if (engine != null) {
        configMap.dynamicConfig.tts.engine = engine!;
      }
      if (language != null) {
        configMap.dynamicConfig.tts.language = language!;
      }
      configMap.dynamicConfig.tts.volume = volume;
      configMap.dynamicConfig.tts.pitch = pitch;
      configMap.dynamicConfig.tts.rate = rate;
    });
    await updateConfigMap(configMap);
  }

  Future _getresetEngineVoice() async {
    engine = await flutterTts.getDefaultEngine;
    Map? voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      language = voice["locale"];
    }
  }

  List<Map<String, dynamic>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <Map<String, dynamic>>[];
    for (dynamic type in engines) {
      if (type is String) {
        items.add({"title": type, "value": type});
      }
    }
    return items;
  }

  List<Map<String, dynamic>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <Map<String, dynamic>>[];
    for (dynamic type in languages) {
      if (type is String) {
        items.add({"title": type, "value": type});
      }
    }
    return items;
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;
  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<String?> _getDefaultEngine() async {
    if (configMap.dynamicConfig.tts.engine != "") {
      engine = configMap.dynamicConfig.tts.engine;
    } else {
      engine = await flutterTts.getDefaultEngine;
      if (engine != null) {
        configMap.dynamicConfig.tts.engine = engine!;
        await updateConfigMap(configMap);
      }
    }
    return engine;
  }

  Future<String?> _getDefaultVoice() async {
    if (configMap.dynamicConfig.tts.language != "") {
      language = configMap.dynamicConfig.tts.language;
    } else {
      Map? voice = await flutterTts.getDefaultVoice;
      if (voice != null) {
        language = voice["locale"];
        configMap.dynamicConfig.tts.language = language!;
        await updateConfigMap(configMap);
      }
    }
    return language;
  }

  Widget _enginesDropDownSection(List<dynamic> engines) => ListTile(
        leading: const Icon(Icons.anchor_outlined),
        title: Text('TTS 引擎: ${configMap.dynamicConfig.tts.engine}'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () {
          showRadioDialog(
            RadioDialogParams(
              title: 'TTS 引擎',
              initialValue: engine,
              valueOptions: getEnginesDropDownMenuItems(engines),
              onSaved: (value) async {
                setState(() {
                  configMap.dynamicConfig.tts.engine = value;
                });
                await updateConfigMap(configMap);
              },
            ),
          );
        },
      );

  Widget _languageDropDownSection(List<dynamic> languages) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ListTile(
          leading: const Icon(Icons.anchor_outlined),
          title: Text('TTS 语言: ${configMap.dynamicConfig.tts.language}'),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            showRadioDialog(
              RadioDialogParams(
                title: 'TTS 语言',
                initialValue: language,
                valueOptions: getLanguageDropDownMenuItems(languages),
                onSaved: (value) async {
                  setState(() {
                    configMap.dynamicConfig.tts.language = value;
                  });
                  await updateConfigMap(configMap);
                },
              ),
            );
          },
        ),
      ]);

  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data as List<dynamic>);
            } else if (snapshot.hasError) {
              return const Text('Error loading engines...');
            } else {
              return const Text('Loading engines...');
            }
          });
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data as List<dynamic>);
        } else if (snapshot.hasError) {
          return const Text('Error loading languages...');
        } else {
          return const Text('Loading Languages...');
        }
      });

  Widget _buildSliders() {
    return Column(
      children: [
        _volume(),
        _pitch(),
        _rate(),
      ],
    );
  }

  Widget _volume() {
    volume = configMap.dynamicConfig.tts.volume;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('音量调节'),
        Slider(
          value: volume,
          onChanged: (newVolume) async {
            setState(() {
              volume = newVolume;
              configMap.dynamicConfig.tts.volume = volume;
            });
            await updateConfigMap(configMap);
          },
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: '音量: ${volume.toStringAsFixed(1)}',
        ),
      ],
    );
  }

  Widget _pitch() {
    pitch = configMap.dynamicConfig.tts.pitch;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('音调调节'),
        Slider(
          value: pitch,
          onChanged: (newPitch) async {
            setState(() {
              pitch = newPitch;
              configMap.dynamicConfig.tts.pitch = pitch;
            });
            await updateConfigMap(configMap);
          },
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: '音调: ${pitch.toStringAsFixed(1)}',
          activeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _rate() {
    rate = configMap.dynamicConfig.tts.rate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('语速调节'),
        Slider(
          value: rate,
          onChanged: (newRate) async {
            setState(() {
              rate = newRate;
              configMap.dynamicConfig.tts.rate = rate;
            });
            await updateConfigMap(configMap);
          },
          min: 0.0,
          max: 5.0,
          divisions: 25,
          label: '语速: ${rate.toStringAsFixed(1)}',
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildResetButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使子元素间间距相等，两端对齐
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: resetSlidersToDefaults,
              child: const Text('重置'),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并启用返回按钮
        title: const Text('tts 引擎配置')
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _engineSection(),
              _futureBuilder(),
              _buildSliders(),
              _buildResetButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
