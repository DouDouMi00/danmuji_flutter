import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/config.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConfigEditPage extends StatefulWidget {
  const ConfigEditPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConfigEditPageState createState() => _ConfigEditPageState();
}

class _ConfigEditPageState extends State<ConfigEditPage> {
  late Future<Map<String, dynamic>> _configFuture;

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
    loadConfig().then((configMap) {
      if (isAndroid) {
        _getDefaultEngine(configMap);
        _getDefaultVoice(configMap);
      }
    });
    _configFuture = loadConfig();
  }

  Future<Map<String, dynamic>> loadConfig() async {
    return getConfigMap();
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              configMap = snapshot.data as Map<String, dynamic>;
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

  Widget _buildConfig(Map<String, dynamic> configMap) {
    // 假设你有如下定义的选项列表，根据实际需求调整
    final List<int> guardLevelOptions = [0, 1, 2]; // 大航海等级选项
    final List<int> medalLevelOptions = [0, 5, 10, 15, 20, 25]; // 粉丝牌等级选项
    final List<int> lengthOptions = [0, 5, 10, 15, 20]; // 文本长度选项
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BiliBili Account Settings'),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使子元素间间距相等，两端对齐
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

        TextFormField(
          controller: TextEditingController(
              text: configMap['kvdb']['bili']['uid'].toString()),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'UID'),
          onChanged: (value) {
            setState(() {
              configMap['kvdb']['bili']['uid'] = int.parse(value);
            });
          },
        ),
        TextFormField(
          obscureText: true,
          controller:
              TextEditingController(text: configMap['kvdb']['bili']['Buvid3']),
          decoration: const InputDecoration(labelText: 'Buvid3'),
          onChanged: (value) {
            setState(() {
              configMap['kvdb']['bili']['buvid3'] = value;
            });
          },
        ),
        TextFormField(
          obscureText: true,
          controller: TextEditingController(
              text: configMap['kvdb']['bili']['sessdata']),
          decoration: const InputDecoration(labelText: 'Sessdata'),
          onChanged: (value) {
            setState(() {
              configMap['kvdb']['bili']['sessdata'] = value;
            });
          },
        ),
        TextFormField(
          obscureText: true,
          controller:
              TextEditingController(text: configMap['kvdb']['bili']['jct']),
          decoration: const InputDecoration(labelText: 'JCT'),
          onChanged: (value) {
            setState(() {
              configMap['kvdb']['bili']['jct'] = value;
            });
          },
        ),
        TextFormField(
          controller: TextEditingController(
              text: configMap['engine']['bili']['liveID'].toString()),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '直播间ID'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['engine']['bili']['liveID'] = 0;
              } else {
                configMap['engine']['bili']['liveID'] = int.parse(value);
              }
            });
          },
        ),
        _engineSection(),
        _futureBuilder(),
        _buildSliders(),
        const Text('弹幕过滤器'),
        // 启用弹幕朗读
        SwitchListTile(
          title: const Text('启用弹幕朗读'),
          value: configMap['dynamic']['filter']['danmu']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['danmu']['enable'] = value;
            });
          },
        ),
        // 启用纯标点符号弹幕朗读
        SwitchListTile(
          title: const Text('启用纯标点符号弹幕朗读'),
          value: configMap['dynamic']['filter']['danmu']['symbolEnable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['danmu']['symbolEnable'] = value;
            });
          },
        ),
        // 启用纯表情弹幕朗读
        SwitchListTile(
          title: const Text('启用纯表情弹幕朗读'),
          value: configMap['dynamic']['filter']['danmu']['emojiEnable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['danmu']['emojiEnable'] = value;
            });
          },
        ),
        // 启用大航海头衔朗读
        SwitchListTile(
          title: const Text('启用大航海头衔朗读'),
          value: configMap['dynamic']['filter']['danmu']
              ['readfansMedalGuardLevel'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['danmu']
                  ['readfansMedalGuardLevel'] = value;
            });
          },
        ),
        // 启用粉丝勋章等级播报
        SwitchListTile(
          title: const Text('启用粉丝勋章等级播报'),
          value: configMap['dynamic']['filter']["danmu"]['readfansMedalName'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']["danmu"]['readfansMedalName'] =
                  value;
            });
          },
        ),
        // 去除短时间内重复弹幕
        SwitchListTile(
          title: const Text('去除短时间内重复弹幕'),
          value: configMap['dynamic']['filter']['danmu']['deduplicate'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['danmu']['deduplicate'] = value;
            });
          },
        ),
        // 粉丝牌必须为本直播间
        SwitchListTile(
          title: const Text('粉丝牌必须为本直播间'),
          value: configMap['dynamic']['filter']["danmu"]
              ['isFansMedalBelongToLive'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']["danmu"]
                  ['isFansMedalBelongToLive'] = value;
            });
          },
        ),
        // 大航海大于等于
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: '大航海大于等于'),
          value: configMap['dynamic']['filter']["danmu"]
              ['fansMedalGuardLevelBigger'],
          items: guardLevelOptions.map((level) {
            return DropdownMenuItem<int>(
              value: level,
              child: Text('$level'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                configMap['dynamic']['filter']["danmu"]
                    ['fansMedalGuardLevelBigger'] = value;
              });
            }
          },
        ),

