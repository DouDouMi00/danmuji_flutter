// tts_engines_setting_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/services/config.dart';

class TtsEnginesSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const TtsEnginesSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _TtsEnginesSettingPageState createState() => _TtsEnginesSettingPageState();
}

class _TtsEnginesSettingPageState extends State<TtsEnginesSettingPage> {
  FlutterTts flutterTts = FlutterTts();
  late double volume;
  late double pitch;
  late double rate;
  bool isCurrentLanguageInstalled = false;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  String? engine;
  String? language;
  late Map<String, dynamic> configMap;

  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as Map<String, dynamic>;
    if (isAndroid) {
      _getDefaultEngine(configMap);
      _getDefaultVoice(configMap);
    }
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

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
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
      configMap["dynamic"]['tts']['engine'] = engine;
    });
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      configMap["dynamic"]['tts']['language'] = language;
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
  Future<String?> _getDefaultEngine(configMap) async {
    if (configMap['dynamic']['tts']['engine'] != "") {
      engine = configMap['dynamic']['tts']['engine'];
    } else {
      engine = await flutterTts.getDefaultEngine;
    }
    return engine;
  }

  Future<String?> _getDefaultVoice(configMap) async {
    if (configMap['dynamic']['tts']['language'] != "") {
      language = configMap['dynamic']['tts']['language'];
    } else {
      Map? voice = await flutterTts.getDefaultVoice;
      if (voice != null) {
        language = voice["locale"];
      }
    }
    return language;
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
        } else {
          return const Text('Loading Languages...');
        }
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
            } else {
              return const Text('Loading engines...');
            }
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
    volume = configMap["dynamic"]['tts']['volume'];
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() {
            volume = newVolume;
            configMap["dynamic"]['tts']['volume'] = volume;
          });
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    pitch = configMap["dynamic"]['tts']['pitch'];
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() {
          pitch = newPitch;
          configMap["dynamic"]['tts']['pitch'] = pitch;
        });
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    rate = configMap["dynamic"]['tts']['rate'];
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() {
          rate = newRate;
          configMap["dynamic"]['tts']['rate'] = rate;
        });
      },
      min: 0.0,
      max: 5.0,
      divisions: 25,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并启用返回按钮
        title: const Text('tts 引擎配置'),
        leading: IconButton(
          // 这里是返回按钮
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 使子元素间间距相等，两端对齐
                children: [
                  Expanded(
                    // 使按钮自适应宽度并均匀分配空间
                    child: ElevatedButton(
                      onPressed: () {
                        updateConfigMap(configMap);
                      },
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
              _engineSection(),
              _futureBuilder(),
              _buildSliders(),
            ],
          ),
        ),
      ),
    );
  }
}
