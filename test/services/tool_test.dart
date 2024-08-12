import 'package:flutter_test/flutter_test.dart';
import 'package:danmuji_flutter/services/tool.dart';

void main() {
  group('isStringAllEmojis 函数:', () {
    test('对于仅包含表情符号的字符串应返回 true', () {
      expect(isStringAllEmojis('😀😂'), isTrue);
      expect(isStringAllEmojis('🌞🌈'), isTrue);
      expect(isStringAllEmojis('🚀🌟'), isTrue);
    });

    test('对于包含非表情符号字符的字符串应返回 false', () {
      expect(isStringAllEmojis('😀hello'), isFalse);
      expect(isStringAllEmojis('world😂'), isFalse);
      expect(isStringAllEmojis('🌟and text🌟'), isFalse);
    });

    test('对于空字符串应返回 false', () {
      expect(isStringAllEmojis(''), isFalse);
    });

    test('对于包含混合内容的字符串应返回 false', () {
      expect(isStringAllEmojis('😀 hello 🌟'), isFalse);
    });
  });
}