// 粉丝牌等级大于等于
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: '粉丝牌等级大于等于'),
          value: configMap['dynamic']['filter']["danmu"]
              ['fansMedalLevelBigger'],
          items: medalLevelOptions.map((level) {
            return DropdownMenuItem<int>(value: level, child: Text('$level'));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                configMap['dynamic']['filter']["danmu"]
                    ['fansMedalLevelBigger'] = value;
              });
            }
          },
        ),

        // 文本长度小于等于
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: '文本长度小于等于'),
          value: configMap['dynamic']['filter']['danmu']['lengthShorter'],
          items: lengthOptions.map((length) {
            return DropdownMenuItem<int>(
              value: length,
              child: Text('$length'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                configMap['dynamic']['filter']['danmu']['lengthShorter'] =
                    value;
              });
            }
          },
        ),

        // "blacklistKeywords": [],黑名单关键词(逗号分隔)
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['danmu']['blacklistKeywords']
                  .toString()),
          decoration: const InputDecoration(labelText: '黑名单用户UID(逗号分隔)'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['danmu']
                    ['blacklistKeywords'] = [];
              } else if (value.contains(',')) {
                configMap['dynamic']['filter']['danmu']['blacklistKeywords'] =
                    value.split(',');
              } else {
                configMap['dynamic']['filter']['danmu']
                    ['blacklistKeywords'] = [value];
              }
            });
          },
        ),
        // "blacklistUsers": [],黑名单用户UID(逗号分隔)
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['danmu']['blacklistUsers']
                  .toString()),
          decoration: const InputDecoration(labelText: '黑名单用户UID(逗号分隔)'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['danmu']['blacklistUsers'] = [];
                return;
              } else if (value.contains(',')) {
                configMap['dynamic']['filter']['danmu']['blacklistUsers'] =
                    value.split(',');
              } else {
                configMap['dynamic']['filter']['danmu']
                    ['blacklistUsers'] = [value];
              }
            });
          },
        ),
        // "whitelistKeywords": []白名单关键词(逗号分隔)
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['danmu']['whitelistKeywords']
                  .toString()),
          decoration: const InputDecoration(labelText: '白名单关键词(逗号分隔)'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['danmu']
                    ['whitelistKeywords'] = [];
                return;
              } else if (value.contains(',')) {
                configMap['dynamic']['filter']['danmu']['whitelistKeywords'] =
                    value.split(',');
              } else {
                configMap['dynamic']['filter']['danmu']
                    ['whitelistKeywords'] = [value];
              }
            });
          },
        ),
        // "whitelistUsers": [],白名单用户UID(逗号分隔)
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['danmu']['whitelistUsers']
                  .toString()),
          decoration: const InputDecoration(labelText: '白名单用户UID(逗号分隔)'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['danmu']['whitelistUsers'] = [];
                return;
              } else if (value.contains(',')) {
                configMap['dynamic']['filter']['danmu']['whitelistUsers'] =
                    value.split(',');
              } else {
                configMap['dynamic']['filter']['danmu']
                    ['whitelistUsers'] = [value];
              }
            });
          },
        ),
        // 礼物过滤器 SwitchListTile
        const Text('礼物过滤器'),
        SwitchListTile(
          title: const Text('启用礼物朗读'),
          value: configMap['dynamic']['filter']['gift']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['gift']['enable'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('启用免费礼物朗读'),
          value: configMap['dynamic']['filter']['gift']['freeGiftEnable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['gift']['freeGiftEnable'] = value;
            });
          },
        ),
        // 几秒内礼物不重复朗读
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['gift']['deduplicateTime']
                  .toString()),
          decoration: const InputDecoration(labelText: '几秒内礼物不重复朗读'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['gift']['deduplicateTime'] = 0;
                return;
              } else {
                configMap['dynamic']['filter']['gift']['deduplicateTime'] =
                    int.parse(value);
              }
            });
          },
        ),
        // 免费礼物数量大于等于
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['gift']
                      ['freeGiftCountBigger']
                  .toString()),
          decoration: const InputDecoration(labelText: '免费礼物数量大于等于'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['gift']['freeGiftCountBigger'] =
                    0;
                return;
              } else {
                configMap['dynamic']['filter']['gift']['freeGiftCountBigger'] =
                    int.parse(value);
              }
            });
          },
        ),
        // 付费礼物金额大于等于
        TextFormField(
          controller: TextEditingController(
              text: configMap['dynamic']['filter']['gift']
                      ['moneyGiftPriceBigger']
                  .toString()),
          decoration: const InputDecoration(labelText: '付费礼物金额大于等于'),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                configMap['dynamic']['filter']['gift']['moneyGiftPriceBigger'] =
                    0;
                return;
              } else {
                configMap['dynamic']['filter']['gift']['moneyGiftPriceBigger'] =
                    int.parse(value);
              }
            });
          },
        ),
        // 舰队购买过滤器 SwitchListTile
        const Text('舰队购买过滤器'),
        SwitchListTile(
          title: const Text('启用舰队购买过滤器'),
          value: configMap['dynamic']['filter']['guardBuy']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['guardBuy']['enable'] = value;
            });
          },
        ),
        // 点赞过滤器 SwitchListTile
        const Text('点赞过滤器'),
        SwitchListTile(
          title: const Text('启用点赞过滤器'),
          value: configMap['dynamic']['filter']['like']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['like']['enable'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('去除重复点赞'),
          value: configMap['dynamic']['filter']['like']['deduplicate'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['like']['deduplicate'] = value;
            });
          },
        ),
        // 启用进入直播键过滤器 SwitchListTile
        const Text('进入直播间过滤器'),
        SwitchListTile(
          title: const Text('启用进入直播间朗读'),
          value: configMap['dynamic']['filter']['welcome']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['welcome']['enable'] = value;
            });
          },
        ),

        // 粉丝牌必须为本直播间
        SwitchListTile(
          title: const Text('粉丝牌必须为本直播间'),
          value: configMap['dynamic']['filter']['welcome']
              ['isFansMedalBelongToLive'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['welcome']
                  ['isFansMedalBelongToLive'] = value;
            });
          },
        ),
        // 大航海大于等于
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: '大航海大于等于'),
          value: configMap['dynamic']['filter']["welcome"]
              ['fansMedalGuardLevelBigger'],
          items: guardLevelOptions.map((level) {
            return DropdownMenuItem<int>(
              value: level,
              child: Text('$level'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                configMap['dynamic']['filter']["welcome"]
                    ['fansMedalGuardLevelBigger'] = value;
              });
            }
          },
        ),

        // 粉丝牌等级大于等于
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: '粉丝牌等级大于等于'),
          value: configMap['dynamic']['filter']["danmu"]
              ['fansMedalLevelBigger'],
          items: medalLevelOptions.map((level) {
            return DropdownMenuItem<int>(value: level, child: Text('$level'));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                configMap['dynamic']['filter']["danmu"]
                    ['fansMedalLevelBigger'] = value;
              });
            }
          },
        ),

        // 订阅过滤器 SwitchListTile
        const Text('订阅过滤器'),
        SwitchListTile(
          title: const Text('启用关注朗读'),
          value: configMap['dynamic']['filter']['subscribe']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['subscribe']['enable'] = value;
            });
          },
        ),
        // 启用进入直播键过滤器 SwitchListTile
        const Text('超级留言过滤器'),
        SwitchListTile(
          title: const Text('启用醒目留言朗读'),
          value: configMap['dynamic']['filter']['superChat']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['superChat']['enable'] = value;
            });
          },
        ),
        // 警告过滤器 SwitchListTile
        const Text('警告过滤器'),
        SwitchListTile(
          title: const Text('启用超管警告朗读'),
          value: configMap['dynamic']['filter']['warning']['enable'],
          onChanged: (value) {
            setState(() {
              configMap['dynamic']['filter']['warning']['enable'] = value;
            });
          },
        ),
        // 文本框展示配置
        Text('当前配置: $configMap'),
      ],
    );
  }
}
