part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const home = _Paths.home;
  static const settings = _Paths.settings;
  static const systemPrompt = _Paths.systemPrompt;
  static const account = _Paths.account;
  static const ttsEngines = _Paths.ttsEngines;
  static const dmFilter = _Paths.dmFilter;
  static const giftFilter = _Paths.giftFilter;
  static const guardBuyFilter = _Paths.guardBuyFilter;
  static const likeFilter = _Paths.likeFilter;
  static const welcomeFilter = _Paths.welcomeFilter;
  static const subscribeFilter = _Paths.subscribeFilter;
  static const superChatFilter = _Paths.superChatFilter;
  static const warningFilter = _Paths.warningFilter;
  static const theme = _Paths.theme;
  static const filterListEditor = _Paths.filterListEditor;
}

abstract class _Paths {
  _Paths._();

  static const home = '/home';
  static const settings = '/settings';
  static const systemPrompt = '/systemPrompt';
  static const account = '/account';
  static const ttsEngines = '/ttsEngines';
  static const dmFilter = '/dmFilter';
  static const giftFilter = '/giftFilter';
  static const guardBuyFilter = '/guardBuyFilter';
  static const likeFilter = '/likeFilter';
  static const welcomeFilter = '/welcomeFilter';
  static const subscribeFilter = '/subscribeFilter';
  static const superChatFilter = '/superChatFilter';
  static const warningFilter = '/warningFilter';
  static const theme = '/theme';
  static const filterListEditor = '/filterListEditor';
}
