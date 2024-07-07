//dm_filter_setting_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/services/config.dart';

class DmFilterSettingPage extends StatefulWidget {
  final Map<String, dynamic> configMap;

  const DmFilterSettingPage({super.key, required this.configMap});

  @override
  // ignore: library_private_types_in_public_api
  _DmFilterSettingPageState createState() => _DmFilterSettingPageState();
}

class _DmFilterSettingPageState extends State<DmFilterSettingPage> {
  final List<int> guardLevelOptions = [0, 1, 2]; // 大航海等级选项
  final List<int> medalLevelOptions = [0, 5, 10, 15, 20, 25]; // 粉丝牌等级选项
  final List<int> lengthOptions = [0, 5, 10, 15, 20]; // 文本
  late Map<String, dynamic> configMap;
  @override
  void initState() {
    super.initState();
    configMap = Get.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 添加AppBar并启用返回按钮
        title: const Text('弹幕过滤器'),
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
                    configMap['dynamic']['filter']['danmu']['symbolEnable'] =
                        value;
                  });
                },
              ),
              // 启用纯表情弹幕朗读
              SwitchListTile(
                title: const Text('启用纯表情弹幕朗读'),
                value: configMap['dynamic']['filter']['danmu']['emojiEnable'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['danmu']['emojiEnable'] =
                        value;
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
                value: configMap['dynamic']['filter']["danmu"]
                    ['readfansMedalName'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']["danmu"]
                        ['readfansMedalName'] = value;
                  });
                },
              ),
              // 去除短时间内重复弹幕
              SwitchListTile(
                title: const Text('去除短时间内重复弹幕'),
                value: configMap['dynamic']['filter']['danmu']['deduplicate'],
                onChanged: (value) {
                  setState(() {
                    configMap['dynamic']['filter']['danmu']['deduplicate'] =
                        value;
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
                  return DropdownMenuItem<int>(
                      value: level, child: Text('$level'));
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
                    text: configMap['dynamic']['filter']['danmu']
                            ['blacklistKeywords']
                        .toString()),
                decoration: const InputDecoration(labelText: '黑名单用户UID(逗号分隔)'),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['danmu']
                          ['blacklistKeywords'] = [];
                    } else if (value.contains(',')) {
                      configMap['dynamic']['filter']['danmu']
                          ['blacklistKeywords'] = value.split(',');
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
                    text: configMap['dynamic']['filter']['danmu']
                            ['blacklistUsers']
                        .toString()),
                decoration: const InputDecoration(labelText: '黑名单用户UID(逗号分隔)'),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['danmu']
                          ['blacklistUsers'] = [];
                      return;
                    } else if (value.contains(',')) {
                      configMap['dynamic']['filter']['danmu']
                          ['blacklistUsers'] = value.split(',');
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
                    text: configMap['dynamic']['filter']['danmu']
                            ['whitelistKeywords']
                        .toString()),
                decoration: const InputDecoration(labelText: '白名单关键词(逗号分隔)'),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['danmu']
                          ['whitelistKeywords'] = [];
                      return;
                    } else if (value.contains(',')) {
                      configMap['dynamic']['filter']['danmu']
                          ['whitelistKeywords'] = value.split(',');
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
                    text: configMap['dynamic']['filter']['danmu']
                            ['whitelistUsers']
                        .toString()),
                decoration: const InputDecoration(labelText: '白名单用户UID(逗号分隔)'),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      configMap['dynamic']['filter']['danmu']
                          ['whitelistUsers'] = [];
                      return;
                    } else if (value.contains(',')) {
                      configMap['dynamic']['filter']['danmu']
                          ['whitelistUsers'] = value.split(',');
                    } else {
                      configMap['dynamic']['filter']['danmu']
                          ['whitelistUsers'] = [value];
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
