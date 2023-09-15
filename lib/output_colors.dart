import 'dart:io';

class StdoutColor {
  final int foregroundColor;
  final int backgroundColor;

  const StdoutColor(this.backgroundColor, this.foregroundColor);

  static const StdoutColor red = StdoutColor(31, 89);

  static const StdoutColor green = StdoutColor(32, 89);

  static const StdoutColor yello = StdoutColor(33, 89);

  static const StdoutColor white = StdoutColor(37, 89);

  static const StdoutColor cyan = StdoutColor(36, 89);

  static const StdoutColor grey = StdoutColor(30, 89);

  static const StdoutColor cyanBright = StdoutColor(106, 49);

  static const StdoutColor whiteBright = StdoutColor(107, 49);

  String get startTag => '\x1b[${backgroundColor}m';

  String get endTag => '\x1b[${foregroundColor}m';
}

extension StdoutColors on Stdout {
  void writeColored(String text, StdoutColor color) =>
      stdout.write(coloredString(text, color));

  String coloredString(String text, StdoutColor color) =>
      '${color.startTag}$text${color.endTag}';
}
