import 'package:danmuji_flutter/common/colors/custom_theme.dart';
import 'package:danmuji_flutter/routes/app_pages.dart';
import 'package:danmuji_flutter/services/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

// import 'package:danmuji_flutter/services/logger.dart';
// https://juejin.cn/post/6844904039495237639

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<ConfigService>(() async => ConfigService().initConfig());
  runApp(MyApp());
  // 添加监听器处理日志记录
  // logger.onRecord.listen(handleLogRecord);
}

class MyApp extends StatelessWidget {
  final appConfig = Get.find<ConfigService>();
  final themeModeMap = {
    '0': ThemeMode.system,
    '1': ThemeMode.light,
    '2': ThemeMode.dark,
  };

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Get.deviceLocale,
      // showSemanticsDebugger: true,
      localizationsDelegates: const [
        // 本地化的代理类
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // 美国英语
        Locale('zh', 'CN'), // 中文简体
        //其它Locales
      ],
      initialRoute: Routes.home,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          themeModeMap[appConfig.configRx.value.system.theme.toString()] ??
              ThemeMode.system,
      getPages: appRoutes,
    );
  }
}
