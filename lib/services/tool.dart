import 'package:flutter_emoji/flutter_emoji.dart';

var parser = EmojiParser();

bool isStringAllEmojis(String input) {
  if (input.isEmpty) {
    return false;
  }
  for (var rune in input.runes) {
    if (!parser.hasEmoji(String.fromCharCode(rune))) {
      return false;
    }
  }
  return true;
}
