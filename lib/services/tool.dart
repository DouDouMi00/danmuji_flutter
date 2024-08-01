bool isStringAllEmojis(String input) {
  RegExp emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
    unicode: true,
  );

  // 直接检查整个字符串是否完全由emoji组成，无需先清理字符串
  bool isAllEmojis = emojiRegex.hasMatch(input) &&
      emojiRegex.allMatches(input).length == input.runes.length;

  return isAllEmojis;
}
