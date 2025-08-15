extension CaseConvert on String {
  /// Split string into parts according to their case.
  ///
  /// 1. All result parts will be lowercased.
  /// 2. It will split by non-alphabet-and-digit characters,
  /// including whitespace and hyphen.
  /// 3. About the case change without separator, see [splitCamelCase].
  List<String> get parts => split(RegExp('[^a-zA-Z0-9]'))
      .map((part) => part.splitCamelCase)
      .expand((nestedPart) => nestedPart)
      .toList();

  /// Split camel case.
  ///
  /// All result parts will be lowercased.
  /// It will split when changing from lowercase to uppercase,
  /// and before from uppercase to lowercase. For example:
  ///
  /// 1. From `'ABCAndAnotherABC'` to `['abc', 'and', 'another', 'abc']`.
  /// 2. From `'abc123abc'` to `['abc123', 'abc']`.
  List<String> get splitCamelCase {
    if (isEmpty) return [];
    final handler = <String>[];
    var char = this[0];
    late String before;
    final buffer = StringBuffer(char);
    for (var i = 1; i < length; i++) {
      before = char;
      char = this[i];
      final current = buffer.toString();

      // From lowercase or digit to uppercase, or from digit to alphabet.
      if (current.isNotEmpty &&
          (((before._lower || before._digit) && char._upper) ||
              (before._digit && (char._upper || char._lower)))) {
        handler.add(current);
        buffer
          ..clear()
          ..write(char);
      }
      // Before uppercase to lowercase.
      else if (current.length > 1 && before._upper && char._lower) {
        handler.add(current.substring(0, current.length - 1));
        buffer
          ..clear()
          ..write(before)
          ..write(char);
      }
      // Otherwise, just pass.
      else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) handler.add(buffer.toString());
    return handler.map((part) => part.toLowerCase()).toList();
  }

  // Only check the first char, it is supposed to be a char.
  // These shortcuts will panic when the string is empty.
  bool get _upper => codeUpper(codeUnitAt(0));
  bool get _lower => codeLower(codeUnitAt(0));
  bool get _digit => codeDigit(codeUnitAt(0));

  bool codeUpper(int charCode) => charCode >= _upperA && charCode <= _upperZ;
  bool codeLower(int charCode) => charCode >= _lowerA && charCode <= _lowerZ;
  bool codeDigit(int charCode) => charCode >= _code0 && charCode <= _code9;

  static final int _upperA = 'a'.toUpperCase().codeUnitAt(0);
  static final int _upperZ = 'z'.toUpperCase().codeUnitAt(0);
  static final int _lowerA = 'a'.toLowerCase().codeUnitAt(0);
  static final int _lowerZ = 'z'.toLowerCase().codeUnitAt(0);
  static final int _code0 = '0'.codeUnitAt(0);
  static final int _code9 = '9'.codeUnitAt(0);

  /// Uppercase the first character and remain the rest.
  String get capitalCase => isEmpty ? '' : this[0].toUpperCase() + substring(1);
  String get upperCase => toUpperCase();
  String get lowerCase => toLowerCase();

  String get wordsCase => parts.join(' ');
  String get kebabCase => parts.join('-');
  String get snakeCase => parts.join('_');
  String get constCase => parts.map((raw) => raw.toUpperCase()).join('_');
  String get pascalCase => parts.map((raw) => raw.capitalCase).join();
  String get camelCase {
    if (isEmpty) return '';
    return parts[0] + parts.sublist(1).map((raw) => raw.capitalCase).join();
  }

  /// Return into an adaptive valid Dart code name identifier.
  ///
  /// When the first letter is uppercase, it will return the pascal case.
  /// Otherwise, it will return the camel case.
  String get adaptiveCodeName {
    if (isEmpty) return '';
    if (_upper) return pascalCase;
    return camelCase;
  }
}
