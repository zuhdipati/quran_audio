class ArabicNumberUtils {
  ArabicNumberUtils._();

  static const Map<String, String> _arabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static String convert(dynamic number) {
    String input = number.toString();
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (_arabicDigits.containsKey(char)) {
        sb.write(_arabicDigits[char]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }
}
