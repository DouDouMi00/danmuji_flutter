// tts_engines_setting_page.dart
import 'dart:io' show Platform;

import 'package:danmuji_flutter/services/config.dart';
import 'package:danmuji_flutter/widgets/obscure_text_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsEnginesSettingPage extends StatelessWidget {
  TtsEnginesSettingPage({super.key}) {
    // 初始化状态
    volume.value = configService.configRx.value.dynamicConfig.tts.volume;
    pitch.value = configService.configRx.value.dynamicConfig.tts.pitch;
    rate.value = configService.configRx.value.dynamicConfig.tts.rate;
    engine.value = configService.configRx.value.dynamicConfig.tts.engine;
    language.value = configService.configRx.value.dynamicConfig.tts.language;
    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  final FlutterTts flutterTts = FlutterTts();
  final ConfigService configService = Get.find<ConfigService>();

  // 使用 Rx 来管理响应式状态
  final RxDouble volume = 0.0.obs;
  final RxDouble pitch = 0.0.obs;
  final RxDouble rate = 0.0.obs;
  final RxBool isCurrentLanguageInstalled = false.obs;
  final RxString engine = ''.obs;
  final RxString language = ''.obs;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // 添加一个方法来重置滑块到默认值
  void resetSlidersToDefaults() async {
    // 更新configMap
    if (isAndroid) {
      await _getresetEngineVoice();
    }
    volume.value = 1.0; // 假设这是volume的默认值
    pitch.value = 1.0; // 假设这是pitch的默认值
    rate.value = 1.0; // 假设这是rate的默认值
    if (engine.value.isNotEmpty) {
      configService.configRx.value.dynamicConfig.tts.engine = engine.value;
    }
    if (language.value.isNotEmpty) {
      configService.configRx.value.dynamicConfig.tts.language = language.value;
    }
    configService.configRx.value.dynamicConfig.tts.volume = volume.value;
    configService.configRx.value.dynamicConfig.tts.pitch = pitch.value;
    configService.configRx.value.dynamicConfig.tts.rate = rate.value;
    configService.configRx.refresh();
  }

  Future _getresetEngineVoice() async {
    engine.value = await flutterTts.getDefaultEngine;
    Map? voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      language.value = voice["locale"];
    }
  }

  List<Map<String, String>> getEnginesDropDownMenuItems(List<dynamic> engines) {
    var items = <Map<String, String>>[];
    for (dynamic type in engines) {
      if (type is String) {
        items.add({"title": type, "value": type});
      }
    }
    return items;
  }

  List<Map<String, String>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <Map<String, String>>[];
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
    if (configService.configRx.value.dynamicConfig.tts.engine.isNotEmpty) {
      engine.value = configService.configRx.value.dynamicConfig.tts.engine;
    } else {
      engine.value = await flutterTts.getDefaultEngine;
      if (engine.value.isNotEmpty) {
        configService.configRx.value.dynamicConfig.tts.engine = engine.value;
        configService.configRx.refresh();
      }
    }
    return engine.value;
  }

  Future<String?> _getDefaultVoice() async {
    if (configService.configRx.value.dynamicConfig.tts.language.isNotEmpty) {
      language.value = configService.configRx.value.dynamicConfig.tts.language;
    } else {
      Map? voice = await flutterTts.getDefaultVoice;
      if (voice != null) {
        language.value = voice["locale"];
        configService.configRx.value.dynamicConfig.tts.language =
            language.value;
        configService.configRx.refresh();
      }
    }
    return language.value;
  }

  Widget _enginesDropDownSection(List<dynamic> engines) => ListTile(
        leading: const Icon(Icons.anchor_outlined),
        title: Obx(() => Text(
            'TTS 引擎: ${configService.configRx.value.dynamicConfig.tts.engine}')),
        trailing: const Icon(Icons.navigate_next),
        onTap: () async {
          await RadioDialog(
            title: 'TTS 引擎',
            initialValue: engine.value,
            valueOptions: getEnginesDropDownMenuItems(engines),
            onChanged: (value) async {
              engine.value = value;
              configService.configRx.value.dynamicConfig.tts.engine = value;
              configService.configRx.refresh();
              await flutterTts.setEngine(value);
            },
          ).show();
        },
      );

  Future<void> _isLanguageInstalled(String language) async {
    if (isAndroid) {
      flutterTts.isLanguageInstalled(language).then((value) {
        if (!value) {
          Get.dialog(
            AlertDialog(
              title: const Text('提示'),
              content: const Text('当前语言未安装'),
              actions: <Widget>[
                TextButton(
                  child: const Text('确定'),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          );
        }
      });
    }
  }

  Widget _languageDropDownSection(List<dynamic> languages) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ListTile(
          leading: const Icon(Icons.anchor_outlined),
          title: Obx(() => Text(
              'TTS 语言: ${configService.configRx.value.dynamicConfig.tts.language}')),
          trailing: const Icon(Icons.navigate_next),
          onTap: () async {
            await RadioDialog(
              title: 'TTS 语言',
              initialValue: language.value,
              valueOptions: getLanguageDropDownMenuItems(languages),
              onChanged: (value) async {
                await _isLanguageInstalled(value);
                language.value = value;
                configService.configRx.value.dynamicConfig.tts.language = value;
                configService.configRx.refresh();
              },
            ).show();
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

  Widget _volume() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('音量调节'),
        Obx(() => Slider(
              value: volume.value,
              onChanged: (newVolume) async {
                volume.value = newVolume;
                configService.configRx.value.dynamicConfig.tts.volume =
                    volume.value;
                configService.configRx.refresh();
              },
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '音量: ${volume.value.toStringAsFixed(1)}',
            )),
      ],
    );
  }

  Widget _pitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('音调调节'),
        Obx(() => Slider(
              value: pitch.value,
              onChanged: (newPitch) async {
                pitch.value = newPitch;
                configService.configRx.value.dynamicConfig.tts.pitch =
                    pitch.value;
                configService.configRx.refresh();
              },
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '音调: ${pitch.value.toStringAsFixed(1)}',
              activeColor: Colors.red,
            )),
      ],
    );
  }

  Widget _rate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('语速调节'),
        Obx(() => Slider(
              value: rate.value,
              onChanged: (newRate) async {
                rate.value = newRate;
                configService.configRx.value.dynamicConfig.tts.rate =
                    rate.value;
                configService.configRx.refresh();
              },
              min: 0.0,
              max: 5.0,
              divisions: 25,
              label: '语速: ${rate.value.toStringAsFixed(1)}',
              activeColor: Colors.green,
            )),
      ],
    );
  }

  // 新增试听功能
  void _playSampleText() async {
    await flutterTts.stop();
    if (language.value.isNotEmpty) {
      await flutterTts.setLanguage(language.value);
    }
    if (engine.value.isNotEmpty) {
      await flutterTts.setEngine(engine.value);
    }
    // 使用当前设置的参数播放一段文本
    await flutterTts.setPitch(pitch.value);
    await flutterTts.setSpeechRate(rate.value);
    await flutterTts.setVolume(volume.value);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak('这是一个试听文本，用于测试当前的语音设置。');
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

  Widget _buildSampleButton() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使子元素间间距相等，两端对齐
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _playSampleText,
              child: const Text('试听'),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('tts 引擎配置')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView(
          children: [
            _buildSampleButton(),
            _engineSection(),
            _futureBuilder(),
            _volume(),
            _pitch(),
            _rate(),
            _buildResetButtons(),
          ],
        ),
      ),
    );
  }
}
